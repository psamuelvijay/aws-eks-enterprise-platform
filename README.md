# AWS EKS Enterprise Platform Deployment

## 🎯 Project Overview

This project demonstrates a complete **enterprise-grade Kubernetes deployment on Amazon EKS** using Infrastructure as Code (Terraform) and modern DevOps practices. It includes automated CI/CD pipelines, containerized application deployment, and comprehensive AWS integrations.

---

## 📋 Table of Contents

- [Architecture](#architecture)
- [Features](#features)
- [Cost Analysis](#cost-analysis)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Deployment Guide](#deployment-guide)
- [Portfolio Website](#portfolio-website)
- [Cleanup](#cleanup)
- [Technologies Used](#technologies-used)

---

## 🏗️ Architecture

### Infrastructure Components

**Compute & Orchestration:**
- **Amazon EKS** - Managed Kubernetes control plane (v1.32)
- **EKS Managed Node Group** - 2× t3.small instances (auto-scaling 1-3)
- **Amazon ECR** - Private container registry

**Networking:**
- **VPC** - Custom VPC (10.0.0.0/16)
- **Subnets** - 2 public + 2 private across 2 Availability Zones
- **NAT Gateway** - Single NAT for cost optimization
- **Internet Gateway** - Public internet access
- **Network Load Balancer** - Application traffic distribution

**Security:**
- **IAM Roles** - EKS cluster and node group roles with least privilege
- **Security Groups** - Network-level access control
- **KMS** - Encryption for Kubernetes secrets
- **EKS Access Entries** - Fine-grained cluster access control

**Monitoring & Logging:**
- **CloudWatch Logs** - EKS control plane logs (API, audit, authenticator)
- **AWS Cost Explorer** - Budget tracking and cost monitoring
- **AWS Budgets** - $0.01 spending alerts

**CI/CD:**
- **GitHub Actions** - Automated deployment pipeline
- **S3 + CloudFront** - Static website hosting with global CDN

---

## ✨ Features

### 1. Infrastructure as Code (Terraform)
- Modular Terraform configuration using official AWS modules
- Automated VPC, EKS cluster, and node group provisioning
- ECR repository with lifecycle policies (keep last 5 images)
- Cost-optimized architecture (single NAT gateway)

### 2. Containerized Application
- Custom Docker image built on nginx Alpine
- Pushed to Amazon ECR
- Deployed on Kubernetes with 2 replicas (scaled to 4 for demo)
- Health checks (readiness + liveness probes)
- Resource limits (CPU: 250m, Memory: 256Mi)

### 3. Kubernetes Deployment
- **Deployment**: 2 pod replicas with rolling updates
- **Service**: LoadBalancer type exposing port 80
- **Auto-scaling**: Demonstrated manual scaling from 2 to 4 pods
- **High Availability**: Multi-AZ deployment

### 4. CI/CD Pipeline (Portfolio Site)
- GitHub Actions workflow for automated S3 sync
- CloudFront cache invalidation on every push
- HTTPS enabled via CloudFront managed certificate

### 5. Cost Management
- AWS Budget with $0.01 threshold
- Email alerts for actual and forecasted spending
- Cost Anomaly Detection monitor

---

## 💰 Cost Analysis

### Resources Created (Session Duration: ~40 minutes)

| Resource | Hourly Cost | Session Cost | Monthly Cost |
|----------|------------|--------------|--------------|
| **EKS Control Plane** | $0.10 | $0.067 | $72.00 |
| **NAT Gateway** | $0.045 | $0.030 | $32.40 |
| **Network Load Balancer** | Free tier | $0.00 | $0.00* |
| **2× t3.small EC2** | Free tier | $0.00 | $0.00* |
| **ECR Storage** | Negligible | <$0.01 | <$0.50 |
| **CloudWatch Logs** | Free tier | $0.00 | $0.00* |
| **VPC (subnets, IGW)** | Free | $0.00 | $0.00 |
| **S3 + CloudFront** | Free tier | $0.00 | $0.00* |
| **TOTAL** | **$0.145/hr** | **~$0.10** | **~$104.40** |

*Free tier: First 750 hours/month for NLB and EC2, 5GB CloudWatch Logs, 50GB CloudFront data transfer

### Actual Billing
- **Session Cost**: ~$0.10 USD (EKS cluster ran for 40 minutes)
- **Current AWS Bill**: $0.00 (charges post hourly with delay)
- **Budget Forecast**: $7.57/month (before teardown)
- **Final Cost**: ~$0.10 USD (all resources deleted)

---

## 📦 Prerequisites

### Required Tools
- **AWS CLI** v2.36+
- **kubectl** v1.31+
- **Terraform** v1.10+
- **Docker** Desktop with WSL2 integration
- **Git**

### AWS Account Setup
1. AWS Account with AdministratorAccess IAM user
2. AWS CLI configured with credentials
3. Free tier eligibility (recommended for cost savings)

---

## 📁 Project Structure

```
.
├── .github/
│   └── workflows/
│       └── deploy.yml          # CI/CD pipeline for portfolio site
├── terraform/
│   ├── main.tf                 # AWS + Kubernetes provider config
│   ├── variables.tf            # Input variables
│   ├── vpc.tf                  # VPC with single NAT gateway
│   ├── eks.tf                  # EKS cluster + managed node group
│   ├── ecr.tf                  # ECR repository with lifecycle policy
│   ├── outputs.tf              # Cluster endpoint, ECR commands, kubectl config
│   ├── app/
│   │   ├── Dockerfile          # nginx Alpine + custom HTML
│   │   └── index.html          # EKS demo application UI
│   └── k8s/
│       ├── deployment.yaml     # Kubernetes deployment (2 replicas)
│       └── service.yaml        # LoadBalancer service
├── css/
│   └── style.css               # Portfolio site styles
├── js/
│   └── script.js               # Portfolio site interactions
├── index.html                  # Portfolio landing page
├── .gitignore
└── README.md
```

---

## 🚀 Deployment Guide

### Phase 1: Portfolio Website (CloudFront + S3)

**Cost**: FREE (within free tier)

```bash
# 1. Create S3 bucket
aws s3 mb s3://your-portfolio-bucket --region us-east-1
aws s3 website s3://your-portfolio-bucket --index-document index.html

# 2. Upload files
aws s3 sync . s3://your-portfolio-bucket --exclude ".git/*" --exclude "terraform/*"

# 3. Create CloudFront distribution (via AWS Console)
# Origin: S3 website endpoint
# Viewer Protocol: Redirect HTTP to HTTPS

# 4. Set up GitHub Actions CI/CD
# Add AWS credentials to GitHub Secrets:
# - AWS_ACCESS_KEY_ID
# - AWS_SECRET_ACCESS_KEY
```

**Result**: https://d3vx9cs0hyk6sf.cloudfront.net

---

### Phase 2: EKS Cluster Deployment

**Cost**: $0.10/hour (~$72/month) - EKS control plane has NO free tier

⚠️ **WARNING**: Running `terraform apply` will start billing immediately.

```bash
# 1. Install Terraform
# Windows: Download from https://www.terraform.io/downloads
# Add to PATH: $env:USERPROFILE\AppData\Local\Programs\Terraform

# 2. Initialize Terraform
cd terraform
terraform init

# 3. Review infrastructure plan
terraform plan

# 4. Deploy infrastructure (⚠️ BILLING STARTS HERE)
terraform apply -auto-approve

# This creates:
# - VPC with 4 subnets (2 public + 2 private)
# - NAT Gateway + Elastic IP
# - EKS Cluster (takes 10-15 minutes)
# - EKS Node Group with 2× t3.small instances (takes 3-5 minutes)
# - ECR repository
# - Security groups, IAM roles, KMS key
```

---

### Phase 3: Application Deployment

```bash
# 1. Configure kubectl
aws eks update-kubeconfig --region ap-south-1 --name demo-eks-cluster

# 2. Verify cluster access
kubectl get nodes
# Should show 2 nodes in Ready state

# 3. Build Docker image
cd terraform/app
docker build -t demo-eks-cluster-demo-app .

# 4. Authenticate with ECR
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com

# 5. Tag and push image
docker tag demo-eks-cluster-demo-app:latest <ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/demo-eks-cluster-demo-app:latest
docker push <ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/demo-eks-cluster-demo-app:latest

# 6. Update deployment.yaml with ECR image URL
# Edit terraform/k8s/deployment.yaml:
# image: <ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/demo-eks-cluster-demo-app:latest

# 7. Deploy to Kubernetes
kubectl apply -f terraform/k8s/deployment.yaml
kubectl apply -f terraform/k8s/service.yaml

# 8. Get LoadBalancer URL (wait 2-3 minutes)
kubectl get service demo-app-service
# EXTERNAL-IP: afd384372f2594259a0da7a8c0289120-d00ebcb60049a3d5.elb.ap-south-1.amazonaws.com

# 9. Test the application
curl http://<LOAD_BALANCER_URL>

# 10. Demonstrate scaling
kubectl scale deployment demo-app --replicas=4
kubectl get pods
# Should show 4 pods running
```

---

### Phase 4: Verification & Screenshots

```powershell
# Capture these for documentation:

# 1. Cluster info
kubectl cluster-info

# 2. Node status
kubectl get nodes -o wide

# 3. Pod details
kubectl get pods -o wide

# 4. Service with LoadBalancer
kubectl get service demo-app-service

# 5. Application in browser
start http://<LOAD_BALANCER_URL>
```

---

## 🧹 Cleanup

**CRITICAL**: To stop billing, delete all resources immediately after testing.

```bash
# Quick cleanup (recommended)
# 1. Delete node group
aws eks delete-nodegroup --cluster-name demo-eks-cluster --nodegroup-name demo --region ap-south-1

# 2. Delete LoadBalancer service (deletes NLB)
kubectl delete service demo-app-service

# 3. Wait for node group deletion (3-5 minutes)
aws eks describe-nodegroup --cluster-name demo-eks-cluster --nodegroup-name demo --region ap-south-1

# 4. Delete EKS cluster
aws eks delete-cluster --name demo-eks-cluster --region ap-south-1

# 5. Wait for cluster deletion (5-10 minutes)
aws eks describe-cluster --name demo-eks-cluster --region ap-south-1

# 6. Delete NAT Gateway
aws ec2 delete-nat-gateway --nat-gateway-id <NAT_GW_ID> --region ap-south-1

# 7. Release Elastic IP
aws ec2 release-address --allocation-id <EIP_ALLOC_ID> --region ap-south-1

# 8. Delete remaining resources via AWS Console
# - VPC
# - Security Groups
# - IAM Roles
# - ECR Repository
# - CloudWatch Log Groups
# - KMS Key
```

**Terraform Destroy** (alternative, but may fail due to dependencies):
```bash
cd terraform
terraform destroy -auto-approve
```

**Portfolio Site** (keep running - FREE):
- S3 bucket: `psamuelvijay-portfolio`
- CloudFront distribution ID: `EXKIGKQ3L0VXL`
- URL: https://d3vx9cs0hyk6sf.cloudfront.net

---

## 🌐 Portfolio Website

**Live URL**: https://d3vx9cs0hyk6sf.cloudfront.net

### Features
- Responsive design
- HTTPS enabled (CloudFront managed certificate)
- Global CDN distribution
- Automated deployment via GitHub Actions
- CI/CD pipeline syncs on every push to `main` branch

### CI/CD Workflow
```yaml
# .github/workflows/deploy.yml
Trigger: Push to main branch
Steps:
  1. Checkout code
  2. Sync files to S3
  3. Invalidate CloudFront cache
```

---

## 🛠️ Technologies Used

### Infrastructure & Cloud
- **Amazon EKS** - Managed Kubernetes service
- **Amazon ECR** - Container registry
- **Amazon VPC** - Network isolation
- **AWS IAM** - Access management
- **AWS KMS** - Encryption at rest
- **CloudWatch** - Logging and monitoring

### Infrastructure as Code
- **Terraform** v1.10+ - Infrastructure provisioning
- **terraform-aws-modules** - Official AWS modules (VPC, EKS)

### Container & Orchestration
- **Docker** - Container runtime
- **Kubernetes** v1.32 - Container orchestration
- **kubectl** - Kubernetes CLI
- **nginx Alpine** - Web server base image

### CI/CD & Version Control
- **GitHub Actions** - Automated workflows
- **Git** - Version control
- **AWS CLI** v2 - Command-line AWS management

### Web Technologies
- **HTML5** - Portfolio structure
- **CSS3** - Styling and animations
- **JavaScript** - Interactive features
- **CloudFront** - CDN
- **S3** - Static hosting

---

## 📊 Key Learnings

1. **Cost Optimization**: Single NAT gateway instead of one per AZ saves ~$32/month
2. **Free Tier Utilization**: t3.small instances and NLB covered by free tier (750 hours/month)
3. **EKS Control Plane Cost**: No free tier - $0.10/hour regardless of usage
4. **Deployment Time**: EKS cluster takes 10-15 minutes, node group takes 3-5 minutes
5. **Access Management**: EKS Access Entries required for kubectl authentication
6. **Image Storage**: ECR lifecycle policies automatically clean old images

---

## 📸 Documentation Evidence

Screenshots captured during deployment:
1. ✅ AWS EKS cluster status (ACTIVE)
2. ✅ kubectl get nodes (2 nodes Ready)
3. ✅ kubectl get pods (4 pods Running - scaled from 2)
4. ✅ kubectl get service (LoadBalancer with external IP)
5. ✅ Application running in browser
6. ✅ CloudFront distribution for portfolio site
7. ✅ GitHub Actions workflow successful

---

## 🎓 Skills Demonstrated

- Cloud Infrastructure Design (AWS)
- Infrastructure as Code (Terraform)
- Container Orchestration (Kubernetes)
- CI/CD Pipeline Implementation (GitHub Actions)
- Docker Image Building & Registry Management
- Network Architecture (VPC, Subnets, NAT, Load Balancers)
- Security Best Practices (IAM, Security Groups, KMS)
- Cost Optimization & Budget Management
- DevOps Automation
- Problem Solving & Debugging

---

## 📧 Contact

**Name**: Samuel Vijay P  
**Email**: samuelvijay2004@gmail.com  
**Portfolio**: https://d3vx9cs0hyk6sf.cloudfront.net  
**GitHub**: https://github.com/psamuelvijay/aws-eks-enterprise-platform

---

## 📄 License

This project is for educational and demonstration purposes.

---

## ⚠️ Disclaimer

This project incurs AWS costs when deployed. Always monitor your AWS billing dashboard and set up budget alerts. Delete all resources immediately after testing to avoid unexpected charges. The author is not responsible for any AWS charges incurred.

---

**Last Updated**: August 19, 2026  
**Total Session Cost**: ~$0.10 USD  
**Status**: ✅ All resources cleaned up, portfolio site live
