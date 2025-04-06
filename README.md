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
export KUBECONFIG=lke-cluster-config.yaml
```

Now you'll be able to interact with the K8s cluster.
For example:
```shell
kubectl get nodes
```

#### Destroy LKE Cluster
```shell
terraform destroy"
```

### Wazuh K8s

```shell
kubectl apply -k kubernetes/wazuh/lke/
```
