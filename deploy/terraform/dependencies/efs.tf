module "mender_efs" {

  source  = "terraform-aws-modules/efs/aws"
  version = "1.8.0"

  # File system
  name           = "${local.project_name}-efs"
  creation_token = "${local.project_name}-efs-token"
  encrypted      = true

  lifecycle_policy = {
    transition_to_ia = "AFTER_90_DAYS"
  }

  # File system policy
  attach_policy                      = false
  bypass_policy_lockout_safety_check = false

  # Mount targets / security group
  mount_targets = {
    "us-east-1a" = {
      subnet_id = module.mender_vpc.private_subnets[0]
    }
    "us-east-1b" = {
      subnet_id = module.mender_vpc.private_subnets[1]
    }
  }
  security_group_description = "EFS Mender SG"
  security_group_vpc_id      = module.mender_vpc.vpc_id
  security_group_name        = "${local.project_name}-efs-sg"
  security_group_rules = {
    vpc = {
      description = "NFS ingress from VPC private subnets for Mender"
      cidr_blocks = ["${local.vpc_cidr}"]
    }
  }

  # Access point(s)
  access_points = {
    mender_redis_replica = {
      root_directory = {
        path = "/data"
        creation_info = {
          owner_gid   = 1001
          owner_uid   = 1001
          permissions = "755"
        }
      }
    },
    mender_redis_master = {
      root_directory = {
        path = "/data"
        creation_info = {
          owner_gid   = 1001
          owner_uid   = 1001
          permissions = "755"
        }
      }
    },
    mender_mongo = {
      root_directory = {
        path = "/bitnami/mongodb/data/db"
        creation_info = {
          owner_gid   = 1001
          owner_uid   = 1001
          permissions = "755"
        }
      }
    },
    mender_nats_data = {
      root_directory = {
        path = "/data"
        creation_info = {
          owner_gid   = 1001
          owner_uid   = 1001
          permissions = "755"
        }
      }
    },
  }

  # Backup policy
  enable_backup_policy = false

  # Replication configuration
  create_replication_configuration = false
}
