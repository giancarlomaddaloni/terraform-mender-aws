# terraform-mender-aws
Fully automated K8S deployment using Terraform and EKS. Includes VPC, IAM roles, cluster, and EC2/EKS groups. IaC stored in Github, ready for CI/CD and further integrations.


kubectl create secret generic mender-mongo \
  --namespace mender \
  --from-literal=MONGO="mongodb://mender:mendernt2025@mongodb.mender.svc.cluster.local:27017/mender" \
  --from-literal=MONGO_URL="mongodb://mender:mendernt2025@mongodb.mender.svc.cluster.local:27017/mender"


gmaddaloni@Giancarlos-MacBook-Pro-2 redis % helm dependency build
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "bitnami" chart repository
Update Complete. ⎈Happy Helming!⎈
Saving 1 charts
Deleting outdated charts