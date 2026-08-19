# ECR — private container registry for the demo app image
resource "aws_ecr_repository" "demo_app" {
  name                 = "${var.cluster_name}-demo-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  # Auto-delete images older than 30 days to avoid storage costs
  lifecycle {
    ignore_changes = [tags]
  }

  tags = {
    Project = var.cluster_name
  }
}

# Lifecycle policy — keep only the last 5 images
resource "aws_ecr_lifecycle_policy" "demo_app" {
  repository = aws_ecr_repository.demo_app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 5 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
