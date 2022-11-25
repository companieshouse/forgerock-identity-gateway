# The ig-base Docker image is create in Concourse 
# using the ForgeRock IG Dockerfile
ARG DOCKER_IMAGE=ig-base
FROM ${DOCKER_IMAGE}

ENV IG_JVM_ARGS=${IG_JVM_ARGS}
ENV ROOT_LOG_LEVEL=${ROOT_LOG_LEVEL}
COPY --chown=forgerock:root . /var/ig

ENTRYPOINT [ "/opt/ig/bin/start.sh", "/var/ig" ]