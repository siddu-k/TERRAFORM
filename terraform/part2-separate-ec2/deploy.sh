#!/bin/bash

# Quick Start Script for Part 2: Separate EC2 Deployment

set -e

echo "========================================="
echo "Part 2: Separate EC2 Instances Deployment"
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

if ! aws sts get-caller-identity &> /dev/null; then
    echo "ERROR: AWS credentials not configured"
    exit 1
fi

echo "✓ All prerequisites met"

# Navigate to directory
cd "$(dirname "$0")"

# Initialize Terraform
echo ""
echo "Step 1: Initializing Terraform..."
terraform init

# Plan
echo ""
echo "Step 2: Planning deployment..."
terraform plan -out=tfplan

# Confirm before applying
echo ""
read -p "Do you want to apply this plan? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Deployment cancelled"
    exit 0
fi

# Apply
echo ""
echo "Step 3: Applying Terraform configuration..."
terraform apply tfplan

# Display outputs
echo ""
echo "========================================="
echo "Deployment Complete!"
echo "========================================="
terraform output

echo ""
echo "NOTE: Wait 3-5 minutes for applications to start"
echo "Then access:"
echo "  - Backend API: http://$(terraform output -raw backend_public_ip):8000"
echo "  - Frontend: http://$(terraform output -raw frontend_public_ip):3000"
