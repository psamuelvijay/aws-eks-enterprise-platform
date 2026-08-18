# aws-eks-enterprise-platform

Enterprise-grade Kubernetes deployment on Amazon EKS with full CI/CD pipeline.

## Portfolio Site

Live at: https://d3vx9cs0hyk6sf.cloudfront.net

Hosted on S3 + CloudFront with automated deployment via GitHub Actions.

### How to update the site

1. Edit `index.html`, `css/style.css`, or `js/script.js`
2. `git add . && git commit -m "your message"`
3. `git push origin main`
4. GitHub Actions automatically syncs to S3 and invalidates CloudFront cache
5. Changes are live within ~30 seconds

## Project Stack

- **Infrastructure**: Terraform (VPC, subnets, security groups, node groups)
- **Container Orchestration**: Amazon EKS
- **Container Registry**: Amazon ECR
- **Identity**: AWS IAM Authenticator + RBAC
- **Load Balancing**: AWS ALB/NLB
- **Autoscaling**: Cluster Autoscaler + HPA
- **Monitoring**: CloudWatch / Prometheus + Grafana
- **CI/CD**: GitHub Actions
