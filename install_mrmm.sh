#!/bin/bash

# m.RMM Installation Script
set -e

echo "🚀 Installing m.RMM..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    echo "Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    echo "Visit: https://docs.docker.com/compose/install/"
    exit 1
fi

print_step "Prerequisites Check Complete"

# Create environment file if it doesn't exist
if [ ! -f .env ]; then
    print_status "Creating environment file..."
    cp .env.mrmm .env
    print_warning "Please edit .env file with your configuration before running 'make up'"
else
    print_status "Environment file already exists"
fi

# Create necessary directories
print_status "Creating directories..."
mkdir -p data/postgres
mkdir -p data/redis
mkdir -p data/tactical
mkdir -p data/mesh
mkdir -p data/jetstream
mkdir -p logs
mkdir -p configs

# Set permissions
print_status "Setting permissions..."
chmod 755 data
chmod 755 logs
chmod 755 configs

# Create configs if they don't exist
if [ ! -f configs/nats-server.conf ]; then
    print_status "Creating NATS configuration..."
    cat > configs/nats-server.conf << 'EOF'
# m.RMM NATS Server Configuration
port: 4222
http_port: 8222

# JetStream
jetstream {
    store_dir: "/data/jetstream"
    max_memory_store: 1GB
    max_file_store: 10GB
}

# Authentication
authorization {
    user: "mrmm"
    password: "change_me_in_production"
}

# Logging
log_time: true
debug: false
trace: false
logfile: "/var/log/nats-server.log"

# Limits
max_connections: 1000
max_payload: 1MB
EOF
fi

# Generate secrets if needed
print_status "Generating secure secrets..."
if ! grep -q "your_secure_password_here" .env 2>/dev/null; then
    # Generate random passwords
    POSTGRES_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
    SECRET_KEY=$(openssl rand -base64 50 | tr -d "=+/" | cut -c1-50)
    
    # Update .env file
    sed -i "s/your_secure_password_here/$POSTGRES_PASSWORD/g" .env
    sed -i "s/your_django_secret_key_here/$SECRET_KEY/g" .env
    
    print_status "Generated secure passwords and updated .env file"
fi

# Create docker-compose override for development if needed
if [ ! -f docker-compose.dev.yml ]; then
    print_status "Creating development override..."
    cat > docker-compose.dev.yml << 'EOF'
version: '3.8'

services:
  api:
    environment:
      - DEBUG=1
      - DJANGO_DEBUG=True
    volumes:
      - ./tacticalrmm/api:/opt/tactical/api
    ports:
      - "8000:8000"

  frontend:
    volumes:
      - ./tacticalrmm-web:/app
    ports:
      - "8080:8080"
    command: npm run serve

  postgres:
    ports:
      - "5432:5432"

  redis:
    ports:
      - "6379:6379"
EOF
fi

print_step "✅ m.RMM installation prepared!"

echo ""
echo "📋 Installation Summary:"
echo "  ✅ Docker and Docker Compose verified"
echo "  ✅ Directory structure created"
echo "  ✅ Environment file configured"
echo "  ✅ NATS configuration created"
echo "  ✅ Development override created"
echo ""
echo "🚀 Next Steps:"
echo "  1. Edit .env file with your domain and configuration:"
echo "     ${YELLOW}nano .env${NC}"
echo ""
echo "  2. Start all services:"
echo "     ${GREEN}make up${NC}"
echo ""
echo "  3. Initialize the database:"
echo "     ${GREEN}make migrate${NC}"
echo ""
echo "  4. Create an admin user:"
echo "     ${GREEN}make createsuperuser${NC}"
echo ""
echo "  5. Access m.RMM:"
echo "     ${BLUE}https://your-domain.com${NC} (web interface)"
echo "     ${BLUE}https://api.your-domain.com${NC} (API)"
echo "     ${BLUE}https://mesh.your-domain.com${NC} (remote control)"
echo ""
echo "📚 For more commands, run:"
echo "     ${GREEN}make help${NC}"
echo ""
print_warning "Important Security Notes:"
print_warning "  - Change default passwords in .env before production use"
print_warning "  - Configure SSL certificates for production"
print_warning "  - Set up proper firewall rules"
print_warning "  - Review all security settings in .env"
echo ""
echo "🎉 Happy managing with m.RMM!"