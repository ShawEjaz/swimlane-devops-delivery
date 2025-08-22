# Swimlane DevOps Practical — Ijaz

This repo includes:
- The original app under `src/devops-practical` (Node.js + MongoDB)
- `docker/` with Dockerfiles
- `helm/devops-practical` to deploy the app + MongoDB
- `terraform/aws-eks` to provision an EKS cluster (2+ nodes, multi-AZ)
- `k8s-extras/` NetworkPolicy
- Bonus: `ansible/` (NTP) and `packer/` (worker AMI)

## App summary
- Port: **3000**
- Required env var: **MONGODB_URL**
- Health endpoints: `/` used for readiness/liveness in this example.

## Prerequisites
- Docker, kubectl, Helm v3, Terraform >= 1.6
- AWS CLI v2 with credentials

## Build & Push Image
```bash
docker build -f docker/app/Dockerfile -t <REG>/devops-practical:latest .
docker push <REG>/devops-practical:latest
```

## Provision EKS
```bash
cd terraform/aws-eks
terraform init && terraform apply -auto-approve
aws eks update-kubeconfig --name $(terraform output -raw cluster_name) --region $(terraform output -raw region)
```

## Deploy with Helm
```bash
helm upgrade --install swimlane helm/devops-practical   --set image.repository=<REG>/devops-practical   --set image.tag=latest   --set mongodb.storage.storageClass=gp3   -n swimlane --create-namespace
```

### (Optional) Ingress
Enable in `values.yaml` or via flags:
```bash
--set ingress.enabled=true --set ingress.className=alb --set ingress.hosts[0].host=myapp.example.com
```

## Verify & Access
```bash
kubectl get pods -n swimlane
kubectl get svc -n swimlane
# open EXTERNAL-IP in browser, register, add a record, and take screenshot
```

## Clean up
```bash
helm uninstall swimlane -n swimlane
cd terraform/aws-eks && terraform destroy
```

## SPOF & Security
- Multi-AZ node group; app replicas=2 with anti-affinity
- MongoDB (single pod) with PVC — for production use a ReplicaSet/StatefulSet/Operator
- Secrets for DB URI; NetworkPolicy restricts DB access
- HPA for app scaling
