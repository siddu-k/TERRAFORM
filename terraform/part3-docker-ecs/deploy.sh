#!/bin/bash

# Quick Start Script for Part 3: Docker/ECS Deployment

set -e

echo "========================================="
echo "Part 3: Docker/ECS Deployment"
echo "========================================="

# Check prerequisites
echo "Checking prerequisites..."

if ! command -v terraform &> /dev/null; then
    echo "ERROR: Terraform is not installed"
    exit 1
fi

if ! command -v aws &> /dev/null; then
    echo "ERROR: AWS CLI is not installed"
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker is not installed"
    exit 1
fi

if ! aws sts get-caller-identity &> /dev/null; then
    echo "ERROR: AWS credentials not configured"
    exit 1
fi

echo "✓ All prerequisites met"

# Navigate to directory
cd "$(dirname "$0")"

# Step 1: Create ECR repositories
echo ""
echo "Step 1: Creating ECR repositories..."
terraform init
terraform apply -target=aws_ecr_repository.backend -target=aws_ecr_repository.frontend -auto-approve

# Step 2: Build and push Docker images
echo ""
echo "Step 2: Building and pushing Docker images..."
export AWS_REGION=${AWS_REGION:-us-east-1}
export PROJECT_NAME=${PROJECT_NAME:-flask-express-ecs}

./build-and-push.sh

# Step 3: Deploy full infrastructure
echo ""
echo "Step 3: Deploying full infrastructure..."
terraform plan -out=tfplan

read -p "Do you want to deploy the infrastructure? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Deployment cancelled"
    exit 0
fi

terraform apply tfplan

# Display outputs
echo ""
echo "========================================="
echo "Deployment Complete!"
echo "========================================="
terraform output

echo ""
echo "NOTE: Wait 5-10 minutes for ECS tasks to start"
echo "Then access:"
echo "  - Application: $(terraform output -raw application_url)"
echo "  - Backend API: $(terraform output -raw backend_api_url)"
