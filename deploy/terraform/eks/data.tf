data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

data "aws_vpc" "mender" {
  filter {
    name   = "tag:Name"
    values = [local.vpc_name]
  }
}


data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.mender.id]
  }

  filter {
    name   = "tag:Name"
    values = ["mender-private-*"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.mender.id]
  }

  filter {
    name   = "tag:Name"
    values = ["mender-public-*"]
  }
}


data "aws_default_tags" "mender" {}
