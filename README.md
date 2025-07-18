# m**er Deployment on AWS EKS

## Overview

This document outlines the architecture and configuration for deploying the [m**er](https://m**er.io) server on AWS EKS using Terraform and Helm. m**er enables secure, updates for connected embedded Linux devices.

---

Docker Registry Mirroring

To avoid rate limits and reduce pull latency during m**er component deployment, Docker images from public registries (like Docker Hub, Bitnami, quay.io, or public.ecr.aws) are mirrored to a private ECR registry.

Multiple GitHub Actions workflows are available to mirror grouped sets of images:

* DB & Bitnami Images: MongoDB, Redis, NGINX, etc.
* EKS Controllers: Cert-Manager, AWS Load Balancer Controller
* NATS Images: Prometheus exporter, NATS server, NATS box
* m**er Services: Inventory, Deployments, Device Auth, GUI, Workflows, etc.

These workflows dynamically evaluate JSON-based maps per group and tag combination, and:

* Pull images from source
* Tag them with the ECR URL
* Push to AWS ECR using docker CLI and AWS credentials

This guarantees fast and reliable image pulls within your Kubernetes cluster with full control over versioning.

Update your Helm values to point to your private ECR mirrors:

inventory:
  image:
    repository: <aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/m**ersoftware/inventory
    tag: v4.0.1

You can find full workflows under .github/workflows with structure:

- mirror-docker-db.yml
- mirror-docker-eks-controllers.yml
- mirror-docker-nats.yml
- mirror-docker-m**er.yml

These use environment variables and JSON mappings for maximum flexibility.

---

## 🛠 Infrastructure Overview

### AWS Resources

* **VPC** with public and private subnets across multiple Availability Zones
* **EKS Cluster** for running m**er services
* **EC2 Instances** for running workers
* **ALB Ingress** as a public door for the m**er service.
* **S3 Bucket** for storing m**er artifacts and TF State.
* **IAM Roles for Service Accounts (IRSA)** for secure serviceAccounts access and roles. 

### Terraform Modules

* `terraform-aws-vpc`
* `terraform-aws-eks`
* `terraform-aws-s3-bucket`
* `terraform-aws-rds`
* `terraform-aws-iam`
* `terraform-aws-sg`
* `terraform-aws-efs`
* `terraform-aws-ecr`
* `terraform-aws-acm`

---

## ☸️ Kubernetes Configuration

### Helm Communication on "kube-system" namespace

Each m**er microservice is deployed as a separate Kubernetes Deployment or Statefulset using Helm:

* `nats` --> on "m**er" namespaces
* `aws-load-balancer-controller`
* `aws-efs-controller`
* `cert-manager`

### Helm DB's on "m**er" namespace

Each m**er microservice is deployed as a separate Kubernetes Deployment using Helm:

* `Redis`
* `MongoDB`

### Helm m**er on "m**er" namespace

Each m**er microservice is deployed as a separate Kubernetes Deployment using Helm:

* `API Gateway`
* `Device Auth`
* `Device Config`
* `Device Connect`
* `User Auth`
* `Inventory`
* `GUI`
* `Storage Proxy`
* `Create Artifact Worker`
* `IOT Manager`
* `User Admin`
* `Workflows`


### Ingress & DNS on "m**er" namespace

* Ingress managed by **NGINX Controller for m**er API and ALB for m**er Frontend**
* TLS via **Cert-Manager for ALB dependencies and ACM for ALB Ingress**
* DNS records  managed via **ROUTE53** --> gmaddaloni.com as main domain and https:://m**er.gmaddaloni.com

### Secrets Management

* Sensitive credentials stored in **Kubernetes Secrets**

### Storage

* EFS for statefulset.
* MongoDB
* Redis
* S3 Buckets for m**er Artifacts
---


## 📈 Observability & Monitoring

* **CloudWatch Metrics** from node group autoscaling and service health

---

## 🧪 CI/CD Integration

### Tools

* **Terraform**: Infrastructure provisioning
* **GitHub Actions / GitLab CI**: CI/CD pipelines for DOCKER Registry Mirroring


### Pipelines

- Terraform Deployment
  * Directories:
    - cd terraform/dependencies/
    - cd terraform/eks/
  * Command: 
    - `terraform plan/apply`
- Helm chart deployment via Kustomize deployment. 
  * Charts: 
    - cd deploy/kustomize/charts/
  * Main Kustomize Path: 
    - cd deploy/kustomize/overlays/m**er/controllers/
    - cd deploy/kustomize/overlays/m**er/m**er-app/
  * Command: 
    - `kustomize build . --enable-helm | kubectl apply -f -`
* Environment provisioning via workspace-based deployment

---



### terraform-m**er-aws

Fully automated K8S deployment using Terraform and EKS. Includes VPC, IAM roles, cluster, and EC2/EKS groups. IaC stored in GitHub, ready for CI/CD and further integrations.

### Kubernetes Secrets [MongoDB, Redis, Nats]

  * Redis
    - `REDIS_CONNECTION_STRING: redis://m**er:m***@redis-headless.m**er.svc.cluster.local:6379`
  * MongoDB: 
    - `MONGO: "mongodb://m**er:m***@mongodb.m**er.svc.cluster.local:27017/m**er?authSource=admin"`
    - `MONGO_URL: "mongodb://m**er:m***@mongodb.m**er.svc.cluster.local:27017/m**er?authSource=admin"`
  * Nats: 
    - `NATS_URI: nats://nats-headless.m**er.svc.cluster.local`




### Helm Chart Dependency for [m**er, nats] applications.

```bash
* Command:
 `helm dependency build` --> for charts: 
  * deploy/kustomize/charts/m**er/
  * deploy/kustomize/charts/nats/

  "Hang tight while we grab the latest from your chart repositories...
  ...Successfully got an update from the "bitnami" chart repository
  Update Complete. ⎈Happy Helming!⎈
  Saving 1 charts
  Deleting outdated charts"
```

### MongoDB User Initialization Commands

```javascript
use workflows
db.createUser({
  user: "m**er",
  pwd: "m***",
  roles: [
    { role: "readWrite", db: "workflows" },
    { role: "dbAdmin", db: "workflows" },
    { role: "userAdmin", db: "workflows" }
  ]
})

use m**er
db.createUser({
  user: "m**er",
  pwd: "m***",
  roles: [
    { role: "readWrite", db: "m**er" },
    { role: "dbAdmin", db: "m**er" },
    { role: "userAdmin", db: "m**er" }
  ]
})

use deviceauth
db.createUser({
  user: "m**er",
  pwd: "m***",
  roles: [
    { role: "readWrite", db: "deviceauth" },
    { role: "dbAdmin", db: "deviceauth" },
    { role: "userAdmin", db: "deviceauth" }
  ]
})

db.getSiblingDB("workflows").grantRolesToUser("m**er", [
  { role: "readWrite", db: "workflows" },
  { role: "dbAdmin", db: "workflows" },
  { role: "userAdmin", db: "workflows" }
]);

db.getSiblingDB("deviceauth").grantRolesToUser("m**er", [
  { role: "readWrite", db: "deviceauth" },
  { role: "dbAdmin", db: "deviceauth" },
  { role: "userAdmin", db: "deviceauth" }
]);

db.getSiblingDB("useradm").grantRolesToUser("m**er", [
  { role: "readWrite", db: "useradm" },
  { role: "dbAdmin", db: "useradm" },
  { role: "userAdmin", db: "useradm" }
]);

db.getSiblingDB("inventory").grantRolesToUser("m**er", [
  { role: "readWrite", db: "inventory" },
  { role: "dbAdmin", db: "inventory" },
  { role: "userAdmin", db: "inventory" }
]);

db.getSiblingDB("deployments").grantRolesToUser("m**er", [
  { role: "readWrite", db: "deployments" },
  { role: "dbAdmin", db: "deployments" },
  { role: "userAdmin", db: "deployments" }
]);

db.getSiblingDB("gui").grantRolesToUser("m**er", [
  { role: "readWrite", db: "gui" },
  { role: "dbAdmin", db: "gui" },
  { role: "userAdmin", db: "gui" }
]);
```

### Create Initial User via CLI

```bash
USERADM_POD=$(kubectl get pod -l 'app.kubernetes.io/component=useradm' -o name | head -1)
kubectl exec $USERADM_POD -- useradm create-user --username "g*****ni@gmail.com" --password "xxxxx"
```

---

## Contact

For architecture diagrams, Helm values, Terraform modules, or live walkthroughs, contact:

**Giancarlo Maddaloni**
*Senior DevOps Engineer*


---
