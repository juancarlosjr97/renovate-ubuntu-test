FROM docker.io/ubuntu:focal

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Build args
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ARG ARTIFACTORY_URL
ARG ARTIFACTORY_READUSER
ARG ARTIFACTORY_READPASSWORD
ARG POSTMAN_VERSION=1.0.8
ARG POSTMAN_SHA256=877357e02e138a916546fc4713645364d968d74521352457ec0a3a728f067a3d
ARG POSTMAN_TARFILE=postman-cli-${POSTMAN_VERSION}.tar.gz

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Postman CLI has the same system requirements as Postman:
#   - https://learning.postman.com/docs/postman-cli/postman-cli-installation/#system-requirements
#   - https://learning.postman.com/docs/getting-started/installation-and-updates/#installing-postman-on-linux
#
# And is only supported on:
#   - Ubuntu 14.04 and newer
#   - Fedora 24
#   - Debian 8 and newer
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ca-certificates required to install Postman CLI
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RUN apt-get update \
    && \
    # Install packages required for GitLab templates or Dockerfile
    apt-get install --quiet -y --no-install-recommends \
        ca-certificates=20211016ubuntu0.22.04.1 \
        curl=7.81.0-1ubuntu1.10 \
        jq=1.6-2.1ubuntu3 \
        wget=1.21.2-2ubuntu1 \
    && \
#     # Update Dockerfile packges to resolve vulnerabilities
#     apt-get install --quiet -y --no-install-recommends \
#         libpam-modules-bin=1.4.0-11ubuntu2.3 \
#         libpam-modules=1.4.0-11ubuntu2.3 \
#         libpam-runtime=1.4.0-11ubuntu2.3 \
#         libpam0g=1.4.0-11ubuntu2.3 \
#         libssl3=3.0.2-0ubuntu1.8 \
#         tar=1.34+dfsg-1ubuntu0.1.22.04.1 \
#     && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# https://learning.postman.com/docs/postman-cli/postman-cli-installation/#linux-installation
# Following the script from: curl -o- "https://dl-cli.pstmn.io/install/linux64.sh"
#
# wget --output-document postman-cli-1.0.8.tar.gz https://dl-cli.pstmn.io/download/latest/linux64
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ARG TMPDIR=/tmp/postman
ARG URL=https://dl-cli.pstmn.io/download/latest/linux64
RUN mkdir -p ${TMPDIR} && \
    wget --quiet --no-verbose \
         --user ${ARTIFACTORY_READUSER} \
         --password ${ARTIFACTORY_READPASSWORD} \
         -O ${TMPDIR}/${POSTMAN_TARFILE} \
         ${ARTIFACTORY_URL}/${POSTMAN_TARFILE} && \
    echo "${POSTMAN_SHA256} */${TMPDIR}/${POSTMAN_TARFILE}" | sha256sum -c - && \
    tar --directory ${TMPDIR} --extract --file ${TMPDIR}/${POSTMAN_TARFILE} && \
    mkdir -p /usr/local/bin && \
    eval install -m 0755 $TMPDIR/postman-cli /usr/local/bin/postman && \
    rm -rf ${TMPDIR}

RUN useradd --create-home --shell /bin/bash postman
USER postman
RUN postman --version
WORKDIR /home/postman
