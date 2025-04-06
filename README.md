# wazuh-k8s

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
kubectl apply -k kubernetes/wazuh/lke/
```

## Access
### Wazuh Dashboard

Get Dashboard URL:
```shell
export WAZUH_DASHBOARD_IP=$(kubectl -n wazuh get svc dashboard -o json | jq -r '.status.loadBalancer.ingress[].ip')
export WAZUH_DASHBOARD_PORT=$(kubectl -n wazuh get svc dashboard -o json | jq -r '.spec.ports[].port')
```

```shell
echo "https://$WAZUH_DASHBOARD_IP:$WAZUH_DASHBOARD_PORT"
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
kubectl -n wazuh get svc wazuh-workers -o json | jq -r '.status.loadBalancer.ingress[].ip'
```

WAZUH_REGISTRATION_PASSWORD:
```shell
kubectl -n wazuh get secret wazuh-authd-pass -o json | jq -r '.data."authd.pass"' | base64 -d
```