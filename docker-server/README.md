# Docker Server Setup

A complete Docker server setup with reverse proxy options (CADDY and SWAG) based on LinuxServer.io images.

## 📁 File Structure

```
docker-server/
├── docker-compose.yml          # Main compose file with CADDY and SWAG examples
├── Dockerfile                  # Custom application Dockerfile
├── .env                       # Environment variables (copy and customize)
├── README.md                  # This file
├── CLOUDFLARE-SETUP.md        # Cloudflare-specific setup guide
├── config/
│   ├── caddy/
│   │   └── Caddyfile          # Caddy reverse proxy configuration
│   └── swag/                  # SWAG configuration (auto-generated)
├── data/
│   ├── caddy/                 # Caddy data persistence
│   └── postgres/              # Database data
├── site/
│   └── index.html             # Example static website
├── secrets/
│   └── db_password.txt        # Database password (change this!)
├── init-scripts/              # Database initialization scripts
└── logs/                      # Application logs
```

## 🚀 Quick Start

### 1. Prerequisites

On your Debian server, install Docker and Docker Compose:

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt install docker-compose-plugin -y

# Log out and back in, or run:
newgrp docker
```

### 2. Setup

1. Copy this folder to your Debian server
2. Customize the `.env` file with your settings
3. Change the database password in `secrets/db_password.txt`
4. Update domain names in `docker-compose.yml` and `config/caddy/Caddyfile`

### 3. Choose Your Proxy

#### Option A: CADDY (Recommended for beginners)
```bash
# Start only CADDY and related services
docker-compose up -d caddy webapp database
```

#### Option B: SWAG (More features, requires DNS setup)
```bash
# Configure DNS API credentials first (see SWAG setup below)
# Start SWAG and related services
docker-compose up -d swag webapp database
```

## 🔧 Configuration

### CADDY Setup

1. Edit `config/caddy/Caddyfile` with your domain names
2. Caddy automatically handles Let's Encrypt certificates
3. No DNS API setup required (uses HTTP challenge)

### SWAG Setup

1. Configure DNS provider credentials:
   ```bash
   # For Cloudflare, create: config/swag/dns-conf/cloudflare.ini
   dns_cloudflare_email = your-email@domain.com
   dns_cloudflare_api_key = your-api-key
   ```
2. Update environment variables in docker-compose.yml:
   - `URL`: Your domain
   - `DNSPLUGIN`: Your DNS provider
   - `EMAIL`: Your email for Let's Encrypt

### Database Setup

1. Change the password in `secrets/db_password.txt`
2. Database will be accessible only from other containers
3. Add initialization scripts to `init-scripts/` if needed

## 📋 Common Commands

```bash
# Start all services
docker-compose up -d

# Start specific services
docker-compose up -d caddy webapp

# View logs
docker-compose logs -f
docker-compose logs -f caddy

# Stop services
docker-compose down

# Restart a service
docker-compose restart caddy

# Check status
docker-compose ps

# Update images
docker-compose pull
docker-compose up -d
```

## 🔒 Security Considerations

1. **Change default passwords** in `secrets/db_password.txt`
2. **Update PUID/PGID** in `.env` to match your user
3. **Configure firewall** to only allow ports 80, 443, and SSH
4. **Regular updates**: Use Watchtower or manual updates
5. **Backup data**: Regularly backup `data/` and `config/` directories

## 🌐 DNS Configuration

Point your domain to your server's IP:

```
A    yourdomain.com        → YOUR_SERVER_IP
A    *.yourdomain.com      → YOUR_SERVER_IP  (for subdomains)
```

## 📖 Adding New Services

To add a new service:

1. Add it to `docker-compose.yml`
2. Configure reverse proxy in Caddyfile or SWAG
3. Add to appropriate network (`proxy-network` for web services)

Example:
```yaml
new-service:
  image: your-app:latest
  container_name: new-service
  expose:
    - "3000"
  networks:
    - proxy-network
```

## 🆘 Troubleshooting

### Common Issues

1. **Port conflicts**: Change ports in docker-compose.yml
2. **Permission issues**: Check PUID/PGID in .env
3. **Certificate errors**: Check domain DNS and Let's Encrypt logs
4. **Container won't start**: Check logs with `docker-compose logs SERVICE_NAME`

### Useful Debug Commands

```bash
# Check Docker status
docker info

# Test connectivity
docker-compose exec caddy ping webapp

# Check certificate status (CADDY)
docker-compose exec caddy caddy list-certificates

# Check SWAG certificates
docker-compose exec swag ls -la /config/keys/
```

## 📚 Resources

- [LinuxServer.io CADDY](https://docs.linuxserver.io/images/docker-caddy)
- [LinuxServer.io SWAG](https://docs.linuxserver.io/images/docker-swag)
- [Caddy Documentation](https://caddyserver.com/docs/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

## 📄 License

This setup is provided as-is for educational and development purposes.
