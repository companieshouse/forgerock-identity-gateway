# The ig-base Docker image is create in Concourse 
# using the ForgeRock IG Dockerfile
ARG DOCKER_IMAGE=ig-base
FROM ${DOCKER_IMAGE}

COPY --chown=forgerock:root . /var/ig

ENTRYPOINT [ "/opt/ig/bin/start.sh", "/var/ig" ]