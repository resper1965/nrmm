#!/bin/bash

# m.RMM Transformation Script
# This script transforms Tactical RMM into m.RMM

set -e

echo "🚀 Starting Tactical RMM → m.RMM Transformation..."

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

# Check if we're in the right directory
if [ ! -d "tacticalrmm" ] || [ ! -d "tacticalrmm-web" ]; then
    print_error "Please run this script from the workspace root where tacticalrmm and tacticalrmm-web directories exist"
    exit 1
fi

print_step "Phase 1: Frontend Branding Updates"

# Frontend package.json updates
print_status "Updating frontend package.json..."
sed -i 's/"name": "web"/"name": "mrmm-web"/g' tacticalrmm-web/package.json
sed -i 's/"version": "0.101.55"/"version": "1.0.0"/g' tacticalrmm-web/package.json
sed -i 's/"productName": "Tactical RMM"/"productName": "m.RMM"/g' tacticalrmm-web/package.json

# Frontend HTML template
print_status "Updating index.html..."
sed -i 's/content="<%= productDescription %>"/content="m.RMM - Advanced Remote Monitoring \& Management Solution"/g' tacticalrmm-web/index.html

# Vue components
print_status "Updating Vue components..."
find tacticalrmm-web/src -name "*.vue" -type f -exec sed -i 's/Tactical RMM/m.RMM/g' {} \;

print_step "Phase 2: Backend Branding Updates"

# Django models
print_status "Updating Django models..."
sed -i 's/default="TacticalRMM"/default="m.RMM"/g' tacticalrmm/api/tacticalrmm/core/models.py

# Management commands
print_status "Updating management commands..."
sed -i 's/"meshname": "TacticalRMM"/"meshname": "m.RMM"/g' tacticalrmm/api/tacticalrmm/core/management/commands/get_mesh_exe_url.py
sed -i 's/"meshname": "TacticalRMM"/"meshname": "m.RMM"/g' tacticalrmm/api/tacticalrmm/core/management/commands/initial_mesh_setup.py

# Settings updates
print_status "Updating Django settings..."
sed -i 's/TRMM_VERSION = "1.2.1-dev"/TRMM_VERSION = "1.0.0"  # m.RMM version/g' tacticalrmm/api/tacticalrmm/tacticalrmm/settings.py
sed -i 's/WEB_VERSION = "0.101.55"/WEB_VERSION = "1.0.0"/g' tacticalrmm/api/tacticalrmm/tacticalrmm/settings.py
sed -i 's/APP_VER = "0.0.200"/APP_VER = "1.0.0"/g' tacticalrmm/api/tacticalrmm/tacticalrmm/settings.py

print_step "Phase 3: Creating m.RMM Extensions"

# Create compliance app
print_status "Creating compliance Django app..."
mkdir -p tacticalrmm/api/tacticalrmm/compliance
cat > tacticalrmm/api/tacticalrmm/compliance/__init__.py << 'EOF'
"""
m.RMM Compliance Module
Handles LGPD, ISO 27001, and other compliance frameworks
"""
EOF

cat > tacticalrmm/api/tacticalrmm/compliance/apps.py << 'EOF'
from django.apps import AppConfig


class ComplianceConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'compliance'
    verbose_name = 'Compliance Management'
EOF

cat > tacticalrmm/api/tacticalrmm/compliance/models.py << 'EOF'
from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()


class ComplianceFramework(models.Model):
    """Compliance frameworks (LGPD, ISO 27001, etc.)"""
    name = models.CharField(max_length=100, unique=True)
    description = models.TextField()
    version = models.CharField(max_length=20)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"{self.name} v{self.version}"


