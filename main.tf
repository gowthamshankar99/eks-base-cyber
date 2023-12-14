#tfsec:ignore:aws-eks-no-public-cluster-access
#tfsec:ignore:aws-eks-no-public-cluster-access-to-cidr
#tfsec:ignore:aws-ec2-no-public-egress-sgr
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.19.0"

  cluster_name                   = var.instance_name
  cluster_version                = var.eks_version
  cluster_endpoint_public_access = true
  cluster_enabled_log_types      = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_id     = data.aws_vpc.vpc.id
  subnet_ids = data.aws_subnets.cluster_private_subnets.ids

  manage_aws_auth_configmap = true
  aws_auth_roles = concat(
    var.aws_auth_roles,[{
    rolearn  = module.common_node_role.iam_role_arn
    username = "system:node:{{EC2PrivateDNSName}}"
    groups = [
      "system:bootstrappers",
      "system:nodes"
    ]
  }]
  )

  # not self-managing kms_key for poc
  create_kms_key            = true

  iam_role_use_name_prefix = false

  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  node_security_group_additional_rules = {
    allow_control_plane_tcp = {
      description                   = "Allow TCP Protocol Port"
      protocol                      = "TCP"
      from_port                     = 1024
      to_port                       = 65535
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  eks_managed_node_group_defaults = {
    force_update_version = true
    enable_monitoring    = true
  }

  eks_managed_node_groups = {
    # dedicated mgmt node group, other node groups managed by karpenter
    (var.management_node_group_name) = {
      ami_type       = var.management_node_group_ami_type
      platform       = var.management_node_group_platform
      instance_types = var.management_node_group_instance_types
      capacity_type  = var.management_node_group_capacity_type
      min_size       = var.management_node_group_min_size
      max_size       = var.management_node_group_max_size
      desired_size   = var.management_node_group_desired_size
      disk_size      = var.management_node_group_disk_size
      labels = {
        "nodegroup"               = var.management_node_group_name
        "node.kubernetes.io/role" = var.management_node_group_role
      }
      # taints = {
      #   dedicated = {
      #     key    = "dedicated"
      #     value  = var.management_node_group_role
      #     effect = "NO_SCHEDULE"
      #   }
      # }
    }
  }

  # cluster_identity_providers = var.oidc_identity_providers
}

module "common_node_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.30.0"

  create_instance_profile = true
  create_role             = true
  role_name               = "${var.instance_name}-common-node-role"
  trusted_role_services   = ["ec2.amazonaws.com"]
  role_requires_mfa       = false

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}
