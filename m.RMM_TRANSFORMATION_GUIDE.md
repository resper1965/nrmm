# 🚀 Guia de Transformação: Tactical RMM → m.RMM

## 📋 Visão Geral do Projeto

**m.RMM** é uma solução própria de Monitoramento e Gerenciamento Remoto baseada no projeto open-source Tactical RMM, com foco em:

- **Segurança Avançada**: Implementação de RBAC multi-tenant e 2FA
- **Escalabilidade**: Arquitetura otimizada para ambientes empresariais
- **Conformidade Regulatória**: Módulos específicos para LGPD e ISO 27001
- **Extensibilidade**: Integrações com SIEMs, backup e vulnerability scanners

---

## 🏗️ 1. Arquitetura Completa do Tactical RMM

### Backend (Django + DRF)
```
tacticalrmm/api/tacticalrmm/
├── accounts/          # Autenticação e usuários
├── agents/           # Gestão de agentes/endpoints
├── alerts/           # Sistema de alertas
├── automation/       # Políticas e automação
├── checks/           # Checks de monitoramento
├── clients/          # Clientes/organizações
├── core/             # Configurações centrais
├── logs/             # Logs e auditoria
├── scripts/          # Scripts remotos
├── services/         # Serviços Windows
├── software/         # Inventário de software
├── tacticalrmm/      # Settings Django
└── winupdate/        # Windows Updates
```

### Frontend (Vue.js + Quasar)
```
tacticalrmm-web/src/
├── components/       # Componentes reutilizáveis
├── layouts/          # Layouts da aplicação
├── pages/            # Páginas/rotas
├── router/           # Configuração de rotas
├── store/            # Vuex/Pinia stores
├── api/              # Chamadas à API
├── utils/            # Utilitários
└── assets/           # Assets estáticos
```

### Agente (Go)
```
natsapi/              # API NATS em Go
main.go               # Agente principal
```

### Infraestrutura
- **PostgreSQL**: Banco principal
- **Redis**: Cache e broker Celery
- **NATS**: Messaging entre servidor e agentes
- **MeshCentral**: Controle remoto
- **Celery**: Task queue assíncrono

---

## 🔄 2. Plano de Refatoração para m.RMM

### Fase 1: Branding e Identidade Visual

#### 2.1 Frontend (Vue.js)
**Arquivos a modificar:**

```bash
# Package.json
tacticalrmm-web/package.json
- "productName": "Tactical RMM" → "m.RMM"

# HTML Template
tacticalrmm-web/index.html
- <title>Tactical RMM</title> → <title>m.RMM</title>

# Componentes Vue
tacticalrmm-web/src/views/LoginView.vue:9
- "Tactical RMM" → "m.RMM"

tacticalrmm-web/src/layouts/MainLayout.vue:62
- "Tactical RMM" → "m.RMM"

# Outros componentes
tacticalrmm-web/src/components/modals/agents/AgentRecovery.vue:27
tacticalrmm-web/src/components/modals/agents/RunScript.vue:162
tacticalrmm-web/src/components/scripts/ScriptFormModal.vue:214
```

#### 2.2 Backend (Django)
**Arquivos a modificar:**

```bash
# Models
tacticalrmm/api/tacticalrmm/core/models.py:77
- default="TacticalRMM" → default="m.RMM"

# Settings
tacticalrmm/api/tacticalrmm/tacticalrmm/settings.py
- Atualizar versões e metadados

# Management Commands
tacticalrmm/api/tacticalrmm/core/management/commands/get_mesh_exe_url.py:22
- "meshname": "TacticalRMM" → "meshname": "m.RMM"

tacticalrmm/api/tacticalrmm/core/management/commands/initial_mesh_setup.py:28
- "meshname": "TacticalRMM" → "meshname": "m.RMM"
```

#### 2.3 Assets e Ícones
```bash
# Favicon
tacticalrmm-web/public/favicon.ico → Substituir por logo m.RMM

# Criar novos assets
tacticalrmm-web/public/
├── logo-mrmm.png
├── icon-mrmm.svg
└── banner-mrmm.png
```

