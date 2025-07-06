.PHONY: build package deploy install uninstall clean shell

LIE_HOME := $(HOME)/.lie
MODULES_DIRECTORY := $(LIE_HOME)/modules
CLI_HOME := ""

SCRIPT_HOME := $(shell cd "$(dir $(abspath $(lastword $(MAKEFILE_LIST))))" && pwd)

ifeq ($(wildcard $(SCRIPT_HOME)/lie.sh),)
    CLI_HOME := $(LIE_HOME)/modules/lie.cli
else
    CLI_HOME := $(SCRIPT_HOME)
endif

build:
	@$(CLI_HOME)/build.sh $(name)

package:
	@$(CLI_HOME)/package.sh $(name)

deploy:
	@$(CLI_HOME)/deploy.sh $(name)

install:
	$(MAKE) package name=lie
	$(MAKE) build name=lie
	@cp *.sh ./lie.cli/
	@cp Makefile ./lie.cli/
	@ls ./lie.cli/
	$(MAKE) deploy name=lie
	$(MAKE) shell name=lie


	

uninstall:
	$(MAKE) clean name=lie

clean:
	@rm -r ./$(name).cli

shell:
	@$(CLI_HOME)/shell.sh $(MODULES_DIRECTORY)/$(name).cli/$(name).json
	@cat ~/.zshrc | grep lie
