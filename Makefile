DC_FILE = -f ./srcs/docker-compose.yml
DC = docker-compose $(DC_FILE)
DATA_DIR = $(shell pwd)/data

DCBUILD=$(DC) build
DCCREATE= $(DC) create
DCUP = $(DC) up
DCDOWN = $(DC) down
DCLOGS = $(DC) logs

.PHONY: create-dirs
create-dirs:
	@echo "Creating data directories..."
	@mkdir -p $(DATA_DIR)/db $(DATA_DIR)/www
	@echo "Directories created. Verifying paths:"
	@ls -ld $(DATA_DIR)/db
	@ls -ld $(DATA_DIR)/www

.PHONY: set-path
set-path:
	@sed -i.bak "s|<DATA_PATH>|$(shell pwd)/data|g" ./srcs/docker-compose.yml

.PHONY: reset-path
reset-path:
	@if [ -f ./srcs/docker-compose.yml.bak ]; then \
		rm ./srcs/docker-compose.yml; \
		mv ./srcs/docker-compose.yml.bak ./srcs/docker-compose.yml; \
	fi

.PHONY: build
build: create-dirs set-path
	$(DCBUILD) $(c)

.PHONY: create
create:
	@$(DCCREATE) $(c)

.PHONY: up
up: build
	@$(DCUP) -d $(c)

.PHONY: down
down: reset-path
	@$(DCDOWN) $(c) --volumes

.PHONY: clean
clean: down
	@echo "Cleaning up images and data directories..."
	@docker image prune -af > /dev/null 2>&1
	@rm -rf $(DATA_DIR)
	@echo "Cleanup complete."

.PHONY: re
re: clean up
