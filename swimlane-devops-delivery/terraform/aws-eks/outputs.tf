output "cluster_name" { value = module.eks.cluster_name }
output "region"       { value = var.region }
output "kubeconfig" {
  description = "Run the following after apply"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region}"
}