### Fase 2: Configurações e URLs

#### 2.4 Domínios e URLs Base
```python
# tacticalrmm/api/tacticalrmm/tacticalrmm/settings.py
ALLOWED_HOSTS = ['mrmm.yourdomain.com', 'api.mrmm.yourdomain.com']

# Configurar novos endpoints
API_BASE_URL = "https://api.mrmm.yourdomain.com"
WEB_BASE_URL = "https://mrmm.yourdomain.com"
```

---

## 🧩 3. Modularização Funcional

### Inventário de Funcionalidades

#### 3.1 Core Features
```
/agents/              # Gestão de endpoints
├── agent_table.py    # Lista de agentes
├── agent_views.py    # CRUD agentes
└── agent_tasks.py    # Tasks relacionadas

/checks/              # Sistema de monitoramento
├── disk_space.py     # Check espaço em disco
├── cpu_load.py       # Check CPU
├── memory.py         # Check memória
├── services.py       # Check serviços
└── script_checks.py  # Checks personalizados

/automation/          # Políticas e automação
├── policies.py       # Políticas de automação
├── tasks.py          # Tasks automatizadas
└── schedules.py      # Agendamentos
```

#### 3.2 Scripts Remotos
```
/scripts/
├── powershell/       # Scripts PowerShell
├── batch/            # Scripts Batch
├── python/           # Scripts Python
└── community/        # Scripts da comunidade
```

#### 3.3 Patch Management
```
/winupdate/
├── update_policies.py    # Políticas de update
├── patch_scanning.py     # Scan de patches
└── update_deployment.py  # Deploy de updates
```

#### 3.4 Controle Remoto
```
# Integração MeshCentral
/core/mesh_utils.py   # Utilitários MeshCentral
- Controle remoto via web
- File browser remoto
- Terminal remoto
```

---

## 🚀 4. Extensões Previstas no m.RMM

### 4.1 Painel de Compliance (LGPD/ISO 27001)

#### Estrutura Proposta
```python
# Nova app Django: compliance
/compliance/
├── models.py         # Modelos de compliance
├── views.py          # Views de compliance
├── serializers.py    # Serializers DRF
├── tasks.py          # Tasks de auditoria
└── reports.py        # Relatórios de compliance

# Models
class CompliancePolicy(models.Model):
    name = models.CharField(max_length=255)
    framework = models.CharField(choices=[('LGPD', 'LGPD'), ('ISO27001', 'ISO 27001')])
    requirements = models.JSONField()  # Lista de requisitos
    
class ComplianceCheck(models.Model):
    agent = models.ForeignKey('agents.Agent')
    policy = models.ForeignKey(CompliancePolicy)
    status = models.CharField(choices=[('compliant', 'Compliant'), ('non_compliant', 'Non Compliant')])
    last_check = models.DateTimeField(auto_now=True)
    evidence = models.JSONField()  # Evidências coletadas
```

#### Frontend Compliance Dashboard
```vue
<!-- tacticalrmm-web/src/views/ComplianceView.vue -->
<template>
  <div class="compliance-dashboard">
    <compliance-overview />
    <compliance-policies />
    <compliance-agents-status />
    <compliance-reports />
  </div>
</template>
```

### 4.2 Dashboard de Vulnerabilidades

#### Integração com Scanners Externos
```python
# /vulnerability/
├── scanner_integration.py  # Integração com Nessus, OpenVAS
├── cve_database.py         # Base CVE local
├── risk_assessment.py      # Análise de risco
└── remediation.py          # Planos de remediação

# API Integration Example
class VulnerabilityScanner:
    def scan_agent(self, agent_id):
        # Integração com Nessus API
        nessus_results = self.nessus_client.scan(agent_id)
        # Processar e armazenar resultados
        return self.process_scan_results(nessus_results)
```

### 4.3 Integração com Backup

