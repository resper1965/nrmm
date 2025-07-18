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
