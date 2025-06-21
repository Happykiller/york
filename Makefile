PROJECT = York
CONTAINERS = york york_web
BASE_COMPOSE = docker-compose.yml
DEV_COMPOSE = docker-compose.override.yml
PROD_COMPOSE = docker-compose.prod.yml

# === STARTUP ===

start: install_network ## 🔐 Start project in production mode
	@echo "🚀 Starting $(PROJECT) in \033[1mPRODUCTION\033[0m mode..."
	docker compose -f $(BASE_COMPOSE) -f $(PROD_COMPOSE) up -d

startall: install_network ## 🔨 Build & start in production
	@echo "🛠️  Build & start $(PROJECT) in \033[1mPRODUCTION\033[0m mode..."
	docker compose -f $(BASE_COMPOSE) -f $(PROD_COMPOSE) up --build -d

start_dev: install_network ## 💻 Start project in development mode
	@echo "💻 Starting $(PROJECT) in \033[1mDEVELOPMENT\033[0m mode..."
	docker compose -f $(BASE_COMPOSE) -f $(DEV_COMPOSE) up -d

startall_dev: install_network ## 🔧 Build & start in development
	@echo "🔧 Build & start $(PROJECT) in \033[1mDEVELOPMENT\033[0m mode..."
	docker compose -f $(BASE_COMPOSE) -f $(DEV_COMPOSE) up --build -d

# === SHUTDOWN / RESET ===

down: ## ⏹️ Stop containers
	@echo "⏹️  Stopping containers..."
	docker compose stop $(CONTAINERS)

reset: down ## 🗑️ Remove containers only
	@echo "🗑️  Removing containers..."
	docker compose rm -f $(CONTAINERS)

reset-all: ## 💣 Full cleanup (containers, volumes, networks)
	@echo "💣 Full cleanup (containers + volumes + networks)..."
	docker compose -f $(BASE_COMPOSE) down -v --remove-orphans

# === UTILITIES ===

status: ## 📦 Show container status
	docker compose ps

logs: ## 📜 Tail live logs
	docker compose logs -f

envcheck: ## 🔎 Check loaded .env variables
	@if [ ! -f .env ]; then \
		echo "❌ .env file missing"; \
	else \
		echo "🧾 Loaded .env variables:"; \
		cat .env | grep -vE '^\s*#' | grep -vE '^\s*$$'; \
	fi

install_network: ## 🌐 Create 'interservices' network if not present
	@echo "🌐 Checking Docker network 'interservices'..."
	@if ! docker network inspect interservices > /dev/null 2>&1; then \
		echo "🔧 Creating network 'interservices'..."; \
		docker network create interservices; \
	else \
		echo "✅ Docker network 'interservices' already exists."; \
	fi

# === HELP ===

help: ## 📖 Show available commands
	@echo ""
	@echo "🎛️  \033[1;34m$(PROJECT) Makefile – Available Commands\033[0m"
	@echo ""
	@grep -E '^[a-zA-Z0-9_-]+:.*?##' Makefile \
		| awk 'BEGIN {FS = ":.*?## "}; {printf " \033[33m%-18s\033[0m %s\n", $$1, $$2}'
	@echo ""

.PHONY: start startall start_dev startall_dev down reset reset-all status logs envcheck install_network help
