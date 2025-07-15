module "mender_eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.37.1"
  cluster_name    = local.k8s_parameters.cluster_name
  cluster_version = local.k8s_parameters.version
  cluster_security_group_id = module.cluster_sg.security_group_id
  cluster_endpoint_public_access  = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]
  enable_cluster_creator_admin_permissions = true
  control_plane_subnet_ids = data.aws_subnets.private.ids
  cluster_enabled_log_types = [ "audit", "api", "authenticator" ]
  cluster_addons = {
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {} 

  }

  vpc_id                   = data.aws_vpc.mender.id
  subnet_ids               = data.aws_subnets.private.ids


  access_entries = {
    terraform = {
      kubernetes_groups = [] 
      principal_arn     = "arn:aws:sts::194722422560:federated-user/terraform"
      policy_associations = {
        namespace = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
          access_scope = {
            namespaces = local.k8s_parameters.namespace_access
            type       = "namespace"
          }
        },
        cluster = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type       = "cluster"
          }
        }
      }
    },
    mender_deploy = {
      kubernetes_groups = [] 
      principal_arn     = "arn:aws:sts::194722422560:federated-user/mender-deploy"
      policy_associations = {
        namespace = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
          access_scope = {
            namespaces = local.k8s_parameters.namespace_access
            type       = "namespace"
          }
        },
        cluster = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type       = "cluster"
          }
        }
      }
    },
    northerntech_team = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:sts::194722422560:federated-user/northerntech-team"
      policy_associations = {
        namespace = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
          access_scope = {
            namespaces = local.k8s_parameters.namespace_access
            type       = "namespace"
          }
        },
        cluster = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type       = "cluster"
          }
        }
      }
    }
  }


}

resource "aws_eks_addon" "coredns" {
  cluster_name = module.mender_eks.cluster_name
  addon_name   = "coredns"
  addon_version = "v1.11.4-eksbuild.2"
  resolve_conflicts_on_create = "OVERWRITE"  
  
  depends_on = [
    module.mender_eks,
    module.mender_node_group
  ]
}


resource "aws_eks_addon" "coredns" {
  cluster_name = module.mender_eks.cluster_name
  addon_name   = "coredns"
  addon_version = "v1.11.4-eksbuild.2"
  resolve_conflicts_on_create = "OVERWRITE"  
  
  depends_on = [
    module.mender_eks,
    module.mender_node_group
  ]
}


module "mender_node_group" {
  source = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"

  name            = local.k8s_parameters.node_group_name
  cluster_name    = local.k8s_parameters.cluster_name
  
  cluster_version = local.k8s_parameters.version

  subnet_ids   = data.aws_subnets.private.ids

  min_size     = local.k8s_parameters.min_size
  max_size     = local.k8s_parameters.max_size
  desired_size = local.k8s_parameters.desired_size

  iam_role_arn = aws_iam_role.mender_eks_node_role.arn

  instance_types       = local.k8s_parameters.instance_types
  capacity_type        = local.k8s_parameters.capacity_type
  cluster_service_cidr = local.k8s_parameters.cluster_service_cidr

  launch_template_tags   = data.aws_default_tags.mender.tags
  vpc_security_group_ids = [module.cluster_sg.security_group_id]

  labels = {
    "application" : "mender"
  }

  depends_on = [
    module.mender_eks
  ]
  
}