#!/usr/bin/env bash

set -e

if ! [ $TRAVIS_PULL_REQUEST == "false" ]; then
  echo "This is a pull request. Skipping docker build and ECR deployment.";
  exit 0;
fi

TAG=`if [ "$TRAVIS_BRANCH" == "master" ]; then echo "unstable"; else echo $TRAVIS_BRANCH ; fi`
COMMIT=${TRAVIS_COMMIT::8}

docker --version
pip install --user awscli
export PATH=$PATH:$HOME/.local/bin

aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 689917379567.dkr.ecr.eu-west-1.amazonaws.com

docker build -f Dockerfile.ccl -t $DOCKER_REPO .
docker run --rm --name pgloader $DOCKER_REPO bash -c "pgloader --version"

docker tag $DOCKER_REPO $ECR_ENDPOINT/$DOCKER_REPO:$TAG
docker push $ECR_ENDPOINT/$DOCKER_REPO:$TAG
