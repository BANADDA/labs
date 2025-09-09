# Transformer Lab Container

A containerized version of Transformer Lab with integrated VS Code Server for remote development.

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
# Build the image
docker build -t transformerlab .

# Run the container
docker run -d \
  --name transformerlab \
  -p 8000:8000 \
  -p 8080:8080 \
  -v $(pwd)/workspace:/home/coder/workspace \
  -v $(pwd)/data:/home/coder/.transformerlab \
  -e CODE_SERVER_PASSWORD=your-password \
  transformerlab
```

### Using Pre-built Image from GitHub

```bash
# Pull and run the latest image
docker run -d \
  --name transformerlab \
  -p 8000:8000 \
  -p 8080:8080 \
  -v $(pwd)/workspace:/home/coder/workspace \
  ghcr.io/yourusername/transformerlab:latest
```

## 🌐 Access Points

Once the container is running, you can access:

- **🧠 Transformer Lab**: http://localhost:8000
- **💻 VS Code Server**: http://localhost:8080
- **🔑 Default Password**: `transformerlab` (change via `CODE_SERVER_PASSWORD`)

## 🔧 Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `CODE_SERVER_PASSWORD` | Password for VS Code Server | `transformerlab` |
| `CODE_SERVER_AUTH` | Authentication method | `password` |
| `PUID` | User ID for file permissions | `1000` |
| `PGID` | Group ID for file permissions | `1000` |

### Volume Mounts

| Host Path | Container Path | Description |
|-----------|----------------|-------------|
| `./workspace` | `/home/coder/workspace` | Your development workspace |
| `./data` | `/home/coder/.transformerlab` | Transformer Lab data & models |
| `./vscode-config` | `/home/coder/.config/code-server` | VS Code Server configuration |

## 🎯 Remote Access Methods

### 1. Direct Access (Local/VPN)
Access directly via IP:port when you have network access to the host.

### 2. SSH Tunneling
```bash
# Forward ports through SSH
ssh -L 8080:localhost:8080 -L 8000:localhost:8000 user@your-server
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
  "workspaceFolder": "/home/coder/workspace",
  "forwardPorts": [8000, 8080],
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

# Or with build args
docker build \
  --build-arg CODE_SERVER_VERSION=4.103.2 \
  -t transformerlab .
```

### Running Different Modes

```bash
# Only Transformer Lab
docker run -p 8000:8000 transformerlab transformerlab

# Only VS Code Server
docker run -p 8080:8080 transformerlab code-server

# Both (default)
docker run -p 8000:8000 -p 8080:8080 transformerlab both
```

## 🔒 Security Considerations

1. **Change Default Password**: Always set `CODE_SERVER_PASSWORD`
2. **Use HTTPS**: Configure SSL certificates for production
3. **Firewall**: Restrict access to necessary IPs only
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
sudo chown -R 1000:1000 ./workspace ./data
```

## 📦 What's Included

- **Transformer Lab**: Complete ML workspace with conda environment
- **VS Code Server**: Web-based VS Code for remote development
- **Python 3.11**: With ML libraries (PyTorch, Transformers, etc.)
- **CUDA Support**: GPU acceleration (when available)
- **Git Integration**: Pre-configured for development workflows

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `docker-compose up`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
