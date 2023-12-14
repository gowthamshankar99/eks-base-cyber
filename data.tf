data "aws_vpc" "vpc" {
  tags = {
    Name = "default"
  }
}

data "aws_subnets" "cluster_private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  tags = {
    reg = var.subnet_identifier
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}