#### Conectores para Datto, Acronis, Veeam
```python
# /backup_integration/
├── datto_connector.py      # Conector Datto
├── acronis_connector.py    # Conector Acronis
├── veeam_connector.py      # Conector Veeam
└── backup_monitoring.py    # Monitoramento de backup

class BackupConnector:
    def get_backup_status(self, agent_id):
        # Verificar status de backup por agente
        pass
    
    def schedule_backup(self, agent_id, policy):
        # Agendar backup baseado em política
        pass
```

### 4.4 Integração SIEM

#### Conectores para RocketCyber, Sentinel
```python
# /siem_integration/
├── rocket_cyber.py         # Conector RocketCyber
├── azure_sentinel.py       # Conector Azure Sentinel
├── splunk_connector.py     # Conector Splunk
└── siem_forwarder.py       # Encaminhamento de eventos

class SIEMForwarder:
    def send_security_event(self, event_data):
        # Enviar eventos de segurança para SIEM
        for siem in self.active_siems:
            siem.send_event(event_data)
```

---

## 🔐 5. Segurança e RBAC Avançado

### 5.1 Implementação RBAC Multi-tenant

#### Estrutura de Permissões
```python
# /accounts/rbac.py
class RolePermission(models.Model):
    role = models.ForeignKey('accounts.Role')
    module = models.CharField(choices=MODULE_CHOICES)
    permission = models.CharField(choices=PERMISSION_CHOICES)
    organization = models.ForeignKey('clients.Client', null=True)  # Multi-tenant

class OrganizationAccess(models.Model):
    user = models.ForeignKey('accounts.User')
    organization = models.ForeignKey('clients.Client')
    role = models.ForeignKey('accounts.Role')
    is_active = models.BooleanField(default=True)

# Permissões por módulo
MODULE_CHOICES = [
    ('agents', 'Agents Management'),
    ('scripts', 'Script Execution'),
    ('automation', 'Automation'),
    ('compliance', 'Compliance'),
    ('vulnerability', 'Vulnerability Management'),
    ('backup', 'Backup Management'),
]

PERMISSION_CHOICES = [
    ('view', 'View'),
    ('add', 'Add'),
    ('change', 'Change'),
    ('delete', 'Delete'),
    ('execute', 'Execute'),
]
```

### 5.2 Autenticação 2FA

#### Implementação TOTP
```python
# /accounts/two_factor.py
import pyotp
from django_otp.models import Device

class TOTPDevice(Device):
    user = models.OneToOneField('accounts.User')
    secret_key = models.CharField(max_length=32)
    
    def verify_token(self, token):
        totp = pyotp.TOTP(self.secret_key)
        return totp.verify(token, valid_window=1)

# Views
class Enable2FAView(APIView):
    def post(self, request):
        secret = pyotp.random_base32()
        device = TOTPDevice.objects.create(
            user=request.user,
            secret_key=secret
        )
        qr_url = pyotp.totp.TOTP(secret).provisioning_uri(
            name=request.user.email,
            issuer_name="m.RMM"
        )
        return Response({'qr_url': qr_url})
```

### 5.3 Auditoria e Logs de Segurança

#### Sistema de Auditoria Avançado
```python
# /audit/
class SecurityEvent(models.Model):
    user = models.ForeignKey('accounts.User', null=True)
    event_type = models.CharField(choices=SECURITY_EVENT_TYPES)
    severity = models.CharField(choices=SEVERITY_LEVELS)
    description = models.TextField()
    ip_address = models.GenericIPAddressField()
    user_agent = models.TextField()
    organization = models.ForeignKey('clients.Client', null=True)
    timestamp = models.DateTimeField(auto_now_add=True)
    additional_data = models.JSONField(default=dict)

SECURITY_EVENT_TYPES = [
    ('login_success', 'Successful Login'),
    ('login_failed', 'Failed Login'),
    ('permission_denied', 'Permission Denied'),
    ('data_export', 'Data Export'),
    ('agent_install', 'Agent Installation'),
    ('script_execution', 'Script Execution'),
    ('compliance_violation', 'Compliance Violation'),
]
```

