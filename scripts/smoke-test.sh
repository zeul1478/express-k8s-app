#!/bin/bash
echo "🧪 Running smoke tests..."

# Ensure Minikube is running
if ! minikube status | grep -q "Running"; then
    echo "⚠️  Minikube not running. Starting it now..."
    minikube start --driver=docker
fi

# For Docker driver, we need to use port-forward instead of service URL
echo "🔧 Setting up port-forward for Docker driver..."
kubectl port-forward service/express-service 30080:3000 --address=0.0.0.0 &
PORT_FORWARD_PID=$!

# Wait for port-forward to establish
sleep 5

# Test the application using localhost
if curl -f http://localhost:30080/health; then
    echo "✅ Smoke tests passed!"
    # Kill the port-forward
    kill $PORT_FORWARD_PID
else
    echo "❌ Smoke tests failed!"
    kill $PORT_FORWARD_PID
    exit 1
fi