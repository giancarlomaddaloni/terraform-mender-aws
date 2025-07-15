provider "aws" {
  region = local.region

  default_tags {
    tags = {
      Application  = "mender"
      IaCTool      = "github-actions"
      DeployedBy   = "gmaddaloni"
      Repository   = "https://github.com/giancarlomaddaloni/terraform-mender-aws"
      Region       = local.region
    }
  }
}