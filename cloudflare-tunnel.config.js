module.exports = {
  apps: [{
    name: 'transformerlab-tunnel',
    script: 'cloudflared',
    args: 'tunnel --url http://localhost:9090',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production'
    }
  }]
}
