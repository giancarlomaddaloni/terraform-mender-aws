data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

data "aws_route53_zone" "mender" {
  name         = "${local.hosted_zone}."
}