#!/bin/sh

echo "Deploying Build " $BUILD_NUM

if kubectl describe ingress backend | grep -q "backend-blue"
then
    echo "Backend environment is Blue. Switching to Green"
    kubectl set image deployment backend-green backend=mzucc/tracker-backend:ci-build-$BUILD_NUM
    kubectl rollout status deployment backend-green
    kubectl patch ingress backend --type merge --patch-file deployment/k8s/backend-ingress-patch-green.yaml
else
    echo "Backend environment is Green. Switching to Blue"
    kubectl set image deployment backend-blue backend=mzucc/tracker-backend:ci-build-$BUILD_NUM
    kubectl rollout status deployment backend-blue
    kubectl patch ingress backend --type merge --patch-file deployment/k8s/backend-ingress-patch-blue.yaml
fi

if kubectl describe ingress frontend | grep -q "frontend-blue"
then
    echo "Frontend environment is Blue. Switching to Green"
    kubectl set image deployment frontend-green frontend=mzucc/tracker-frontend-prod:ci-build-$BUILD_NUM
    kubectl rollout status deployment frontend-green
    kubectl patch ingress frontend --type merge --patch-file deployment/k8s/frontend-ingress-patch-green.yaml
else
    echo "Frontend environment is Green. Switching to Blue"
    kubectl set image deployment frontend-blue frontend=mzucc/tracker-frontend-prod:ci-build-$BUILD_NUM
    kubectl rollout status deployment frontend-blue
    kubectl patch ingress frontend --type merge --patch-file deployment/k8s/frontend-ingress-patch-blue.yaml
fi
