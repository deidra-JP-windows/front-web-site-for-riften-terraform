# syntax=docker/dockerfile:1
FROM python:3.12.11-alpine3.22

# Install Terraform
ARG PRODUCT=terraform
ARG TERRAFORM_VERSION=1.12.1
 
RUN apk add --update --no-cache bash git openssh && \
    apk add --update --virtual .deps --no-cache gnupg && \
    cd /tmp && \
    wget https://releases.hashicorp.com/${PRODUCT}/${TERRAFORM_VERSION}/${PRODUCT}_${TERRAFORM_VERSION}_linux_amd64.zip && \
    wget https://releases.hashicorp.com/${PRODUCT}/${TERRAFORM_VERSION}/${PRODUCT}_${TERRAFORM_VERSION}_SHA256SUMS && \
    wget https://releases.hashicorp.com/${PRODUCT}/${TERRAFORM_VERSION}/${PRODUCT}_${TERRAFORM_VERSION}_SHA256SUMS.sig && \
    wget -qO- https://www.hashicorp.com/.well-known/pgp-key.txt | gpg --import && \
    gpg --verify ${PRODUCT}_${TERRAFORM_VERSION}_SHA256SUMS.sig ${PRODUCT}_${TERRAFORM_VERSION}_SHA256SUMS && \
    grep ${PRODUCT}_${TERRAFORM_VERSION}_linux_amd64.zip ${PRODUCT}_${TERRAFORM_VERSION}_SHA256SUMS | sha256sum -c && \
    unzip /tmp/${PRODUCT}_${TERRAFORM_VERSION}_linux_amd64.zip -d /tmp && \
    mv /tmp/${PRODUCT} /usr/local/bin/${PRODUCT} && \
    rm -f /tmp/${PRODUCT}_${TERRAFORM_VERSION}_linux_amd64.zip ${PRODUCT}_${TERRAFORM_VERSION}_SHA256SUMS ${TERRAFORM_VERSION}/${PRODUCT}_${TERRAFORM_VERSION}_SHA256SUMS.sig && \
    apk del .deps

# Verify installation
RUN terraform -version
