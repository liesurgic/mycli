# Modular CLI Framework Makefile

.PHONY: init build package deploy install uninstall test

init:
	./init.sh $(filter-out $@,$(MAKECMDGOALS))

package:
	./package/scripts/package.sh $(arg).json

deploy:
	./package/scripts/deploy.sh $(arg)

install:
	./installer/install.sh

uninstall:
	./installer/uninstall.sh

test:
	@echo "Coming soon..."
