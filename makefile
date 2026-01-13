# ---- Project config ----
DC := docker-compose
NGINX_SERVICE := nginx
HTPASSWD_FILE := infra/graphdb/htpasswd

# ---- Targets ----
.PHONY: help up down restart ps logs nginx-restart nginx-reload nginx-test htpasswd htpasswd-add

help:
	@echo "Targets:"
	@echo "  make up                       Start services (detached)"
	@echo "  make down                     Stop services"
	@echo "  make restart                  Restart all services"
	@echo "  make ps                       Show running services"
	@echo "  make logs                     Follow logs (tail 200)"
	@echo "  make nginx-test               Test nginx config (nginx -t) inside $(NGINX_SERVICE)"
	@echo "  make nginx-reload             Reload nginx inside $(NGINX_SERVICE)"
	@echo "  make nginx-restart            Restart $(NGINX_SERVICE)"
	@echo "  make htpasswd USER=admin      Create/overwrite $(HTPASSWD_FILE) (prompts password)"
	@echo "  make htpasswd-add USER=viewer Append user to $(HTPASSWD_FILE) (prompts password)"

up:
	$(DC) up -d

down:
	$(DC) down

restart:
	$(DC) restart

ps:
	$(DC) ps

logs:
	$(DC) logs -f --tail=200

nginx-restart:
	$(DC) restart $(NGINX_SERVICE)

nginx-reload:
	$(DC) exec $(NGINX_SERVICE) nginx -s reload

nginx-test:
	$(DC) exec $(NGINX_SERVICE) nginx -t

# Create/overwrite htpasswd with ONE user (good for single-admin)
htpasswd:
	@test -n "$(USER)" || (echo "Usage: make htpasswd USER=admin" && exit 1)
	@mkdir -p $$(dirname "$(HTPASSWD_FILE)")
	@docker run -it --rm httpd:2.4-alpine htpasswd -nB "$(USER)" > "$(HTPASSWD_FILE)"
	@echo "Wrote $(HTPASSWD_FILE). (Nginx reads it as /etc/nginx/.htpasswd)"

# Append another user (multi-user)
htpasswd-add:
	@test -n "$(USER)" || (echo "Usage: make htpasswd-add USER=viewer" && exit 1)
	@mkdir -p $$(dirname "$(HTPASSWD_FILE)")
	@docker run -it --rm httpd:2.4-alpine htpasswd -nB "$(USER)" >> "$(HTPASSWD_FILE)"
	@echo "Appended user to $(HTPASSWD_FILE)."
