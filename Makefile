all: up

up:
	docker compose up -d

down:
	docker compose down

prune:
	docker container prune
