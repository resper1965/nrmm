# m.RMM - Advanced Remote Monitoring & Management

**m.RMM** é uma solução empresarial de Monitoramento e Gerenciamento Remoto baseada no Tactical RMM, aprimorada com recursos avançados de segurança, módulos de compliance e integrações empresariais.

## 🌟 Características Principais

### Funcionalidades Core RMM
- **Controle Remoto**: Controle remoto via MeshCentral similar ao TeamViewer
- **Shell em Tempo Real**: Execução remota de comandos e acesso ao terminal
- **Gerenciamento de Arquivos**: Navegador de arquivos remoto com upload/download
- **Execução de Scripts**: Scripts PowerShell, Python, Bash e Batch
- **Gerenciamento de Patches**: Gerenciamento automatizado de atualizações Windows
- **Gerenciamento de Serviços**: Monitoramento e controle de serviços Windows
- **Inventário**: Coleta abrangente de informações de hardware/software

### Aprimoramentos Empresariais m.RMM
- **RBAC Multi-tenant**: Controle de acesso baseado em funções com isolamento organizacional
- **Autenticação 2FA**: Autenticação de dois fatores baseada em TOTP
- **Dashboard de Compliance**: Monitoramento de conformidade LGPD e ISO 27001
- **Gerenciamento de Vulnerabilidades**: Integração com Nessus, OpenVAS e outros scanners
- **Integração SIEM**: Conectores para Azure Sentinel, Splunk e RocketCyber
- **Monitoramento de Backup**: Integração com Datto, Acronis e Veeam
- **Alertas Avançados**: Sistema de alertas inteligentes com suporte a webhooks
- **Log de Auditoria**: Log abrangente de eventos de segurança

## 🚀 Início Rápido

