#!/bin/bash

# m.RMM Installation Script
set -e

echo "🚀 Installing m.RMM..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Create environment file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating environment file..."
    cp .env.mrmm .env
    echo "⚠️  Please edit .env file with your configuration before running 'make up'"
fi

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p data/postgres
mkdir -p data/redis
mkdir -p data/tactical
mkdir -p data/mesh
mkdir -p logs

# Set permissions
echo "🔒 Setting permissions..."
chmod 755 data
chmod 755 logs

echo "✅ m.RMM installation prepared!"
echo ""
echo "Next steps:"
echo "1. Edit .env file with your configuration"
echo "2. Run 'make up' to start all services"
echo "3. Run 'make migrate' to set up the database"
echo "4. Run 'make createsuperuser' to create an admin user"
echo ""
echo "For more commands, run 'make help'"
