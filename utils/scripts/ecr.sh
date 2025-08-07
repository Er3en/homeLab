#!/bin/bash

aws ecr create-repository --repository-name fastapi-test --region eu-central-1

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
aws ecr get-login-password --region eu-central-1 \
  | docker login --username AWS \
  --password-stdin ${ACCOUNT_ID}.dkr.ecr.eu-central-1.amazonaws.com

docker tag fastapi-test:latest ${ACCOUNT_ID}.dkr.ecr.eu-central-1.amazonaws.com/fastapi-test:latest

docker push ${ACCOUNT_ID}.dkr.ecr.eu-central-1.amazonaws.com/fastapi-test:latest