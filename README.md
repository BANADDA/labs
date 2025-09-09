# Transformer Lab Container

A containerized version of Transformer Lab for remote access via web browser, similar to LinuxServer containers.

## 🚀 Quick Start

### Step 1: Pull the Image

```bash
docker pull ghcr.io/banadda/labs/transformerlab:latest
```

### Step 2: Create Directories

```bash
mkdir -p workspace config
```

### Step 3: Run the Container

```bash
docker run -d \
  --name transformerlab \
  -p 9090:8338 \
  -v $(pwd)/workspace:/home/abc/workspace \
  -v $(pwd)/config:/config \
  -e PUID=1000 \
  -e PGID=1000 \
  --restart unless-stopped \
  ghcr.io/banadda/labs/transformerlab:latest
```

### Step 4: Access Transformer Lab

Open your browser and go to:
- **Local**: http://localhost:9090
- **Remote**: http://your-server-ip:9090

### Step 5: Check Logs (Optional)

```bash
# View container logs
docker logs -f transformerlab

# Check container status
docker ps | grep transformerlab
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

## 🌍 Remote Access & Deployment

### SSH Tunneling
If you need to access a remote server securely:

```bash
# Forward port through SSH
ssh -L 9090:localhost:9090 user@your-server

# Then access via http://localhost:9090
```

### Firewall Configuration

**Ubuntu/Debian:**
```bash
sudo ufw allow 9090/tcp
```

**CentOS/RHEL:**
```bash
sudo firewall-cmd --add-port=9090/tcp --permanent
sudo firewall-cmd --reload
```

**Azure/AWS:**
- Add inbound rule for port 9090 in Network Security Group
- Allow TCP traffic from your IP or 0.0.0.0/0 (public access)

### Cloud Deployment

**Railway:**
1. Fork this repository
2. Connect to Railway
3. Deploy from GitHub
4. Access via provided URL

**DigitalOcean App Platform:**
1. Create new app from GitHub
2. Use Docker deployment
3. Set port to 8338
4. Deploy and access

## 🔧 Advanced Usage

### Using Different Ports

If port 9090 is busy, you can use any other port:

```bash
# Use port 8080 instead
docker run -d \
  --name transformerlab \
  -p 8080:8338 \
  -v $(pwd)/workspace:/home/abc/workspace \
  -v $(pwd)/config:/config \
  -e PUID=1000 \
  -e PGID=1000 \
  ghcr.io/banadda/labs/transformerlab:latest
```

### Using Docker Compose

Create a `docker-compose.yml` file:

```yaml
version: '3.8'
services:
  transformerlab:
    image: ghcr.io/banadda/labs/transformerlab:latest
    container_name: transformerlab
    ports:
      - "9090:8338"
    environment:
      - PUID=1000
      - PGID=1000
    volumes:
      - ./workspace:/home/abc/workspace
      - ./config:/config
    restart: unless-stopped
```

Then run:
```bash
docker-compose up -d
```

### Updating the Container

```bash
# Stop and remove old container
docker stop transformerlab
docker rm transformerlab

# Pull latest image
docker pull ghcr.io/banadda/labs/transformerlab:latest

# Run new container (your data in workspace/ and config/ is preserved)
docker run -d \
  --name transformerlab \
  -p 9090:8338 \
  -v $(pwd)/workspace:/home/abc/workspace \
  -v $(pwd)/config:/config \
  -e PUID=1000 \
  -e PGID=1000 \
  --restart unless-stopped \
  ghcr.io/banadda/labs/transformerlab:latest
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
