output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS control plane API endpoint"
  value       = module.eks.cluster_endpoint
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "configure_kubectl" {
  description = "Run this command to point kubectl at your new cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "ecr_repository_url" {
  description = "ECR repository URL — use this in deployment.yaml"
  value       = aws_ecr_repository.demo_app.repository_url
}

output "ecr_push_commands" {
  description = "Commands to build, tag and push your Docker image to ECR"
  value       = <<-EOT
    aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.demo_app.repository_url}
    docker build -t ${var.cluster_name}-demo-app .
    docker tag ${var.cluster_name}-demo-app:latest ${aws_ecr_repository.demo_app.repository_url}:latest
    docker push ${aws_ecr_repository.demo_app.repository_url}:latest
  EOT
}
