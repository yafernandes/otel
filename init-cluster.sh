#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

kubectl create ns otel

kubectl apply -n otel -f datadog-secrets.yaml

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.yaml

sleep 5

kubectl wait -n cert-manager --for=condition=ready pod --selector=app.kubernetes.io/name=cert-manager --timeout=5m
kubectl wait -n cert-manager --for=condition=ready pod --selector=app.kubernetes.io/name=cainjector --timeout=5m
kubectl wait -n cert-manager --for=condition=ready pod --selector=app.kubernetes.io/name=webhook --timeout=5m

helm install opentelemetry-operator open-telemetry/opentelemetry-operator -n otel

kubectl wait -n otel --for=condition=ready pod --selector=app.kubernetes.io/name=opentelemetry-operator --timeout=5m

kubectl apply -n otel -f auto-intrumentation.yaml

helm install opentelemetry-collector open-telemetry/opentelemetry-collector -n otel -f otel-daemonset-values.yaml
helm install opentelemetry-cluster-collector open-telemetry/opentelemetry-collector -n otel -f otel-deployment-values.yaml

# No arm64 support - https://github.com/open-telemetry/opentelemetry-network/blob/main/docs/roadmap.md#arm-support
# helm install opentelemetry-ebpf open-telemetry/opentelemetry-ebpf -n otel -f otel-ebpf-values.yaml
