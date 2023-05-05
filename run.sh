#!/bin/bash

GH_OWNER=$GITHUB_OWNER
GH_REPOSITORY=$GITHUB_REPOSITORY
GH_TOKEN=$GITHUB_PAT

# Determine if is org runner or repo runner
if [ -z "$GH_REPOSITORY" ]
then
    GH_FULL="${GH_OWNER}"
    CONTEXT=orgs
else
    GH_FULL="${GH_OWNER}/${GH_REPOSITORY}"
    CONTEXT=repos
fi

# Use this variable for URLs
echo "GH_FULL (${CONTEXT}): ${GH_FULL}"

# Registration
RUNNER_SUFFIX=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 5 | head -n 1)
RUNNER_NAME="${GH_FULL}-${RUNNER_SUFFIX}"

REG_URL="https://api.github.com/${CONTEXT}/${GH_FULL}/actions/runners/registration-token"
echo REG_URL: ${REG_URL}

REG_TOKEN=$(curl -sX POST -H "Accept: application/vnd.github.v3+json" -H "Authorization: token ${GH_TOKEN}" ${REG_URL} | jq .token --raw-output)

# Configuration
cd /home/docker/actions-runner

./config.sh --unattended --url https://github.com/${GH_FULL} --token ${REG_TOKEN} --name ${RUNNER_NAME}

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!