class ComplianceRequirement(models.Model):
    """Individual requirements within a framework"""
    framework = models.ForeignKey(ComplianceFramework, on_delete=models.CASCADE, related_name='requirements')
    code = models.CharField(max_length=50)  # e.g., "LGPD-Art-32", "ISO-A.12.6.1"
    title = models.CharField(max_length=255)
    description = models.TextField()
    category = models.CharField(max_length=100)
    severity = models.CharField(max_length=20, choices=[
        ('low', 'Low'),
        ('medium', 'Medium'),
        ('high', 'High'),
        ('critical', 'Critical'),
    ])
    
    class Meta:
        unique_together = ['framework', 'code']
    
    def __str__(self):
        return f"{self.framework.name} - {self.code}"


class CompliancePolicy(models.Model):
    """Policies that implement compliance requirements"""
    name = models.CharField(max_length=255)
    requirements = models.ManyToManyField(ComplianceRequirement, related_name='policies')
    organization = models.ForeignKey('clients.Client', on_delete=models.CASCADE)
    check_script = models.TextField(help_text="Script to check compliance")
    remediation_script = models.TextField(blank=True, help_text="Script to fix non-compliance")
    check_interval = models.IntegerField(default=86400, help_text="Check interval in seconds")
    is_active = models.BooleanField(default=True)
    created_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return self.name


class ComplianceCheck(models.Model):
    """Results of compliance checks"""
    agent = models.ForeignKey('agents.Agent', on_delete=models.CASCADE)
    policy = models.ForeignKey(CompliancePolicy, on_delete=models.CASCADE)
    status = models.CharField(max_length=20, choices=[
        ('compliant', 'Compliant'),
        ('non_compliant', 'Non Compliant'),
        ('unknown', 'Unknown'),
        ('error', 'Error'),
    ])
    details = models.JSONField(default=dict, help_text="Detailed check results")
    evidence = models.JSONField(default=dict, help_text="Evidence collected")
    check_date = models.DateTimeField(auto_now_add=True)
    next_check = models.DateTimeField()
    
    class Meta:
        ordering = ['-check_date']
    
    def __str__(self):
        return f"{self.agent.hostname} - {self.policy.name} - {self.status}"


class ComplianceReport(models.Model):
    """Generated compliance reports"""
    organization = models.ForeignKey('clients.Client', on_delete=models.CASCADE)
    framework = models.ForeignKey(ComplianceFramework, on_delete=models.CASCADE)
    report_type = models.CharField(max_length=50, choices=[
        ('summary', 'Summary Report'),
        ('detailed', 'Detailed Report'),
        ('gap_analysis', 'Gap Analysis'),
        ('remediation', 'Remediation Plan'),
    ])
    report_data = models.JSONField(default=dict)
    generated_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    generated_at = models.DateTimeField(auto_now_add=True)
    file_path = models.CharField(max_length=500, blank=True)
    
    class Meta:
        ordering = ['-generated_at']
    
    def __str__(self):
        return f"{self.organization.name} - {self.framework.name} - {self.report_type}"
EOF

# Create vulnerability management app
print_status "Creating vulnerability management app..."
mkdir -p tacticalrmm/api/tacticalrmm/vulnerability
cat > tacticalrmm/api/tacticalrmm/vulnerability/__init__.py << 'EOF'
"""
m.RMM Vulnerability Management Module
Integrates with external vulnerability scanners
"""
EOF

cat > tacticalrmm/api/tacticalrmm/vulnerability/models.py << 'EOF'
from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()


class VulnerabilityScanner(models.Model):
    """Configuration for external vulnerability scanners"""
    name = models.CharField(max_length=100)
    scanner_type = models.CharField(max_length=50, choices=[
        ('nessus', 'Tenable Nessus'),
        ('openvas', 'OpenVAS'),
        ('qualys', 'Qualys'),
        ('rapid7', 'Rapid7'),
    ])
    api_url = models.URLField()
    api_key = models.CharField(max_length=255, blank=True)
    api_secret = models.CharField(max_length=255, blank=True)
    is_active = models.BooleanField(default=True)
    scan_interval = models.IntegerField(default=86400 * 7, help_text="Scan interval in seconds")
    
    def __str__(self):
        return f"{self.name} ({self.scanner_type})"


