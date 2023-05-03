FROM ubuntu

USER root
RUN apt update
RUN apt install -y \
  curl \
  wget \
  podman

# Get oc bin
WORKDIR /tmp
RUN wget -qO- https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz | tar -xvzf -

RUN mv oc /usr/local/bin
RUN mv kubectl /usr/local/bin

WORKDIR /

# OCP friendly
USER 1001