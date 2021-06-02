# ForgeRock Identity Gateway

This repository contains infrastructure script and configuration for deploying ForgeRock Identity Gateway in AWS. All scripts are deployed as part of the CI/CD pipeline but can also be ran locally.

## Running Locally

### Pre-Requisites

The following need to be installed/configured for local use:

- [Docker](https://www.docker.com/products/docker-desktop)
- [AWS CLI](https://aws.amazon.com/cli/)
- [yawsso](https://pypi.org/project/yawsso/)
- [Terraform Runner](https://companieshouse.atlassian.net/wiki/spaces/DEVOPS/pages/1694236886/Terraform-runner)

### WebFiling Identity Gateway

A base IG Docker image is required in order to build the WebFiling image. This can retrieved from AWS or built locally.

**Using AWS Image**
```
# Navigate to the directory
cd webfiling

# Configure AWS CLI
export AWS_PROFILE=development-eu-west-2
aws-sso-login
yawsso

# Login to container registry
aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin {REPLACE_WITH_ECR_URL}

# Build and run IG Docker image
docker build -t webfiling-ig --build-arg DOCKER_IMAGE={REPLACE_WITH_ECR_URL}:ig-base .
docker run --rm -d --name webfiling-ig -e APPLICATION_HOST={REPLACE_WITH_EWF_HOSTNAME} -p 8080:8080 webfiling-ig
```

**Using Local Image**
```
# Download the IG zip file for ForgeRock downloads page
# https://backstage.forgerock.com/downloads/browse/ig/featured

# Extract files
unzip IG-7.0.2.zip

# Build the ig-base image
cd identity-gateway
docker build -t ig-base -f docker/Dockerfile .

# Build and run IG Docker image
# Run these commands in the webfiling directory
docker build -t webfiling-ig .
docker run --rm -it --name webfiling-ig -e APPLICATION_HOST={REPLACE_WITH_EWF_HOSTNAME} \
-e OIDC_CLIENT_ID={REPLACE_WITH_OIDC_CLIENT_ID} \
-e OIDC_CLIENT_SECRET={REPLACE_WITH_OIDC_CLIENT_SECRET} \
-e FIDC_REALM=alpha \
-e AM_HOST={REPLACE_WITH_AM_HOSTNAME} \
-p 8080:8080 webfiling-ig
```

### Terraform

Terraform variables can be provided while running the `terraform-runner` CLI or a local file can be created to store them. Create a file called `local.auto.tfvars` in the `terraform/groups/identity-gateway` directory.

**Example local.auto.tfvars**
```
ecr_url                  = "{REPLACE_WITH_ECR_URL}"
container_image_version  = "webfiling-1.0.0"
```

The `terraform-runner` can be ran from the root of the project using the following commands:
```
# Check the Terraform plan output
terraform-runner -g identity-gateway -p development-eu-west-2 -e development -t terraform -c plan

# Apply changes to the account
terraform-runner -g identity-gateway -p development-eu-west-2 -e development -t terraform -c apply
```