---

## ⚙️ 6. Docker Compose Atualizado para m.RMM

### docker-compose.yml Completo
```yaml
version: '3.8'

services:
  # Backend API
  api:
    build:
      context: ./tacticalrmm
      dockerfile: docker/containers/tactical/Dockerfile
    container_name: mrmm-backend
    environment:
      - DEBUG=0
      - POSTGRES_DB=mrmm
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - REDIS_HOST=redis
      - MESH_HOST=meshcentral
      - TRMM_DOMAIN=${MRMM_DOMAIN}
    volumes:
      - tactical_data:/opt/tactical
      - mongo_data:/data/db
    depends_on:
      - postgres
      - redis
      - meshcentral
    networks:
      - mrmm-network

  # Frontend
  frontend:
    build:
      context: ./tacticalrmm-web
      dockerfile: Dockerfile
    container_name: mrmm-frontend
    environment:
      - BACKEND_URL=https://api.${MRMM_DOMAIN}
    networks:
      - mrmm-network

  # PostgreSQL Database
  postgres:
    image: postgres:15-alpine
    container_name: mrmm-postgres
    environment:
      - POSTGRES_DB=mrmm
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - mrmm-network

  # Redis
  redis:
    image: redis:7-alpine
    container_name: mrmm-redis
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    networks:
      - mrmm-network

  # Celery Worker
  celery:
    build:
      context: ./tacticalrmm
      dockerfile: docker/containers/tactical/Dockerfile
    container_name: mrmm-celery
    command: celery -A tacticalrmm worker -l info
    environment:
      - POSTGRES_DB=mrmm
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - REDIS_HOST=redis
    volumes:
      - tactical_data:/opt/tactical
    depends_on:
      - postgres
      - redis
    networks:
      - mrmm-network

  # Celery Beat (Scheduler)
  celery-beat:
    build:
      context: ./tacticalrmm
      dockerfile: docker/containers/tactical/Dockerfile
    container_name: mrmm-celery-beat
    command: celery -A tacticalrmm beat -l info
    environment:
      - POSTGRES_DB=mrmm
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - REDIS_HOST=redis
    volumes:
      - tactical_data:/opt/tactical
    depends_on:
      - postgres
      - redis
    networks:
      - mrmm-network

  # MeshCentral
  meshcentral:
    image: typhonragewind/meshcentral:latest
    container_name: mrmm-meshcentral
    environment:
      - HOSTNAME=${MRMM_DOMAIN}
      - REVERSE_PROXY=traefik
      - MESH_SOFTWARE_NAME=m.RMM
    volumes:
      - mesh_data:/opt/meshcentral/meshcentral-data
      - mesh_backups:/opt/meshcentral/meshcentral-backups
      - mesh_files:/opt/meshcentral/meshcentral-files
    networks:
      - mrmm-network

  # NATS Server
  nats:
    image: nats:2.11.2-alpine
    container_name: mrmm-nats
    command: ["-c", "/nats-server.conf"]
    volumes:
      - ./configs/nats-server.conf:/nats-server.conf
    networks:
      - mrmm-network

  # Reverse Proxy (Traefik)
  traefik:
    image: traefik:v3.0
    container_name: mrmm-proxy
    command:
      - "--api.dashboard=true"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.letsencrypt.acme.email=${ACME_EMAIL}"
      - "--certificatesresolvers.letsencrypt.acme.storage=/acme.json"
      - "--certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web"
    ports:
      - "80:80"
      - "443:443"
      - "8080:8080"  # Traefik dashboard
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - traefik_acme:/acme.json
    networks:
      - mrmm-network
    labels:
      - "traefik.enable=true"
      
      # Frontend
      - "traefik.http.routers.frontend.rule=Host(`${MRMM_DOMAIN}`)"
      - "traefik.http.routers.frontend.entrypoints=websecure"
      - "traefik.http.routers.frontend.tls.certresolver=letsencrypt"
      - "traefik.http.routers.frontend.service=frontend"
      - "traefik.http.services.frontend.loadbalancer.server.port=80"
      
      # API
      - "traefik.http.routers.api.rule=Host(`api.${MRMM_DOMAIN}`)"
      - "traefik.http.routers.api.entrypoints=websecure"
      - "traefik.http.routers.api.tls.certresolver=letsencrypt"
      - "traefik.http.routers.api.service=api"
      - "traefik.http.services.api.loadbalancer.server.port=8000"
      
      # MeshCentral
      - "traefik.http.routers.mesh.rule=Host(`mesh.${MRMM_DOMAIN}`)"
      - "traefik.http.routers.mesh.entrypoints=websecure"
      - "traefik.http.routers.mesh.tls.certresolver=letsencrypt"
      - "traefik.http.routers.mesh.service=mesh"
      - "traefik.http.services.mesh.loadbalancer.server.port=443"

volumes:
  postgres_data:
  redis_data:
  tactical_data:
  mongo_data:
  mesh_data:
  mesh_backups:
  mesh_files:
  traefik_acme:

networks:
  mrmm-network:
    driver: bridge

```

