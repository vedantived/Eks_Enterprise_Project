#!/bin/bash

set -e  # stop on error

echo "🚀 STEP 1: Terraform Apply"
cd environment/dev
terraform init
terraform apply -auto-approve

echo "🔧 STEP 2: Update kubeconfig"
aws eks --region ap-south-1 update-kubeconfig --name eks-zero-trust

echo "📦 STEP 3: Create Namespaces"
kubectl create namespace security || true
kubectl create namespace logging || true

echo "🔑 STEP 4: IRSA Setup"
cd ../../platform/irsa
kubectl apply -f serviceaccount.yaml

echo "🚀 STEP 5: Deploy Application"
cd ../../applications/zero-trust-app/base
kubectl apply -k .

echo "⏳ Waiting for pods..."
kubectl wait --for=condition=ready pod -l app=zero-trust-app -n security --timeout=120s

echo "🔒 STEP 6: Apply Network Policies"
cd ../../../platform/security
kubectl apply -f default-deny.yaml
kubectl apply -f allow-node.yaml
kubectl apply -f allow-kube-system.yaml
kubectl apply -f allow-app.yaml

echo "🔄 STEP 7: Restart Deployment"
kubectl rollout restart deployment zero-trust-app -n security

echo "✅ STEP 8: Final Status"
kubectl get pods -n security
kubectl get netpol -n security

echo "🎉 DONE: Full Zero Trust Setup Completed!"
