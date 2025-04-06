label = "wazuh-lke-cluster"
k8s_version = "1.32"
region = "us-west"
pools = [
  {
    type : "g6-standard-2"
    count : 3
  }
]