### .env para m.RMM
```bash
# m.RMM Configuration
MRMM_DOMAIN=mrmm.yourdomain.com
POSTGRES_PASSWORD=your_secure_password
ACME_EMAIL=admin@yourdomain.com

# Security
SECRET_KEY=your_django_secret_key
DJANGO_DEBUG=False

# External Integrations
NESSUS_API_KEY=your_nessus_key
ROCKET_CYBER_API_KEY=your_rocket_cyber_key
DATTO_API_KEY=your_datto_key

# SMTP
EMAIL_HOST=smtp.yourdomain.com
EMAIL_HOST_USER=noreply@yourdomain.com
EMAIL_HOST_PASSWORD=email_password
EMAIL_PORT=587
EMAIL_USE_TLS=True
```

---

## 📈 7. Exemplo de Automação Avançada

### Sistema de Regras Automatizadas
```python
# /automation/advanced_rules.py
class AdvancedAutomationRule(models.Model):
    name = models.CharField(max_length=255)
    organization = models.ForeignKey('clients.Client')
    trigger_condition = models.JSONField()  # Condições complexas
    actions = models.JSONField()  # Ações a executar
    is_active = models.BooleanField(default=True)
    
    # Exemplo de trigger: CPU > 95% por 10 minutos
    # {
    #   "metric": "cpu_usage",
    #   "operator": ">",
    #   "threshold": 95,
    #   "duration": 600,  # 10 minutos
    #   "consecutive": True
    # }
    
    # Exemplo de ações
    # [
    #   {
    #     "type": "execute_script",
    #     "script_id": 123,
    #     "parameters": {"service": "nginx"}
    #   },
    #   {
    #     "type": "send_webhook",
    #     "url": "https://siem.company.com/api/events",
    #     "payload": {
    #       "severity": "high",
    #       "event": "cpu_overload",
    #       "agent": "{{agent.hostname}}"
    #     }
    #   },
    #   {
    #     "type": "send_notification",
    #     "channels": ["email", "slack"],
    #     "message": "High CPU usage detected on {{agent.hostname}}"
    #   }
    # ]

class AutomationEngine:
    def evaluate_triggers(self):
        """Avaliar todas as regras ativas"""
        active_rules = AdvancedAutomationRule.objects.filter(is_active=True)
        
        for rule in active_rules:
            if self.check_trigger_condition(rule):
                self.execute_actions(rule)
    
    def check_trigger_condition(self, rule):
        """Verificar se condição do trigger foi atendida"""
        condition = rule.trigger_condition
        
        if condition['metric'] == 'cpu_usage':
            # Buscar dados de CPU dos últimos X minutos
            agents = self.get_organization_agents(rule.organization)
            return self.check_cpu_condition(agents, condition)
    
    def execute_actions(self, rule):
        """Executar ações da regra"""
        for action in rule.actions:
            if action['type'] == 'execute_script':
                self.execute_script_action(action, rule)
            elif action['type'] == 'send_webhook':
                self.send_webhook_action(action, rule)
            elif action['type'] == 'send_notification':
                self.send_notification_action(action, rule)
```

