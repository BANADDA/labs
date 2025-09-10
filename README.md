# Transformer Lab Container v1.0.1

A containerized version of Transformer Lab with **automatic Cloudflare tunnel support** for instant global HTTPS access, similar to LinuxServer containers.

## 🆕 **New in v1.0.1:**
- ✅ **Auto-detects cloudflared** on host system
- ✅ **Automatically creates Cloudflare tunnel** if available
- ✅ **Displays HTTPS URL** in container logs
- ✅ **Falls back to local access** if no cloudflared
- ✅ **Zero configuration** - just run and get a link!

## 🚀 Quick Start

### Step 1: Pull the Image

```bash
docker pull ghcr.io/bigideaafrica/labs:latest
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
  ghcr.io/bigideaafrica/labs:latest
```

### Step 4: Access Transformer Lab

**🎉 NEW: Automatic Cloudflare Tunnel (v1.0.1)**

If you have `cloudflared` installed on your host:
1. The container will **automatically detect** it
2. **Create a Cloudflare tunnel** 
3. **Display the HTTPS URL** in the logs like:
   ```
   🎉 Cloudflare Tunnel Created!
   🌍 Global Access URL: https://amazing-example-url.trycloudflare.com
   ```

**Fallback: Local/Direct Access**
- **Local**: http://localhost:9090  
- **Remote**: http://your-server-ip:9090 (requires firewall configuration)

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

### Cloudflare Tunnel (Recommended for Public Access)

Get a secure HTTPS URL without port forwarding or firewall changes:

**Step 1: Install Cloudflared**
```bash
# Download and install cloudflared
curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared.deb
```

**Step 2: Login to Cloudflare**
```bash
cloudflared tunnel login
```

**Step 3: Create a Tunnel**
```bash
# Create tunnel
cloudflared tunnel create transformerlab

# Create config file
mkdir -p ~/.cloudflared
cat > ~/.cloudflared/config.yml << EOF
tunnel: transformerlab
credentials-file: /home/$(whoami)/.cloudflared/transformerlab.json

ingress:
  - hostname: transformerlab.yourdomain.com
    service: http://localhost:9090
  - service: http_status:404
EOF
```

**Step 4: Add DNS Record**
```bash
# Point your domain to the tunnel
cloudflared tunnel route dns transformerlab transformerlab.yourdomain.com
```

**Step 5: Run the Tunnel**
```bash
# Start tunnel (run in background)
cloudflared tunnel --config ~/.cloudflared/config.yml run &
```

**Result:** Access your Transformer Lab at `https://transformerlab.yourdomain.com` 🎉

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
  ghcr.io/bigideaafrica/labs:latest
```

### Using Docker Compose

Create a `docker-compose.yml` file:

```yaml
version: '3.8'
services:
  transformerlab:
    image: ghcr.io/bigideaafrica/labs:latest
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
docker pull ghcr.io/bigideaafrica/labs:latest

# Run new container (your data in workspace/ and config/ is preserved)
docker run -d \
  --name transformerlab \
  -p 9090:8338 \
  -v $(pwd)/workspace:/home/abc/workspace \
  -v $(pwd)/config:/config \
  -e PUID=1000 \
  -e PGID=1000 \
  --restart unless-stopped \
  ghcr.io/bigideaafrica/labs:latest
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
