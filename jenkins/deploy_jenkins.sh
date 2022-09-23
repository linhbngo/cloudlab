#!/bin/bash

helm repo add jenkins https://charts.jenkins.io
helm repo update

set -x

helm install -f /local/repository/jenkins/values.yaml jenkins/jenkins --generate-name
