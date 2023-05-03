FROM ubuntu

USER root

# Tooling
RUN apt update
RUN apt install -y \
  curl \
  wget \
  podman \
  jq

# Get oc bin
WORKDIR /tmp
RUN wget -qO- https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz | tar -xvzf -

RUN mv oc /usr/local/bin
RUN mv kubectl /usr/local/bin

WORKDIR /

# User stuff
ENV UID=1000
ENV GID=0
ENV USERNAME="runner"

# Create our user and their home directory
RUN useradd -m $USERNAME -u $UID
# This is to mimic the OpenShift behaviour of adding the dynamic user to group 0.
RUN usermod -G 0 $USERNAME
ENV HOME /home/${USERNAME}
WORKDIR /home/${USERNAME}

# Override these when creating the container.
ENV GITHUB_PAT ""
ENV GITHUB_APP_ID ""
ENV GITHUB_APP_INSTALL_ID ""
ENV GITHUB_APP_PEM ""
ENV GITHUB_OWNER ""
ENV GITHUB_REPOSITORY ""
ENV RUNNER_WORKDIR /home/${USERNAME}/_work
ENV RUNNER_GROUP ""
ENV RUNNER_LABELS ""
ENV EPHEMERAL ""

# Allow group 0 to modify these /etc/ files since on openshift, the dynamically-assigned user is always part of group 0.
# Also see ./uid.sh for the usage of these permissions.
RUN chmod g+w /etc/passwd && \
    touch /etc/sub{g,u}id && \
    chmod -v ug+rw /etc/sub{g,u}id

COPY --chown=${USERNAME}:0 get-runner-release.sh ./
RUN ./get-runner-release.sh
RUN ./bin/installdependencies.sh

# Set permissions so that we can allow the openshift-generated container user to access home.
# https://docs.openshift.com/container-platform/3.3/creating_images/guidelines.html#openshift-container-platform-specific-guidelines
RUN chown -R ${USERNAME}:0 /home/${USERNAME}/ && \
    chgrp -R 0 /home/${USERNAME}/ && \
    chmod -R g=u /home/${USERNAME}/

COPY --chown=${USERNAME}:0 entrypoint.sh uid.sh register.sh get_github_app_token.sh ./

# OCP friendly
USER $UID

ENTRYPOINT ./entrypoint.sh