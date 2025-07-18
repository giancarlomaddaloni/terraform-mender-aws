# Mender Deployment on AWS EKS

## Overview

This document outlines the architecture and configuration for deploying the [mender](https://mender.io) server on AWS EKS using Terraform and Helm. mender enables secure, updates for connected embedded Linux devices.

---

<img width="724" height="930" alt="Screenshot 2025-07-18 at 12 28 05 PM" src="https://github.com/user-attachments/assets/7fb57218-b416-44ba-b54b-77a3631ad678" />

---

## Docker Registry Mirroring

To avoid rate limits and reduce pull latency during mender component deployment, Docker images from public registries (like Docker Hub, Bitnami, quay.io, or public.ecr.aws) are mirrored to a private ECR registry.

Multiple GitHub Actions workflows are available to mirror grouped sets of images:

* DB & Bitnami Images: MongoDB, Redis, NGINX, etc.
* EKS Controllers: Cert-Manager, AWS Load Balancer Controller
* NATS Images: Prometheus exporter, NATS server, NATS box
* mender Services: Inventory, Deployments, Device Auth, GUI, Workflows, etc.

These workflows dynamically evaluate JSON-based maps per group and tag combination, and:

* Pull images from source
* Tag them with the ECR URL
* Push to AWS ECR using docker CLI and AWS credentials

This guarantees fast and reliable image pulls within your Kubernetes cluster with full control over versioning.

Update your Helm values to point to your private ECR mirrors:

inventory:
  image:
    repository: <aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/mendersoftware/inventory
    tag: v4.0.1

You can find full workflows under .github/workflows with structure:

- mirror-docker-db.yml
- mirror-docker-eks-controllers.yml
- mirror-docker-nats.yml
- mirror-docker-mender.yml

These use environment variables and JSON mappings for maximum flexibility.

---

## 🛠 Infrastructure Overview

### AWS Resources

* **VPC** with public and private subnets across multiple Availability Zones
* **EKS Cluster** for running mender services
* **EC2 Instances** for running workers
* **ALB Ingress** as a public door for the mender service.
* **S3 Bucket** for storing mender artifacts and TF State.
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

Each mender microservice is deployed as a separate Kubernetes Deployment or Statefulset using Helm:

* `nats` --> on "mender" namespaces
* `aws-load-balancer-controller`
* `aws-efs-controller`
* `cert-manager`

### Helm DB's on "mender" namespace

Each mender microservice is deployed as a separate Kubernetes Deployment using Helm:

* `Redis`
* `MongoDB`

### Helm mender on "mender" namespace

Each mender microservice is deployed as a separate Kubernetes Deployment using Helm:

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


### Ingress & DNS on "mender" namespace

* Ingress managed by **NGINX Controller for mender API and ALB for mender Frontend**
* TLS via **Cert-Manager for ALB dependencies and ACM for ALB Ingress**
* DNS records  managed via **ROUTE53** --> gtest.com as main domain and https:://mender.gtest.com

### Secrets Management

* Sensitive credentials stored in **Kubernetes Secrets**

### Storage

* EFS for statefulset.
* MongoDB
* Redis
* S3 Buckets for mender Artifacts
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
    - cd deploy/kustomize/overlays/mender/controllers/
    - cd deploy/kustomize/overlays/mender/mender-app/
  * Command: 
    - `kustomize build . --enable-helm | kubectl apply -f -`
* Environment provisioning via workspace-based deployment

---



### terraform-mender-aws

Fully automated K8S deployment using Terraform and EKS. Includes VPC, IAM roles, cluster, and EC2/EKS groups. IaC stored in GitHub, ready for CI/CD and further integrations.

### Kubernetes Secrets [MongoDB, Redis, Nats]

  * Redis
    - `REDIS_CONNECTION_STRING: redis://mender:m***@redis-headless.mender.svc.cluster.local:6379`
  * MongoDB: 
    - `MONGO: "mongodb://mender:m***@mongodb.mender.svc.cluster.local:27017/mender?authSource=admin"`
    - `MONGO_URL: "mongodb://mender:m***@mongodb.mender.svc.cluster.local:27017/mender?authSource=admin"`
  * Nats: 
    - `NATS_URI: nats://nats-headless.mender.svc.cluster.local`




### Helm Chart Dependency for [mender, nats] applications.

```bash
* Command:
 `helm dependency build` --> for charts: 
  * deploy/kustomize/charts/mender/
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
  user: "mender",
  pwd: "m***",
  roles: [
    { role: "readWrite", db: "workflows" },
    { role: "dbAdmin", db: "workflows" },
    { role: "userAdmin", db: "workflows" }
  ]
})

use mender
db.createUser({
  user: "mender",
  pwd: "m***",
  roles: [
    { role: "readWrite", db: "mender" },
    { role: "dbAdmin", db: "mender" },
    { role: "userAdmin", db: "mender" }
  ]
})

use deviceauth
db.createUser({
  user: "mender",
  pwd: "m***",
  roles: [
    { role: "readWrite", db: "deviceauth" },
    { role: "dbAdmin", db: "deviceauth" },
    { role: "userAdmin", db: "deviceauth" }
  ]
})

db.getSiblingDB("workflows").grantRolesToUser("mender", [
  { role: "readWrite", db: "workflows" },
  { role: "dbAdmin", db: "workflows" },
  { role: "userAdmin", db: "workflows" }
]);

db.getSiblingDB("deviceauth").grantRolesToUser("mender", [
  { role: "readWrite", db: "deviceauth" },
  { role: "dbAdmin", db: "deviceauth" },
  { role: "userAdmin", db: "deviceauth" }
]);

db.getSiblingDB("useradm").grantRolesToUser("mender", [
  { role: "readWrite", db: "useradm" },
  { role: "dbAdmin", db: "useradm" },
  { role: "userAdmin", db: "useradm" }
]);

db.getSiblingDB("inventory").grantRolesToUser("mender", [
  { role: "readWrite", db: "inventory" },
  { role: "dbAdmin", db: "inventory" },
  { role: "userAdmin", db: "inventory" }
]);

db.getSiblingDB("deployments").grantRolesToUser("mender", [
  { role: "readWrite", db: "deployments" },
  { role: "dbAdmin", db: "deployments" },
  { role: "userAdmin", db: "deployments" }
]);

db.getSiblingDB("gui").grantRolesToUser("mender", [
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
