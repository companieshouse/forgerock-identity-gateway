# The ig-base Docker image is create in Concourse 
# using the ForgeRock IG Dockerfile
FROM ig-base

COPY --chown=forgerock:root . /var/ig

ENTRYPOINT [ "/var/ig/run-ig.sh" ]