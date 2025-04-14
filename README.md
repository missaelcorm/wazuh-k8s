# wazuh-k8s

## Prerequisites
### Terraform
Reffer to: [terraform install](https://developer.hashicorp.com/terraform/install)

### Kustomize
```shell
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
```

```shell
mv kustomize /usr/local/bin/kustomize
```

### Helm (for Linux x86_64/amd64)
```shell
curl -LO https://get.helm.sh/helm-v3.17.2-linux-amd64.tar.gz
```

```shell
tar -zxvf helm-v3.17.2-linux-amd64.tar.gz
```

```shell
mv linux-amd64/helm /usr/local/bin/helm
```

```shell
helm --help
```

## Repo Setup
Wazuh K8s version used: v4.11.1
Repository Tag: https://github.com/wazuh/wazuh-kubernetes/tree/v4.11.1


```shell
export GIT_TAG=v4.11.1
```

```shell
cd /tmp
git clone https://github.com/wazuh/wazuh-kubernetes --branch $GIT_TAG
```

```shell
cp -r /tmp/wazuh-kubernetes/wazuh/* ./kubernetes/wazuh/base
```

## Deployment
### LKE K8s Cluster (Linode Kubernetes Engine) Setup

```shell
cd terraform/lke-cluster
```

```shell
export TF_VAR_token=aabb...9900
```

```shell
terraform init
```

```shell
terraform plan -var-file="terraform.tfvars"
```

```shell
terraform apply -var-file="terraform.tfvars"
```

#### Connect to LKE
```shell
export KUBE_VAR=`terraform output kubeconfig` && echo $KUBE_VAR | base64 -di > lke-cluster-config.yaml
```

```shell
export KUBECONFIG=$(realpath lke-cluster-config.yaml)
```

Now you'll be able to interact with the K8s cluster.
For example:
```shell
kubectl get nodes
```

#### Destroy LKE Cluster
```shell
terraform destroy
```

### Wazuh K8s

Generate certs for indexer and dashboard.
```shell
./kubernetes/wazuh/base/certs/dashboard_http/generate_certs.sh
./kubernetes/wazuh/base/certs/indexer_cluster/generate_certs.sh
```

```shell
kustomize build ./kubernetes/wazuh/lke/ --enable-helm | kubectl apply -f -
```

## Access
### Wazuh Dashboard

Get Dashboard URL:
```shell
export WAZUH_DASHBOARD_IP=$(kubectl -n ingress-nginx get svc ingress-nginx-controller -o json | jq -r '.status.loadBalancer.ingress[].ip')
```

```shell
echo "https://$WAZUH_DASHBOARD_IP"
```

Dashboard credentials:
```shell
# Username
kubectl -n wazuh get secret dashboard-cred -o json | jq -r '.data.username' | base64 -d
# Password
kubectl -n wazuh get secret dashboard-cred -o json | jq -r '.data.password' | base64 -d
```

### Wazuh Server (For connecting agents)
WAZUH_MANAGER:
```shell
export WAZUH_MANAGER=$(kubectl -n ingress-nginx get svc ingress-nginx-controller -o json | jq -r '.status.loadBalancer.ingress[].ip')
```

WAZUH_REGISTRATION_PASSWORD:
```shell
export WAZUH_REGISTRATION_PASSWORD=$(kubectl -n wazuh get secret wazuh-authd-pass -o json | jq -r '.data."authd.pass"' | base64 -d)
```

### Wazuh Agents Registration
#### Linodes (terraform)

```shell
cd terraform/linode_instances
```

```shell
export TF_VAR_token=aabb...9900
```

```shell
export TF_VAR_wazuh_manager=$WAZUH_MANAGER
export TF_VAR_wazuh_registration_password=$WAZUH_REGISTRATION_PASSWORD
```

Use if not using ingress
```shell
export TF_VAR_wazuh_registration_server=$(kubectl -n wazuh get svc wazuh -o json | jq -r '.status.loadBalancer.ingress[].ip')
```

```shell
terraform init
```

```shell
terraform plan -var-file="terraform.tfvars"
```

```shell
terraform apply -var-file="terraform.tfvars"
```

#### Linux
```shell
cd agents/linux-amd64
```

```shell
sudo WAZUH_MANAGER=x.x.x.x WAZUH_REGISTRATION_PASSWORD=xxx WAZUH_AGENT_NAME=hostname ./enroll-linux.sh
```

Uninstall wazuh
```shell
sudo apt-get remove --purge wazuh-agent
```

```shell
sudo systemctl disable wazuh-agent
sudo systemctl daemon-reload
```

#### MacOS
```shell
cd agents/macos-arm
```

```shell
curl -LO https://packages.wazuh.com/4.x/macos/wazuh-agent-4.11.1-1.arm64.pkg
```

```shell
sudo ./enroll-mac.sh <WAZUH_MANAGER> <WAZUH_REGISTRATION_SERVER> <WAZUH_REGISTRATION_PASSWORD> wazuh-agent-4.11.1-1.arm64.pkg
```

Uninstall wazuh
```shell
sudo ./uninstall-wazuh.sh
```

#### Windows
```shell
cd agents/windows-amd64
```

```shell
# Run as Administrator
.\Install-WazuhAgent.ps1 -WazuhManager <WAZUH_MANAGER> -RegistrationServer <WAZUH_REGISTRATION_SERVER> -RegistrationPassword <WAZUH_REGISTRATION_PASSWORD> -AgentName <WAZUH_AGENT_NAME>
```

Uninstall wazuh
```shell
# Run as Administrator
msiexec.exe /x wazuh-agent-4.11.1-1.msi /qn
```

### Wazuh Agents Deregistration
```shell
AGENTS=001,002,003
```

```shell
export WAZUH_API_IP=$(kubectl -n wazuh get svc wazuh -o json | jq -r '.status.loadBalancer.ingress[].ip')
export WAZUH_API_USERNAME=$(kubectl -n wazuh get secret wazuh-api-cred -o json | jq -r '.data.username' | base64 -d)
export WAZUH_API_PASSWORD=$(kubectl -n wazuh get secret wazuh-api-cred -o json | jq -r '.data.password' | base64 -d)
```

```shell
TOKEN=$(curl -u "$WAZUH_API_USERNAME:$WAZUH_API_PASSWORD" -k -X GET "https://$WAZUH_API_IP:55000/security/user/authenticate?raw=true")
```

```shell
curl -k -X DELETE "https://$WAZUH_API_IP:55000/agents?pretty=true&older_than=0s&agents_list=$AGENTS$&status=all" -H  "Authorization: Bearer $TOKEN"
```