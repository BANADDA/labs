# Transformer Lab Container

A containerized version of Transformer Lab for remote access via web browser, similar to LinuxServer containers.

## 🚀 Quick Start

### Using Docker Compose (Recommended)

```bash
# Clone your repository
git clone https://github.com/BANADDA/labs
cd labs

# Start the container
docker-compose up -d

# View logs
docker-compose logs -f
```

### Using Docker Run

```bash
# Run the pre-built container (recommended)
docker run -d \
  --name transformerlab \
  -p 9090:8338 \
  -v $(pwd)/workspace:/home/abc/workspace \
  -v $(pwd)/config:/config \
  -e PUID=1000 \
  -e PGID=1000 \
  ghcr.io/banadda/labs/transformerlab:latest
```

### Using Pre-built Image from GitHub

```bash
# Pull and run the latest image
docker run -d \
  --name transformerlab \
  -p 9090:8338 \
  -v $(pwd)/workspace:/home/abc/workspace \
  -v $(pwd)/config:/config \
  -e PUID=1000 \
  -e PGID=1000 \
  ghcr.io/banadda/labs/transformerlab:latest
```

## 🌐 Access Points

Once the container is running, you can access:

- **🧠 Transformer Lab Web UI**: http://localhost:9090
- **🌍 Remote Access**: http://your-server-ip:9090

## 🔧 Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PUID` | User ID for file permissions | `1000` |
| `PGID` | Group ID for file permissions | `1000` |
| `TZ` | Timezone | `Etc/UTC` |

### Volume Mounts

| Host Path | Container Path | Description |
|-----------|----------------|-------------|
| `./workspace` | `/home/abc/workspace` | Your development workspace |
| `./config` | `/config` | Transformer Lab configuration |
| `./models` | `/home/abc/.transformerlab/models` | AI models storage |

## 🎯 Remote Access Methods

### 1. Direct Access (Local/VPN)
Access directly via IP:port when you have network access to the host.

### 2. SSH Tunneling
```bash
# Forward ports through SSH
ssh -L 9090:localhost:9090 user@your-server
```

### 3. Reverse Proxy (Production)
Use nginx or Traefik for SSL termination and domain routing:

```bash
# Start with reverse proxy
docker-compose --profile proxy up -d
```

### 4. Cloud Deployment

#### GitHub Codespaces
Add `.devcontainer/devcontainer.json`:

```json
{
  "name": "Transformer Lab",
  "dockerComposeFile": "../docker-compose.yml",
  "service": "transformerlab",
  "workspaceFolder": "/home/abc/workspace",
  "forwardPorts": [9090],
  "postCreateCommand": "echo 'Container ready!'"
}
```

#### Railway/Render/DigitalOcean
Deploy directly from GitHub with automatic builds.

## 🛠️ Development

### Building Locally

```bash
# Build the image
docker build -t transformerlab .

# Run locally built image
docker run -d \
  --name transformerlab \
  -p 9090:8338 \
  -v $(pwd)/workspace:/home/abc/workspace \
  -v $(pwd)/config:/config \
  -e PUID=1000 \
  -e PGID=1000 \
  transformerlab
```

## 🔒 Security Considerations

1. **Firewall**: Ensure port 9090 is properly configured in your firewall/NSG
2. **Use HTTPS**: Configure SSL certificates for production via reverse proxy
3. **Network Access**: Restrict access to necessary IPs only
4. **Updates**: Regularly update the container image

## 🐛 Troubleshooting

### Container Won't Start
```bash
# Check logs
docker-compose logs transformerlab

# Check system resources
docker stats
```

### Can't Access Services
```bash
# Verify ports are exposed
docker port transformerlab

# Check if services are running inside container
docker exec transformerlab ps aux
```

### Permission Issues
```bash
# Fix ownership of mounted volumes
sudo chown -R 1000:1000 ./workspace ./config
```

## 📦 What's Included

- **Transformer Lab**: Complete ML workspace with conda environment
- **Web-based Interface**: Access via browser (no additional software needed)
- **Python 3.11**: With ML libraries (PyTorch, Transformers, etc.)
- **CUDA Support**: GPU acceleration (when available)
- **LinuxServer-style**: PUID/PGID support, persistent storage
- **Multi-architecture**: Supports AMD64 and ARM64

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `docker-compose up`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
