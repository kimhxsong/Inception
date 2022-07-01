DC_FILE = -f ./srcs/docker-compose.yml
DC = docker-compose $(DC_FILE)

DCBUILD=$(DC) build
DCCREATE= $(DC) create
DCUP = $(DC) up
DCDOWN = $(DC) down
DCLOGS = $(DC) logs

.PHONY: build
build:
	$(DCBUILD) $(c)

.PHONY: create
create:
	@$(DCCREATE) $(c)

.PHONY: up
up: build
	@$(DCUP) -d $(c)

.PHONY: down
down:
	@$(DCDOWN) $(c) --volume > /dev/null 2>&1

.PHONY: clean
clean: down
	@yes | docker image prune -a > /dev/null 2>&1

.PHONY: re
re: clean up