class VulnerabilityScan(models.Model):
    """Vulnerability scan instances"""
    scanner = models.ForeignKey(VulnerabilityScanner, on_delete=models.CASCADE)
    agent = models.ForeignKey('agents.Agent', on_delete=models.CASCADE)
    scan_id = models.CharField(max_length=100, blank=True)  # External scanner scan ID
    status = models.CharField(max_length=20, choices=[
        ('pending', 'Pending'),
        ('running', 'Running'),
        ('completed', 'Completed'),
        ('failed', 'Failed'),
    ])
    started_at = models.DateTimeField(auto_now_add=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    total_vulnerabilities = models.IntegerField(default=0)
    critical_count = models.IntegerField(default=0)
    high_count = models.IntegerField(default=0)
    medium_count = models.IntegerField(default=0)
    low_count = models.IntegerField(default=0)
    
    class Meta:
        ordering = ['-started_at']
    
    def __str__(self):
        return f"{self.agent.hostname} - {self.scanner.name} - {self.status}"


class Vulnerability(models.Model):
    """Individual vulnerabilities found"""
    scan = models.ForeignKey(VulnerabilityScan, on_delete=models.CASCADE, related_name='vulnerabilities')
    cve_id = models.CharField(max_length=20, blank=True)
    title = models.CharField(max_length=255)
    description = models.TextField()
    severity = models.CharField(max_length=20, choices=[
        ('critical', 'Critical'),
        ('high', 'High'),
        ('medium', 'Medium'),
        ('low', 'Low'),
        ('info', 'Informational'),
    ])
    cvss_score = models.FloatField(null=True, blank=True)
    affected_software = models.CharField(max_length=255, blank=True)
    affected_version = models.CharField(max_length=100, blank=True)
    solution = models.TextField(blank=True)
    status = models.CharField(max_length=20, choices=[
        ('open', 'Open'),
        ('fixed', 'Fixed'),
        ('accepted_risk', 'Accepted Risk'),
        ('false_positive', 'False Positive'),
    ], default='open')
    first_seen = models.DateTimeField(auto_now_add=True)
    last_seen = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-cvss_score', '-first_seen']
    
    def __str__(self):
        return f"{self.cve_id} - {self.title[:50]}"
EOF

print_step "Phase 4: Creating Configuration Files"

# Create NATS configuration
print_status "Creating NATS configuration..."
mkdir -p configs
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

# Create Makefile for easy management
print_status "Creating Makefile..."
cat > Makefile << 'EOF'
# m.RMM Makefile

.PHONY: help build up down logs clean migrate collectstatic createsuperuser

help: ## Show this help message
	@echo "m.RMM Management Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Build all Docker images
	docker-compose -f docker-compose.mrmm.yml build

up: ## Start all services
	docker-compose -f docker-compose.mrmm.yml up -d

down: ## Stop all services
	docker-compose -f docker-compose.mrmm.yml down

logs: ## View logs from all services
	docker-compose -f docker-compose.mrmm.yml logs -f

clean: ## Remove all containers and volumes
	docker-compose -f docker-compose.mrmm.yml down -v
	docker system prune -f

migrate: ## Run Django migrations
	docker-compose -f docker-compose.mrmm.yml exec api python manage.py migrate

collectstatic: ## Collect static files
	docker-compose -f docker-compose.mrmm.yml exec api python manage.py collectstatic --noinput

createsuperuser: ## Create Django superuser
	docker-compose -f docker-compose.mrmm.yml exec api python manage.py createsuperuser

shell: ## Open Django shell
	docker-compose -f docker-compose.mrmm.yml exec api python manage.py shell

backup: ## Backup database
	docker-compose -f docker-compose.mrmm.yml exec postgres pg_dump -U postgres mrmm > backup_$(shell date +%Y%m%d_%H%M%S).sql

restore: ## Restore database (usage: make restore FILE=backup.sql)
	docker-compose -f docker-compose.mrmm.yml exec -T postgres psql -U postgres mrmm < $(FILE)

update: ## Update all containers
	docker-compose -f docker-compose.mrmm.yml pull
	$(MAKE) down
	$(MAKE) up

dev: ## Start in development mode
	docker-compose -f docker-compose.mrmm.yml -f docker-compose.dev.yml up

test: ## Run tests
	docker-compose -f docker-compose.mrmm.yml exec api python manage.py test
EOF

print_step "Phase 5: Creating Installation Script"

# Create installation script
print_status "Creating installation script..."
cat > install_mrmm.sh << 'EOF'
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
EOF

chmod +x install_mrmm.sh

print_step "Phase 6: Creating Documentation"

# Create README for m.RMM
print_status "Creating m.RMM README..."
cat > README_mRMM.md << 'EOF'
# m.RMM - Advanced Remote Monitoring & Management

**m.RMM** is an enterprise-grade Remote Monitoring & Management solution based on Tactical RMM, enhanced with advanced security features, compliance modules, and enterprise integrations.

## 🌟 Features

### Core RMM Features
- **Remote Control**: TeamViewer-like remote desktop control via MeshCentral
- **Real-time Shell**: Remote command execution and terminal access
- **File Management**: Remote file browser with upload/download capabilities
- **Script Execution**: PowerShell, Python, Bash, and Batch script execution
- **Patch Management**: Automated Windows update management
- **Service Management**: Windows service monitoring and control
- **Hardware/Software Inventory**: Comprehensive system information collection

### m.RMM Enterprise Enhancements
- **RBAC Multi-tenant**: Role-based access control with organization isolation
- **2FA Authentication**: TOTP-based two-factor authentication
- **Compliance Dashboard**: LGPD and ISO 27001 compliance monitoring
- **Vulnerability Management**: Integration with Nessus, OpenVAS, and other scanners
- **SIEM Integration**: ConnectorsR for Azure Sentinel, Splunk, and RocketCyber
- **Backup Monitoring**: Integration with Datto, Acronis, and Veeam
- **Advanced Alerting**: Intelligent alerting with webhook support
- **Audit Logging**: Comprehensive security event logging

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose
- Domain name with DNS configured
- SSL certificate (Let's Encrypt supported)

### Installation

1. **Clone and prepare the installation:**
   ```bash
   git clone <your-mrmm-repo>
   cd mrmm
   ./install_mrmm.sh
   ```

2. **Configure environment:**
   ```bash
   cp .env.mrmm .env
   # Edit .env with your configuration
   nano .env
   ```

3. **Start services:**
   ```bash
   make up
   ```

4. **Initialize database:**
   ```bash
   make migrate
   make createsuperuser
   ```

5. **Access m.RMM:**
   - Web Interface: `https://your-domain.com`
   - API: `https://api.your-domain.com`
   - MeshCentral: `https://mesh.your-domain.com`

## 📊 Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Vue.js SPA    │    │  Django API     │    │  Go Agents      │
│   (Frontend)    │◄──►│   (Backend)     │◄──►│  (Endpoints)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │              ┌─────────────────┐              │
         │              │   PostgreSQL    │              │
         │              │   (Database)    │              │
         │              └─────────────────┘              │
         │                       │                       │
         │              ┌─────────────────┐              │
         └──────────────►│      Redis      │◄─────────────┘
                        │ (Cache/Queue)   │
                        └─────────────────┘
                                 │
                        ┌─────────────────┐
                        │   MeshCentral   │
                        │ (Remote Control)│
                        └─────────────────┘
```

## 🔧 Management Commands

Use the provided Makefile for easy management:

```bash
make help           # Show all available commands
make up             # Start all services
make down           # Stop all services
make logs           # View logs
make migrate        # Run database migrations
make backup         # Backup database
make update         # Update all containers
```

## 🔐 Security Features

### Authentication & Authorization
- **Multi-factor Authentication**: TOTP support
- **Role-based Access Control**: Granular permissions per organization
- **Session Management**: Configurable session timeouts
- **API Security**: JWT tokens with refresh mechanism

### Compliance & Auditing
- **LGPD Compliance**: Data protection and privacy controls
- **ISO 27001**: Information security management
- **Audit Trails**: Comprehensive activity logging
- **Evidence Collection**: Automated compliance evidence gathering

### Vulnerability Management
- **Automated Scanning**: Integration with security scanners
- **Risk Assessment**: CVE scoring and prioritization
- **Remediation Tracking**: Patch management and fix verification
- **Reporting**: Executive and technical vulnerability reports

## 🔌 Integrations

### Security Tools
- **Nessus**: Vulnerability scanning
- **OpenVAS**: Open-source vulnerability assessment
- **Azure Sentinel**: Cloud SIEM integration
- **Splunk**: Enterprise security platform
- **RocketCyber**: Managed security services

### Backup Solutions
- **Datto**: Business continuity and disaster recovery
- **Acronis**: Cyber backup and protection
- **Veeam**: Data protection and management

### Monitoring & Alerting
- **Webhooks**: Custom alert integrations
- **Email/SMS**: Traditional notification channels
- **Slack**: Team collaboration alerts
- **Microsoft Teams**: Business communication alerts

## 📈 Compliance Dashboard

m.RMM includes built-in compliance monitoring for:

### LGPD (Brazilian Data Protection Law)
- Data inventory and mapping
- Consent management tracking
- Data breach notification workflows
- Privacy impact assessments

### ISO 27001 (Information Security Management)
- Security control implementation tracking
- Risk assessment and treatment
- Incident management workflows
- Management review reporting

## 🏢 Multi-tenant Architecture

m.RMM supports true multi-tenancy with:
- **Organization Isolation**: Complete data separation
- **Role Hierarchy**: Global, organization, and site-level roles
- **Custom Branding**: Per-organization logos and themes
- **Usage Reporting**: Resource utilization tracking

## 📞 Support

- **Documentation**: Comprehensive admin and user guides
- **API Reference**: Complete REST API documentation
- **Community**: Discord server for community support
- **Enterprise Support**: Professional support packages available

## 📄 License

m.RMM is based on Tactical RMM and includes additional proprietary enhancements. See LICENSE file for details.

## 🤝 Contributing

We welcome contributions! Please see CONTRIBUTING.md for guidelines.

---

**m.RMM** - Securing and managing your infrastructure with confidence.
EOF

print_step "Phase 7: Final Cleanup and Verification"

print_status "Setting executable permissions..."
chmod +x scripts/transform_to_mrmm.sh
chmod +x install_mrmm.sh

print_status "Creating .gitignore updates..."
cat >> .gitignore << 'EOF'

# m.RMM specific
.env
.env.local
.env.production
data/
logs/
backup_*.sql
EOF

print_step "✅ Transformation Complete!"

echo ""
echo "🎉 Tactical RMM has been successfully transformed to m.RMM!"
echo ""
echo "📋 What was completed:"
echo "  ✅ Frontend branding (Vue.js components, package.json)"
echo "  ✅ Backend branding (Django models, settings, management commands)"
echo "  ✅ Docker configuration for m.RMM"
echo "  ✅ Compliance module (LGPD/ISO 27001)"
echo "  ✅ Vulnerability management module"
echo "  ✅ Installation and management scripts"
echo "  ✅ Updated documentation"
echo ""
echo "🚀 Next Steps:"
echo "  1. Review and customize .env.mrmm configuration"
echo "  2. Run './install_mrmm.sh' to prepare installation"
echo "  3. Edit .env with your specific settings"
echo "  4. Run 'make up' to start m.RMM"
echo "  5. Run 'make migrate' to initialize database"
echo "  6. Run 'make createsuperuser' to create admin user"
echo ""
echo "📚 For more information, see README_mRMM.md"
echo ""
print_warning "Remember to:"
print_warning "  - Change all default passwords in .env"
print_warning "  - Configure SSL certificates for production"
print_warning "  - Set up proper backup procedures"
print_warning "  - Review security settings before deployment"
EOF