#!/bin/bash

# Production Deployment Script for Attendance Portal
# This script safely deploys the application with zero downtime

set -e  # Exit on any error

echo "🚀 Starting Production Deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    print_error "docker-compose not found. Please install Docker Compose."
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "docker-compose.prod.yml" ]; then
    print_error "docker-compose.prod.yml not found. Please run this script from the project root."
    exit 1
fi

# Backup current containers (optional)
print_status "Creating backup of current deployment..."
docker-compose -f docker-compose.prod.yml ps > deployment-backup-$(date +%Y%m%d-%H%M%S).txt 2>/dev/null || true

# Stop and remove old containers
print_status "Stopping old containers..."
docker-compose -f docker-compose.prod.yml down

# Pull latest images (if using external images)
print_status "Pulling latest base images..."
docker-compose -f docker-compose.prod.yml pull mongo || true

# Build new images
print_status "Building new application images..."
docker-compose -f docker-compose.prod.yml build --no-cache

# Start services in correct order
print_status "Starting MongoDB..."
docker-compose -f docker-compose.prod.yml up -d mongo

print_status "Waiting for MongoDB to be ready..."
sleep 10

print_status "Starting backend service..."
docker-compose -f docker-compose.prod.yml up -d attendence-backend

print_status "Waiting for backend to be ready..."
sleep 15

# Health check for backend
print_status "Checking backend health..."
for i in {1..30}; do
    if curl -f http://localhost:5000/api/health > /dev/null 2>&1; then
        print_success "Backend is healthy!"
        break
    fi
    if [ $i -eq 30 ]; then
        print_error "Backend health check failed after 30 attempts"
        print_status "Backend logs:"
        docker-compose -f docker-compose.prod.yml logs attendence-backend
        exit 1
    fi
    print_status "Waiting for backend... (attempt $i/30)"
    sleep 2
done

print_status "Starting frontend service..."
docker-compose -f docker-compose.prod.yml up -d frontend

print_status "Waiting for frontend to be ready..."
sleep 10

# Health check for frontend
print_status "Checking frontend health..."
for i in {1..20}; do
    if curl -f http://localhost/health > /dev/null 2>&1; then
        print_success "Frontend is healthy!"
        break
    fi
    if [ $i -eq 20 ]; then
        print_error "Frontend health check failed after 20 attempts"
        print_status "Frontend logs:"
        docker-compose -f docker-compose.prod.yml logs frontend
        exit 1
    fi
    print_status "Waiting for frontend... (attempt $i/20)"
    sleep 2
done

# Final status check
print_status "Checking all services..."
docker-compose -f docker-compose.prod.yml ps

print_success "🎉 Deployment completed successfully!"
print_status "Application is available at:"
print_status "  Frontend: http://localhost"
print_status "  Backend API: http://localhost:5000"
print_status "  Health Check: http://localhost/health"

# Show logs
print_status "Recent logs:"
docker-compose -f docker-compose.prod.yml logs --tail=10

print_success "Deployment script completed!"