---

## 🛣️ 8. Roadmap de Fork m.RMM

### Etapa 1: Branding e Identidade (1-2 semanas)
- [ ] Substituir todos os "Tactical RMM" por "m.RMM"
- [ ] Criar nova identidade visual (logo, cores, ícones)
- [ ] Atualizar metadados e configurações
- [ ] Personalizar domínios e URLs

### Etapa 2: Arquitetura e Refatoração (2-3 semanas)
- [ ] Reestruturar apps Django para modularidade
- [ ] Implementar sistema RBAC multi-tenant
- [ ] Adicionar autenticação 2FA
- [ ] Melhorar sistema de auditoria

### Etapa 3: Extensões de Segurança (3-4 semanas)
- [ ] Módulo de Compliance (LGPD/ISO 27001)
- [ ] Dashboard de Vulnerabilidades
- [ ] Integração com scanners de segurança
- [ ] Conectores SIEM

### Etapa 4: Integrações Externas (2-3 semanas)
- [ ] Conectores de backup (Datto, Acronis, Veeam)
- [ ] APIs de vulnerability scanners
- [ ] Webhooks avançados
- [ ] Integrações de monitoramento

### Etapa 5: Observabilidade e Governança (2-3 semanas)
- [ ] Métricas avançadas e dashboards
- [ ] Relatórios de compliance
- [ ] Sistema de alertas inteligentes
- [ ] Documentação técnica completa

---

## 📋 Lista de Arquivos para Modificação

### Branding Frontend
```
tacticalrmm-web/package.json
tacticalrmm-web/index.html
tacticalrmm-web/src/views/LoginView.vue
tacticalrmm-web/src/layouts/MainLayout.vue
tacticalrmm-web/src/components/modals/agents/AgentRecovery.vue
tacticalrmm-web/src/components/modals/agents/RunScript.vue
tacticalrmm-web/src/components/scripts/ScriptFormModal.vue
tacticalrmm-web/public/favicon.ico
```

### Branding Backend
```
tacticalrmm/api/tacticalrmm/core/models.py
tacticalrmm/api/tacticalrmm/tacticalrmm/settings.py
tacticalrmm/api/tacticalrmm/core/management/commands/get_mesh_exe_url.py
tacticalrmm/api/tacticalrmm/core/management/commands/initial_mesh_setup.py
tacticalrmm/api/tacticalrmm/core/migrations/0030_coresettings_mesh_device_group.py
```

### Configurações Docker
```
docker-compose.yml
.env
Dockerfile (múltiplos)
configs/nginx.conf
configs/nats-server.conf
```

---

## 🚀 Conclusão

Este guia fornece um roadmap completo para transformar o Tactical RMM em **m.RMM**, uma solução empresarial robusta com foco em segurança, compliance e escalabilidade. 

**Benefícios da Transformação:**
- ✅ Identidade própria e branding personalizado
- ✅ Segurança empresarial com RBAC e 2FA
- ✅ Compliance regulatória (LGPD/ISO 27001)
- ✅ Integrações avançadas (SIEM, backup, vulnerabilidades)
- ✅ Escalabilidade e observabilidade aprimoradas

**Próximos Passos:**
1. Clonar e configurar ambiente de desenvolvimento
2. Iniciar Fase 1 (Branding)
3. Implementar melhorias arquiteturais
4. Desenvolver extensões específicas
5. Realizar testes e deploy em produção

O projeto m.RMM será uma evolução significativa do Tactical RMM, mantendo toda a funcionalidade core e adicionando camadas de segurança e compliance necessárias para ambientes empresariais.