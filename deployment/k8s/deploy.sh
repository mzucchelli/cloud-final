#!/bin/sh

if kubectl describe ingress backend | grep -q "backend-blue"
then
    echo "Environment is Blue. Switching to Green"
    kubectl set image deployment backend-green backend=mzucc/tracker-backend:ci-build-$BUILD_NUM
    kubectl rollout status deployment backend-green
    kubectl patch ingress backend --type merge --patch-file deployment/k8s/backend-ingress-patch-green.yaml
else
    echo "Environment is Green. Switching to Blue"
    kubectl set image deployment backend-blue backend=mzucc/tracker-backend:ci-build-$BUILD_NUM
    kubectl rollout status deployment backend-blue
    kubectl patch ingress backend --type merge --patch-file deployment/k8s/backend-ingress-patch-blue.yaml
fi
