#!/bin/bash
# HRMS Backend Deployment Script
# Usage:
#   ./deploy-backend.sh
#   ./deploy-backend.sh --skip-build
#   ./deploy-backend.sh --skip-pull
#   ./deploy-backend.sh --branch <branch-name>

# Defaults
SKIP_BUILD=false
SKIP_PULL=false
BRANCH="main"                         # ← Your backend branch name

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --skip-build) SKIP_BUILD=true ;;
        --skip-pull)  SKIP_PULL=true ;;
        --branch)     BRANCH="$2"; shift ;;
    esac
    shift
done

# Generate version
VERSION=$(date +"%Y%m%d%H%M%S")

# ─── Backend Configuration ────────────────────────────────
DOCKER_IMAGE_NAME="sharanbirajdar/vault-frontend"
DOCKER_IMAGE="$DOCKER_IMAGE_NAME:$VERSION"
DOCKER_LATEST="$DOCKER_IMAGE_NAME:latest"
EC2_HOST="ubuntu@ec2-13-126-151-93.ap-south-1.compute.amazonaws.com"
SSH_KEY="~/Downloads/linux.pem"
CONTAINER_NAME="vault-frontend"
HOST_PORT=3000
CONTAINER_PORT=3000
ENV_FILE="C:\Users\ADMIN\Downloads\fullstack-auth\fullstack-auth\frontend\.env"                       # ← Path to your existing .env file
# ──────────────────────────────────────────────────────────

echo ""
echo "========================================"
echo "   HRMS Backend Deployment Script"
echo "========================================"
echo "   Branch  : $BRANCH"
echo "   Image   : $DOCKER_IMAGE"
echo "   Port    : $HOST_PORT"
echo "========================================"

# Step 1: Pull latest code
if [ "$SKIP_PULL" = false ]; then
    echo ""
    echo -n ">> Pull latest code from origin/$BRANCH? (y/n): "
    read -r CONFIRM
    if [[ "$CONFIRM" == "y" || "$CONFIRM" == "Y" ]]; then
        echo ">> Pulling latest code from origin/$BRANCH..."
        git pull origin $BRANCH
        if [ $? -ne 0 ]; then
            echo "   Git pull failed!"
            exit 1
        fi
        echo "   Code updated successfully"
    else
        echo ">> Skipping git pull (user cancelled)"
    fi
else
    echo ">> Skipping git pull"
fi

# Step 2: Check existing .env file
echo ""
echo ">> Checking for existing .env file..."
if [ -f "$ENV_FILE" ]; then
    echo "   .env file found at: $ENV_FILE"
    echo "   Using existing .env — no changes made"
else
    echo "   ERROR: .env file not found at '$ENV_FILE'"
    echo "   Please create a .env file in the project root before deploying."
    exit 1
fi

# Step 3: Build Docker image
if [ "$SKIP_BUILD" = false ]; then
    echo ""
    echo ">> Building Docker image: $DOCKER_IMAGE..."
    docker build --no-cache -t $DOCKER_IMAGE -t $DOCKER_LATEST .
    if [ $? -ne 0 ]; then
        echo "   Docker build failed!"
        exit 1
    fi
    echo "   Docker image built successfully"
else
    echo ""
    echo -n ">> Enter existing image tag to push (or press Enter for 'latest'): "
    read -r INPUT_TAG
    if [ -z "$INPUT_TAG" ]; then
        VERSION="latest"
    else
        VERSION="$INPUT_TAG"
    fi
    DOCKER_IMAGE="$DOCKER_IMAGE_NAME:$VERSION"
    echo "   Using image: $DOCKER_IMAGE"
fi

# Step 4: Push to Docker Hub
echo ""
echo ">> Pushing $DOCKER_IMAGE to Docker Hub..."
docker push $DOCKER_IMAGE
if [ $? -ne 0 ]; then
    echo "   Docker push failed!"
    exit 1
fi

echo ">> Pushing latest tag to Docker Hub..."
docker push $DOCKER_LATEST
if [ $? -ne 0 ]; then
    echo "   Docker push (latest) failed!"
    exit 1
fi
echo "   Images pushed to Docker Hub"

# Step 5: Deploy to EC2 (copy .env and run container)
echo ""
echo ">> Copying .env file to EC2..."
scp -i $SSH_KEY $ENV_FILE $EC2_HOST:/home/ubuntu/.env
if [ $? -ne 0 ]; then
    echo "   Failed to copy .env to EC2!"
    exit 1
fi
echo "   .env copied to EC2 successfully"

echo ""
echo ">> Deploying backend version $VERSION to EC2..."

DEPLOY_CMD="docker pull $DOCKER_IMAGE && \
  docker stop $CONTAINER_NAME 2>/dev/null; \
  docker rm $CONTAINER_NAME 2>/dev/null; \
  docker run -d --name $CONTAINER_NAME \
  -p ${HOST_PORT}:${CONTAINER_PORT} \
  --env-file /home/ubuntu/.env \
  --restart unless-stopped \
  $DOCKER_IMAGE"

ssh -i $SSH_KEY $EC2_HOST "$DEPLOY_CMD"
if [ $? -ne 0 ]; then
    echo "   EC2 deployment failed!"
    exit 1
fi
echo "   Backend deployed to EC2 successfully"

# Step 6: Verify
echo ""
echo ">> Verifying deployment..."
ssh -i $SSH_KEY $EC2_HOST \
  "docker ps --filter name=$CONTAINER_NAME --format 'Name: {{.Names}}\nStatus: {{.Status}}\nImage: {{.Image}}'"

echo ""
echo "========================================"
echo "   Backend Deployment Complete!"
echo "========================================"
echo "API URL: http://ec2-13-126-151-93.ap-south-1.compute.amazonaws.com:$HOST_PORT"


