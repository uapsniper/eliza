# ElizaOS Twitter Agent Deployment Guide

This guide will help you deploy ElizaOS with PostgreSQL on DigitalOcean for running Twitter agents.

## Prerequisites

1. DigitalOcean account
2. Domain name (optional, recommended for production)
3. OpenAI API key
4. Twitter Developer accounts for each agent (up to 10)

## Step 1: Set up a DigitalOcean Droplet

1. Create a new Droplet:
   - Choose Ubuntu 22.04
   - Select a plan with at least 4GB RAM and 2 vCPUs
   - Choose a datacenter region closest to your target audience
   - Add your SSH key for secure access
   - Click "Create Droplet"

2. Log in to your droplet:
   ```bash
   ssh root@your-droplet-ip
   ```

## Step 2: Deploy ElizaOS

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/eliza.git
   cd eliza
   ```

2. Copy the environment template:
   ```bash
   cp .env.template .env
   ```

3. Edit the `.env` file with your configuration:
   ```bash
   nano .env
   ```
   - Set `OPENAI_API_KEY`
   - Update PostgreSQL credentials
   - Add Twitter API credentials for each agent
   - Generate strong secrets for `JWT_SECRET` and `SESSION_SECRET`

4. Make the deployment script executable and run it:
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

## Step 3: Configure Twitter Agents

1. Access the ElizaOS web interface at `http://your-droplet-ip:3000`
2. Log in with the default credentials
3. Navigate to the Agents section
4. For each Twitter account:
   - Click "Add Agent"
   - Enter agent details (name, personality, etc.)
   - Configure Twitter API credentials
   - Set up agent behavior and response patterns
   - Save the configuration

## Step 4: Secure Your Deployment (Recommended)

1. **Set up a firewall**:
   ```bash
   sudo ufw allow OpenSSH
   sudo ufw allow http
   sudo ufw allow https
   sudo ufw enable
   ```

2. **Set up HTTPS** (using Nginx and Let's Encrypt):
   ```bash
   # Install Nginx
   sudo apt install nginx
   sudo systemctl enable nginx
   
   # Install Certbot
   sudo apt install certbot python3-certbot-nginx
   sudo certbot --nginx -d yourdomain.com
   ```

3. **Set up automatic updates**:
   ```bash
   sudo apt install unattended-upgrades
   sudo dpkg-reconfigure -plow unattended-upgrades
   ```

## Step 5: Monitor Your Agents

1. Access logs:
   ```bash
   docker-compose logs -f
   ```

2. Monitor resource usage:
   ```bash
   docker stats
   ```

3. Set up monitoring (optional):
   - Use DigitalOcean's built-in monitoring
   - Or set up Prometheus and Grafana

## Maintenance

### Backups

1. Set up regular database backups:
   ```bash
   # Create a backup script
   echo '#!/bin/bash
   docker-compose exec -T postgres pg_dump -U $POSTGRES_USER $POSTGRES_DB > backup_$(date +%Y%m%d).sql' > backup.sh
   chmod +x backup.sh
   ```

2. Schedule daily backups:
   ```bash
   (crontab -l 2>/dev/null; echo "0 3 * * * /path/to/eliza/backup.sh") | crontab -
   ```

### Updates

To update ElizaOS:

```bash
cd /path/to/eliza
git pull
docker-compose down
docker-compose pull
docker-compose up -d --build
```

## Troubleshooting

### Common Issues

1. **Agents not responding**
   - Check logs: `docker-compose logs elizaos`
   - Verify Twitter API credentials
   - Check rate limits

2. **Database connection issues**
   - Verify PostgreSQL is running: `docker-compose ps`
   - Check logs: `docker-compose logs postgres`
   - Verify credentials in `.env` file

3. **High resource usage**
   - Monitor with `htop` or `docker stats`
   - Consider upgrading your droplet
   - Check for memory leaks in custom plugins

## Support

For additional help, please refer to the [ElizaOS Documentation](https://docs.elizaos.ai) or open an issue on GitHub.
