#!/bin/bash
# Check the status of all Kubernetes resources

echo "=== DEPLOYMENTS ==="
kubectl get deployments -o wide

echo ""
echo "=== PODS ==="
kubectl get pods -o wide

echo ""
echo "=== SERVICES ==="
kubectl get services -o wide

echo ""
echo "=== CONFIGMAP ==="
kubectl get configmap app-configmap -o yaml

echo ""
echo "=== LOGS ==="
echo "Gateway Service logs:"
kubectl logs -l app=gateway-service --tail=20

echo ""
echo "Discovery Service logs:"
kubectl logs -l app=discovery-service --tail=20

echo ""
echo "MySQL logs:"
kubectl logs -l app=mysql --tail=20
