module "mender_s3" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.2.0"
  bucket  = "${local.project_name}-${local.bucket_name}-nt"
}