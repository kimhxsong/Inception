DC_FILE = -f ./srcs/docker-compose.yml
DC = docker-compose $(DC_FILE)

DCBUILD=$(DC) build
DCCREATE= $(DC) create
DCUP = $(DC) up
DCDOWN = $(DC) down
DCLOGS = $(DC) logs