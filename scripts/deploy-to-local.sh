#!/bin/bash
echo "🚀 Deploying to local Kubernetes cluster..."

# Check if Minikube is running
if ! minikube status | grep -q "Running"; then
    echo "⚠️  Minikube not running. Starting it now..."
    minikube start --driver=docker
fi

# Update Kubernetes deployment with correct container name
kubectl set image deployment/express-deployment express-app=zeul1478/express-sample:latest

echo "✅ Deployment updated!"
echo "📋 Checking rollout status..."
kubectl rollout status deployment/express-deployment --timeout=120s

echo "🎉 Deployment complete!"