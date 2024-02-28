#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

kubectl create ns developer-app

kubectl apply -f mysql.yaml
kubectl apply -f adminer.yaml

kubectl apply -f kafka.yaml

kubectl apply -f rabbitmq.yaml

kubectl apply -n developer-app -f toolbox.yaml

kubectl apply -f developer-app.yaml
kubectl apply -f services.yaml
kubectl apply -f blackholes.yaml

kubectl apply -f loadrunner.yaml
