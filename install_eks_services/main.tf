# Install nifi using helm
# tflint-ignore: terraform_required_providers
resource "helm_release" "my_release" {
  name      = "my-release"
  repository = "https://cetic.github.io/helm-charts"
  chart     = "nifi"
  version   = "1.1.6" # Specify the desired chart version
  # enable persistent storage
#   set {
#     name  = "key1"
#     value = "value1"
#   }

#   set {
#     name  = "key2"
#     value = "value2"
#   }

  # Add more set blocks as needed for additional values
  values = [
    templatefile("values.yaml", {
    }),
  ]

  wait = true
}


# resources
resource "helm_release" "elastic_operator" {
  name       = "elastic-operator"
  namespace  = "elastic-system"
  repository = "https://helm.elastic.co"
  chart      = "eck-operator"
  version    = "2.10.0" # Specify the desired chart version


  # Add more set blocks as needed for additional values
}

resource "helm_release" "fluentbit" {
  name       = "aws-for-fluent-bit"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-for-fluent-bit"
  # version    = "0.1.32"


  wait = true  
}

data "aws_eks_cluster" "existing_cluster" {
  name = var.instance_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.instance_name
}