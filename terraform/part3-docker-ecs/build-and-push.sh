#!/bin/bash

# Build and Push Docker Images to ECR
# This script builds Docker images and pushes them to AWS ECR

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Docker Image Build and Push Script${NC}"
echo -e "${GREEN}================================${NC}"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}AWS CLI is not installed. Please install it first.${NC}"
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed. Please install it first.${NC}"
    exit 1
fi

# Get AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=${AWS_REGION:-us-east-1}
PROJECT_NAME=${PROJECT_NAME:-flask-express-ecs}

echo -e "${YELLOW}AWS Account ID: $AWS_ACCOUNT_ID${NC}"
echo -e "${YELLOW}AWS Region: $AWS_REGION${NC}"
echo -e "${YELLOW}Project Name: $PROJECT_NAME${NC}"

# ECR Repository URLs
BACKEND_REPO="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$PROJECT_NAME-backend"
FRONTEND_REPO="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$PROJECT_NAME-frontend"

# Login to ECR
echo -e "${GREEN}Logging in to Amazon ECR...${NC}"
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Build Backend Image
echo -e "${GREEN}Building backend Docker image...${NC}"
cd ../backend
docker build -t $PROJECT_NAME-backend:latest .
docker tag $PROJECT_NAME-backend:latest $BACKEND_REPO:latest

# Push Backend Image
echo -e "${GREEN}Pushing backend image to ECR...${NC}"
docker push $BACKEND_REPO:latest

# Build Frontend Image
echo -e "${GREEN}Building frontend Docker image...${NC}"
cd ../frontend
docker build -t $PROJECT_NAME-frontend:latest .
docker tag $PROJECT_NAME-frontend:latest $FRONTEND_REPO:latest

# Push Frontend Image
echo -e "${GREEN}Pushing frontend image to ECR...${NC}"
docker push $FRONTEND_REPO:latest

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Docker images successfully built and pushed!${NC}"
echo -e "${GREEN}================================${NC}"
echo -e "${YELLOW}Backend Image: $BACKEND_REPO:latest${NC}"
echo -e "${YELLOW}Frontend Image: $FRONTEND_REPO:latest${NC}"
