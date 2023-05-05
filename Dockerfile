FROM ubuntu:23.04

# Environment and labels
ENV RUNNER_VERSION=2.303.0
ENV DEBIAN_FRONTEND=noninteractive

LABEL RUNNER_VERSION=${RUNNER_VERSION}

# Packages, users
RUN apt-get update -y && apt-get upgrade -y && useradd -m docker
RUN apt-get install -y --no-install-recommends \
    curl wget unzip vim git jq podman build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip

# Install actions runner
RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Install deps
RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

ADD run.sh run.sh
RUN chmod +x run.sh

# OCP friendly
USER 1001
ENTRYPOINT ["./run.sh"]