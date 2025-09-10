# Transformer Lab Container v1.0.1 - With Cloudflare Auto-Tunnel
FROM ubuntu:22.04

# Version and build info
LABEL version="1.0.1"
LABEL description="Transformer Lab with automatic Cloudflare tunnel support"
LABEL maintainer="BANADDA"

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    sudo \
    openssh-client \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user similar to LinuxServer's 'abc' user
ARG PUID=1000
ARG PGID=1000
RUN groupadd -g ${PGID} abc && \
    useradd -m -s /bin/bash -u ${PUID} -g abc abc && \
    echo "abc ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to the abc user
USER abc
WORKDIR /home/abc

# Set up environment variables matching your install script
ENV ENV_NAME="transformerlab"
ENV TLAB_DIR="/home/abc/.transformerlab"
ENV TLAB_CODE_DIR="${TLAB_DIR}/src"
ENV TLAB_STATIC_WEB_DIR="${TLAB_DIR}/webapp"
ENV MINIFORGE_ROOT="${TLAB_DIR}/miniforge3"
ENV CONDA_BIN="${MINIFORGE_ROOT}/bin/conda"
ENV MAMBA_BIN="${MINIFORGE_ROOT}/bin/mamba"
ENV ENV_DIR="${TLAB_DIR}/envs/${ENV_NAME}"

# Copy the install script
COPY --chown=abc:abc install.sh /home/abc/install.sh
RUN chmod +x /home/abc/install.sh

# Install Transformer Lab components
RUN /home/abc/install.sh download_transformer_lab
RUN /home/abc/install.sh install_conda
RUN /home/abc/install.sh create_conda_environment
RUN /home/abc/install.sh install_dependencies

# Switch to root to create directories with proper permissions
USER root
# Cache bust: 2025-01-12-v1
RUN mkdir -p /home/abc/workspace /config && \
    chown -R abc:abc /home/abc/workspace /config

# Switch back to abc user
USER abc
RUN ln -s /config /home/abc/.transformerlab-config

# Copy configuration files
COPY --chown=abc:abc entrypoint.sh /home/abc/entrypoint.sh
RUN chmod +x /home/abc/entrypoint.sh

# Expose Transformer Lab port
EXPOSE 8000

# Set the entrypoint
ENTRYPOINT ["/home/abc/entrypoint.sh"]
CMD ["transformerlab"]
