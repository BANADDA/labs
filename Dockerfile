# Multi-stage build for Transformer Lab + VS Code Server
FROM ubuntu:22.04 as base

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

# Create a non-root user
RUN useradd -m -s /bin/bash -u 1000 coder && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to the coder user
USER coder
WORKDIR /home/coder

# Set up environment variables matching your install script
ENV ENV_NAME="transformerlab"
ENV TLAB_DIR="/home/coder/.transformerlab"
ENV TLAB_CODE_DIR="${TLAB_DIR}/src"
ENV TLAB_STATIC_WEB_DIR="${TLAB_DIR}/webapp"
ENV MINIFORGE_ROOT="${TLAB_DIR}/miniforge3"
ENV CONDA_BIN="${MINIFORGE_ROOT}/bin/conda"
ENV MAMBA_BIN="${MINIFORGE_ROOT}/bin/mamba"
ENV ENV_DIR="${TLAB_DIR}/envs/${ENV_NAME}"

# Copy the install script
COPY --chown=coder:coder install.sh /home/coder/install.sh
RUN chmod +x /home/coder/install.sh

# Install Transformer Lab components
RUN /home/coder/install.sh download_transformer_lab
RUN /home/coder/install.sh install_conda
RUN /home/coder/install.sh create_conda_environment
RUN /home/coder/install.sh install_dependencies

# Install VS Code Server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Create workspace directory
RUN mkdir -p /home/coder/workspace

# Copy configuration files
COPY --chown=coder:coder entrypoint.sh /home/coder/entrypoint.sh
RUN chmod +x /home/coder/entrypoint.sh

# Expose ports
EXPOSE 8080 8000 8443

# Set the entrypoint
ENTRYPOINT ["/home/coder/entrypoint.sh"]
CMD ["both"]
