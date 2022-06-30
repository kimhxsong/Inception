include ./Makefile.Inception.inc

.PHONY: build
build:
	$(DCBUILD)

.PHONY: create
create:
	@$(DCCREATE)

.PHONY: up
up: build
	@$(DCUP) -d

.PHONY: down
down:
	@$(DCDOWN) --volumes > /dev/null 2>&1

.PHONY: clean
clean: down
	@yes | docker image prune -a > /dev/null 2>&1

.PHONY: re
re: clean up
