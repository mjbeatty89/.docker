# Cloudflare Setup Guide

Since you're using Cloudflare for DNS, here are the specific configurations and considerations for your Docker server setup.

## 🌩️ Cloudflare Configuration

### DNS Records Setup

In your Cloudflare dashboard, create these DNS records:

```
Type    Name                Value               Proxy Status
A       yourdomain.com      YOUR_SERVER_IP      Orange (Proxied)
A       *.yourdomain.com    YOUR_SERVER_IP      Orange (Proxied)
```

**Important**: You can choose between:
- **Proxied (Orange Cloud)**: Traffic goes through Cloudflare (CDN, DDoS protection, SSL)
- **DNS Only (Grey Cloud)**: Direct connection to your server

## 🔑 API Credentials Setup

### Option 1: API Token (Recommended)

1. Go to [Cloudflare API Tokens](https://dash.cloudflare.com/profile/api-tokens)
2. Click "Create Token"
3. Use "Custom token" template
4. Configure:
   - **Token name**: `Docker-SWAG-LetsEncrypt`
   - **Permissions**:
     - Zone : Zone : Read
     - Zone : DNS : Edit
   - **Zone Resources**: Include your domain
5. Copy the token and add it to `config/cloudflare/cloudflare.ini`:
   ```ini
   dns_cloudflare_api_token = your_token_here
   ```

### Option 2: Global API Key (Less Secure)

1. Go to [Cloudflare API](https://dash.cloudflare.com/profile/api-tokens)
2. Find "Global API Key" and click "View"
3. Add to `config/cloudflare/cloudflare.ini`:
   ```ini
   dns_cloudflare_email = your-email@domain.com
   dns_cloudflare_api_key = your_global_api_key
   ```

## 🐳 Docker Configuration

### SWAG with Cloudflare

SWAG is pre-configured for Cloudflare DNS validation. Just:

1. Edit `config/cloudflare/cloudflare.ini` with your credentials
2. Update `docker-compose.yml` with your domain:
   ```yaml
   environment:
     - URL=yourdomain.com
     - EMAIL=your-email@domain.com
   ```

### Caddy with Cloudflare (Optional)

If you prefer Caddy and want DNS challenge:

1. Add Cloudflare API token to `.env`:
   ```bash
   CLOUDFLARE_API_TOKEN=your_token_here
   ```

2. Uncomment DNS challenge in `config/caddy/Caddyfile`:
   ```caddyfile
   {
       acme_dns cloudflare {env.CLOUDFLARE_API_TOKEN}
       email your-email@domain.com
   }
   ```

3. Update docker-compose.yml to pass the environment variable:
   ```yaml
   caddy:
     environment:
       - CLOUDFLARE_API_TOKEN=${CLOUDFLARE_API_TOKEN}
   ```

## 🔄 SSL/TLS Settings

### With Cloudflare Proxy (Orange Cloud)

**Cloudflare SSL/TLS Mode: `Full (strict)`**

- Cloudflare handles SSL termination
- Your server still needs valid certificates
- SWAG/Caddy will get Let's Encrypt certificates
- Traffic: Browser → Cloudflare (HTTPS) → Your Server (HTTPS)

### Without Cloudflare Proxy (Grey Cloud)

**Direct connection to your server**

- Let's Encrypt certificates directly serve clients
- Traffic: Browser → Your Server (HTTPS)
- Simpler setup, but no Cloudflare protection

## 🛡️ Security Considerations

### Firewall Rules

With Cloudflare proxy, you can restrict access to Cloudflare IPs only:

```bash
# Allow Cloudflare IPs only (if using proxy)
# Update these ranges as needed from https://www.cloudflare.com/ips/
sudo ufw allow from 173.245.48.0/20 to any port 80
sudo ufw allow from 103.21.244.0/22 to any port 80
sudo ufw allow from 173.245.48.0/20 to any port 443
sudo ufw allow from 103.21.244.0/22 to any port 443
# ... add all Cloudflare IP ranges

# Or allow all (simpler but less secure)
sudo ufw allow 80
sudo ufw allow 443
```

### Real Visitor IPs

When using Cloudflare proxy, enable real IP restoration:

**For Caddy:**
```caddyfile
yourdomain.com {
    trusted_proxies cloudflare
    # ... rest of config
}
```

**For SWAG (Nginx):**
Add to your nginx config:
```nginx
real_ip_header CF-Connecting-IP;
set_real_ip_from 0.0.0.0/0;
```

## 🚀 Quick Start Commands

### Using SWAG (Recommended for Cloudflare)

```bash
# 1. Configure Cloudflare credentials
nano config/cloudflare/cloudflare.ini

# 2. Update domain in docker-compose.yml
nano docker-compose.yml

# 3. Start services
docker-compose up -d swag webapp database
```

### Using Caddy

```bash
# 1. Update Caddyfile with your domain
nano config/caddy/Caddyfile

# 2. Start services  
docker-compose up -d caddy webapp database
```

## 🔍 Troubleshooting

### Common Issues

1. **Certificate errors with proxy enabled**
   - Ensure Cloudflare SSL mode is "Full (strict)"
   - Check that your server has valid certificates

2. **DNS validation failing**
   - Verify API token has correct permissions
   - Check token isn't expired
   - Ensure domain is added to your Cloudflare account

3. **Real IP not showing**
   - Configure trusted proxies in your reverse proxy
   - Check Cloudflare IP ranges are up to date

### Debug Commands

```bash
# Check SWAG logs for certificate issues
docker-compose logs -f swag

# Test DNS resolution
dig yourdomain.com

# Check Cloudflare API access
curl -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
     -H "Authorization: Bearer YOUR_API_TOKEN" \
     -H "Content-Type:application/json"
```

## 📚 Additional Resources

- [Cloudflare SSL/TLS Settings](https://developers.cloudflare.com/ssl/origin-configuration/ssl-modes/)
- [Cloudflare API Documentation](https://developers.cloudflare.com/api/)
- [SWAG Documentation](https://docs.linuxserver.io/images/docker-swag)
- [Caddy Cloudflare Plugin](https://github.com/caddy-dns/cloudflare)
