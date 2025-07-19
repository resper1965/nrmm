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
