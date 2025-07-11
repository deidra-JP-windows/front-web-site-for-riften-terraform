# syntax=docker/dockerfile:1
FROM mcr.microsoft.com/devcontainers/python:1-3.12-bullseye

# Install Terraform
ENV TERRAFORM_VERSION=1.12.1
RUN apt-get update \
    && apt-get install -y wget unzip gnupg software-properties-common \
    && wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Verify installation
RUN terraform -version
