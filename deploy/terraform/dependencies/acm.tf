module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "6.0.0"
  create_route53_records = true
  domain_name = local.domain_name
  validate_certificate = true
  validation_method = "DNS"
  zone_id = data.aws_route53_zone.mender.zone_id
}