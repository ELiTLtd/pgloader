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

eval $(aws ecr get-login --region eu-west-1 --no-include-email)

docker build -f Dockerfile.ccl -t $DOCKER_REPO .
docker run --rm --name pgloader $DOCKER_REPO bash -c "pgloader --version"

docker tag $DOCKER_REPO $ECR_ENDPOINT/$DOCKER_REPO:$TAG
docker push $ECR_ENDPOINT/$DOCKER_REPO:$TAG
