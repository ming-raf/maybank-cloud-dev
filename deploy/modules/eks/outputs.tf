output "cluster_name" {
  value       = aws_eks_cluster.this.name
  description = "EKS cluster name"
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.this.endpoint
  description = "EKS API server endpoint"
}

output "cluster_certificate_authority_data" {
  value       = aws_eks_cluster.this.certificate_authority[0].data
  description = "EKS cluster CA data (base64)"
}

output "node_group_name" {
  value       = aws_eks_node_group.default.node_group_name
  description = "Default managed node group name"
}

output "node_role_arn" {
  value       = aws_iam_role.eks_node_role.arn
  description = "IAM role ARN used by the node group"
}