### Pré-requisitos
- Docker e Docker Compose
- Nome de domínio com DNS configurado
- Certificado SSL (Let's Encrypt suportado)

### Instalação

1. **Clone e prepare a instalação:**
   ```bash
   git clone <seu-repo-mrmm>
   cd mrmm
   ./install_mrmm.sh
   ```

2. **Configure o ambiente:**
   ```bash
   cp .env.mrmm .env
   # Edite .env com sua configuração
   nano .env
   ```

3. **Inicie os serviços:**
   ```bash
   make up
   ```

4. **Inicialize o banco de dados:**
   ```bash
   make migrate
   make createsuperuser
   ```

5. **Acesse o m.RMM:**
   - Interface Web: `https://seu-dominio.com`
   - API: `https://api.seu-dominio.com`
   - MeshCentral: `https://mesh.seu-dominio.com`

## 📊 Arquitetura

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Vue.js SPA    │    │  Django API     │    │  Agentes Go     │
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
                        │ (Controle Remoto)│
                        └─────────────────┘
```

### Componentes da Arquitetura

#### Backend (Django + DRF)
- **Core**: Configurações centrais e utilitários
- **Accounts**: Autenticação, usuários e RBAC
- **Agents**: Gerenciamento de agentes/endpoints
- **Clients**: Organizações e multi-tenancy
- **Scripts**: Execução remota de scripts
- **Checks**: Sistema de monitoramento
- **Alerts**: Sistema de alertas
- **Automation**: Políticas e automação
- **Compliance**: Módulo de conformidade (LGPD/ISO 27001)
- **Vulnerability**: Gerenciamento de vulnerabilidades

#### Frontend (Vue.js + Quasar)
- **Layouts**: Layout principal da aplicação
- **Components**: Componentes reutilizáveis
- **Views**: Páginas e rotas principais
- **Store**: Gerenciamento de estado (Pinia/Vuex)
- **API**: Chamadas para a API backend

#### Infraestrutura
- **PostgreSQL**: Banco de dados principal
- **Redis**: Cache e broker para Celery
- **NATS**: Messaging entre servidor e agentes
- **MeshCentral**: Plataforma de controle remoto
- **Celery**: Fila de tarefas assíncronas
- **Traefik**: Reverse proxy com SSL automático

## 🔧 Comandos de Gerenciamento

Use o Makefile fornecido para facilitar o gerenciamento:

```bash
make help           # Mostrar todos os comandos disponíveis
make install        # Preparar instalação do m.RMM
make up             # Iniciar todos os serviços
make down           # Parar todos os serviços
make logs           # Ver logs de todos os serviços
make migrate        # Executar migrações do banco
make backup         # Fazer backup do banco
make update         # Atualizar todos os containers
make status         # Mostrar status dos serviços
```

### Comandos de Desenvolvimento
```bash
make dev            # Iniciar em modo desenvolvimento
make test           # Executar testes
make shell          # Abrir shell Django
make frontend-logs  # Ver apenas logs do frontend
make backend-logs   # Ver apenas logs do backend
```

## 🔐 Recursos de Segurança

### Autenticação e Autorização
- **Autenticação Multi-fator**: Suporte TOTP
- **Controle de Acesso Baseado em Funções**: Permissões granulares por organização
- **Gerenciamento de Sessão**: Timeouts de sessão configuráveis
- **Segurança da API**: Tokens JWT com mecanismo de refresh

### Compliance e Auditoria
- **Conformidade LGPD**: Controles de proteção e privacidade de dados
- **ISO 27001**: Gerenciamento de segurança da informação
- **Trilhas de Auditoria**: Log abrangente de atividades
- **Coleta de Evidências**: Coleta automatizada de evidências de conformidade

### Gerenciamento de Vulnerabilidades
- **Scanning Automatizado**: Integração com scanners de segurança
- **Avaliação de Risco**: Pontuação CVE e priorização
- **Rastreamento de Remediação**: Gerenciamento de patches e verificação de correções
- **Relatórios**: Relatórios executivos e técnicos de vulnerabilidades

## 🔌 Integrações

### Ferramentas de Segurança
- **Nessus**: Scanning de vulnerabilidades
- **OpenVAS**: Avaliação de vulnerabilidades open-source
- **Azure Sentinel**: Integração SIEM em nuvem
- **Splunk**: Plataforma de segurança empresarial
- **RocketCyber**: Serviços de segurança gerenciada

### Soluções de Backup
- **Datto**: Continuidade de negócios e recuperação de desastres
- **Acronis**: Backup e proteção cibernética
- **Veeam**: Proteção e gerenciamento de dados

### Monitoramento e Alertas
- **Webhooks**: Integrações de alerta personalizadas
- **Email/SMS**: Canais de notificação tradicionais
- **Slack**: Alertas de colaboração em equipe
- **Microsoft Teams**: Alertas de comunicação empresarial

## 📈 Dashboard de Compliance

O m.RMM inclui monitoramento de conformidade integrado para:

### LGPD (Lei Geral de Proteção de Dados)
- Inventário e mapeamento de dados
- Rastreamento de gerenciamento de consentimento
- Fluxos de notificação de violação de dados
- Avaliações de impacto de privacidade

### ISO 27001 (Gerenciamento de Segurança da Informação)
- Rastreamento de implementação de controles de segurança
- Avaliação e tratamento de riscos
- Fluxos de gerenciamento de incidentes
- Relatórios de revisão gerencial

## 🏢 Arquitetura Multi-tenant

O m.RMM suporta verdadeiro multi-tenancy com:
- **Isolamento Organizacional**: Separação completa de dados
- **Hierarquia de Funções**: Funções globais, organizacionais e de site
- **Branding Personalizado**: Logos e temas por organização
- **Relatórios de Uso**: Rastreamento de utilização de recursos

## 🔧 Configuração de Desenvolvimento

### Estrutura de Arquivos
```
m.RMM/
├── tacticalrmm/           # Backend Django
├── tacticalrmm-web/       # Frontend Vue.js
├── docker-compose.mrmm.yml # Configuração Docker
├── .env.mrmm              # Template de ambiente
├── Makefile               # Comandos de gerenciamento
├── install_mrmm.sh        # Script de instalação
├── scripts/               # Scripts utilitários
├── configs/               # Arquivos de configuração
└── docs/                  # Documentação
```

### Desenvolvimento Local
```bash
# Modo desenvolvimento com hot reload
make dev

# Executar testes
make test

# Ver logs específicos
make frontend-logs
make backend-logs
make db-logs
```

## 📚 Módulos Personalizados

### Módulo de Compliance
Localização: `tacticalrmm/api/tacticalrmm/compliance/`

Funcionalidades:
- Frameworks de conformidade (LGPD, ISO 27001)
- Políticas de conformidade
- Verificações automatizadas
- Relatórios de conformidade
- Rastreamento de evidências

### Módulo de Vulnerabilidades
Localização: `tacticalrmm/api/tacticalrmm/vulnerability/`

Funcionalidades:
- Configuração de scanners externos
- Execução de scans automatizados
- Gerenciamento de vulnerabilidades
- Avaliação de riscos
- Planos de remediação

## 🚀 Roadmap de Implementação

### Fase 1: Branding e Configuração Básica ✅
- [x] Branding completo frontend/backend
- [x] Configuração Docker personalizada
- [x] Scripts de instalação e gerenciamento

### Fase 2: Módulos de Segurança
- [ ] Implementação completa do módulo de compliance
- [ ] Integração com scanners de vulnerabilidade
- [ ] Sistema RBAC multi-tenant
- [ ] Autenticação 2FA

### Fase 3: Integrações Externas
- [ ] Conectores SIEM (Sentinel, Splunk)
- [ ] Integrações de backup (Datto, Acronis, Veeam)
- [ ] Webhooks avançados
- [ ] APIs de terceiros

### Fase 4: Observabilidade
- [ ] Dashboards executivos
- [ ] Métricas avançadas
- [ ] Relatórios automatizados
- [ ] Alertas inteligentes

## 📞 Suporte

- **Documentação**: Guias abrangentes de administração e usuário
- **Referência da API**: Documentação completa da REST API
- **Comunidade**: Servidor Discord para suporte da comunidade
- **Suporte Empresarial**: Pacotes de suporte profissional disponíveis

## 🛡️ Segurança

### Relatório de Vulnerabilidades
Para relatar vulnerabilidades de segurança, envie um email para: security@seudominio.com

### Práticas de Segurança
- Todas as senhas são hasheadas usando bcrypt
- Comunicação criptografada TLS 1.3
- Autenticação baseada em JWT com expiração
- Logs de auditoria para todas as ações sensíveis
- Isolamento de dados multi-tenant

## 📄 Licença

m.RMM é baseado no Tactical RMM e inclui aprimoramentos proprietários adicionais. Veja o arquivo LICENSE para detalhes.

### Licenças de Componentes
- **Tactical RMM**: Tactical RMM License 1.0
- **Django**: BSD 3-Clause
- **Vue.js**: MIT License
- **PostgreSQL**: PostgreSQL License
- **Redis**: BSD 3-Clause

## 🤝 Contribuição

Aceitamos contribuições! Por favor, veja CONTRIBUTING.md para diretrizes.

### Como Contribuir
1. Fork o repositório
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📝 Changelog

### v1.0.0 (Data atual)
- Primeira versão do m.RMM
- Branding completo baseado no Tactical RMM
- Módulo de compliance (LGPD/ISO 27001)
- Módulo de gerenciamento de vulnerabilidades
- Configuração Docker otimizada
- Scripts de instalação e gerenciamento automatizados

---

**m.RMM** - Protegendo e gerenciando sua infraestrutura com confiança.

Para mais informações, visite: [docs.mrmm.seudominio.com](https://docs.mrmm.seudominio.com)

## 🙏 Agradecimentos

- Equipe do [Tactical RMM](https://github.com/amidaware/tacticalrmm) pela base sólida
- Comunidade open-source pelas ferramentas e bibliotecas utilizadas
- Contribuidores do projeto m.RMM