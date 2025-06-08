#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting ElizaOS deployment...${NC}"

# Check if .env exists
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}Creating .env file from template...${NC}"
    cp .env.template .env
    echo -e "${GREEN}Please edit the .env file with your configuration and run this script again.${NC}"
    exit 1
fi

# Load environment variables
set -a
source .env
set +a

# Install required packages
echo -e "${YELLOW}Installing required packages...${NC}"
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common

# Install Docker
echo -e "${YELLOW}Installing Docker...${NC}"
if ! command -v docker &> /dev/null; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo \
        "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER
fi

# Install Docker Compose
echo -e "${YELLOW}Installing Docker Compose...${NC}"
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Create data directory for persistent storage
echo -e "${YELLOW}Setting up data directories...${NC}"
mkdir -p data/pgdata

# Set proper permissions
sudo chown -R 1000:1000 data/

# Start services
echo -e "${YELLOW}Starting services with Docker Compose...${NC}
docker-compose up -d

echo -e "\n${GREEN}Deployment complete!${NC}"
echo -e "${GREEN}ElizaOS is now running on http://localhost:3000${NC}"
echo -e "${GREEN}pgAdmin is available at http://localhost:5050${NC}"
echo -e "\n${YELLOW}Note:${NC} It may take a few minutes for all services to start up completely.\n"
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Access the web interface at http://your-server-ip:3000"
echo "2. Log in with the default credentials"
echo "3. Configure your Twitter agents in the admin panel"

# Show container status
echo -e "\n${YELLOW}Container status:${NC}"
docker-compose ps
