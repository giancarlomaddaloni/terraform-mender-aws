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

use workflows
db.createUser({
  user: "mender",
  pwd: "mendernt2025",
  roles: [
    { role: "readWrite", db: "workflows" },
    { role: "dbAdmin", db: "workflows" },
    { role: "userAdmin", db: "workflows" }
  ]
})

use mender
db.createUser({
  user: "mender",
  pwd: "mendernt2025",
  roles: [
    { role: "readWrite", db: "mender" },
    { role: "dbAdmin", db: "mender" },
    { role: "userAdmin", db: "mender" }
  ]
})

use deviceauth
db.createUser({
  user: "mender",
  pwd: "mendernt2025",
  roles: [
    { role: "readWrite", db: "deviceauth" },
    { role: "dbAdmin", db: "deviceauth" },
    { role: "userAdmin", db: "deviceauth" }
  ]
})
db.grantRolesToUser("mender", [
  { role: "readWrite", db: "deviceauth" },
  { role: "dbAdmin", db: "deviceauth" },
  { role: "userAdmin", db: "deviceauth" }
])


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


USERADM_POD=$(kubectl get pod -l 'app.kubernetes.io/component=useradm' -o name | head -1)
kubectl exec $USERADM_POD -- useradm create-user --username "giancarlomaddaloni@gmail.com" --password "mendernt2025"