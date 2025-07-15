locals {

  project_name   = "mender"
  region         = "us-east-1"
  vpc_cidr       = "10.0.0.0/16"
  vpc_name       = "mender-vpc"
  azs            = slice(data.aws_availability_zones.available.names, 0, 3)

  bucket_name    = "artifacts"

  repositories = [
    "mender-web",
    "mender-lb-eks",
    "mender-cert-manager/startupapicheck",
    "mender-cert-manager/acmesolver",
    "mender-cert-manager/cainjector",
    "mender-cert-manager/controller",
    "mender-cert-manager/webhook",
    "mender-mongodb",
    "mender-redis",
    "mender-nats",
    "docker-registry",
    "mender-traefik"
  ]

  k8s_parameters = {
    cluster_name = "${local.project_name}-eks"
  }


}