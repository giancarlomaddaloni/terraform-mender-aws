locals {

  project_name   = "mender"
  region         = "us-east-1"
  vpc_cidr       = "10.0.0.0/16"
  vpc_name       = "mender-vpc"
  azs            = slice(data.aws_availability_zones.available.names, 0, 3)

  bucket_name    = "artifacts"

  hosted_zone    = "gmaddaloni.com"
  domain_name    = "mender.gmaddaloni.com"

  repositories = [
    "mender-lb-eks",
    "mender-cert-manager/startupapicheck",
    "mender-cert-manager/acmesolver",
    "mender-cert-manager/cainjector",
    "mender-cert-manager/controller",
    "mender-cert-manager/webhook",
    "nats",
    "natsio/prometheus-nats-exporter",
    "natsio/nats-server-config-reloader",
    "natsio/nats-box",
    "docker-registry",
    "mender-traefik",
    "bitnami/os-shell",
    "bitnami/nginx",
    "bitnami/mongodb-exporter",
    "bitnami/mongodb",
    "bitnami/kubectl",
    "bitnami/redis-exporter",
    "bitnami/redis-sentinel",
    "bitnami/redis",
    "mendersoftware/workflows",
    "mendersoftware/useradm",
    "mendersoftware/iot-manager",
    "mendersoftware/inventory",
    "mendersoftware/deviceconnect",
    "mendersoftware/deviceconfig",
    "mendersoftware/deviceauth",
    "mendersoftware/deployments",
    "mendersoftware/create-artifact-worker",
    "mendersoftware/gui",
    "traefik"
  ]


  k8s_parameters = {
    cluster_name = "${local.project_name}-eks"
  }


}