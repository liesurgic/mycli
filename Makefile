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
	@echo "RUNNING COMMAND: ./build.sh $(name)"
	@$(CLI_HOME)/build.sh $(name)

package:
	@echo "RUNNING COMMAND: ./package.sh $(name)"
	@$(CLI_HOME)/package.sh $(name)

deploy:
	@echo "RUNNING COMMAND: ./deploy.sh $(name)"
	@$(CLI_HOME)/deploy.sh $(name)

install:
	$(MAKE) package name=lie
	$(MAKE) build name=lie
	@cp *.sh ./lie.cli/
	@cp Makefile ./lie.cli/
	@ls ./lie.cli/
	$(MAKE) deploy name=lie
	$(MAKE) shell name=lie
	$(MAKE) clean name=lie


	

uninstall:
	@$(CLI_HOME)/uninstall.sh 
	$(MAKE) clean name=lie

clean:
	@echo "RUNNING COMMAND: rm -r ./$(name).cli"
	@rm -r ./$(name).cli

shell:
	@echo "RUNNING COMMAND: ./shell.sh $(MODULES_DIRECTORY)/$(name).cli/$(name).json"
	@$(CLI_HOME)/shell.sh $(MODULES_DIRECTORY)/$(name).cli/$(name).json
	@cat ~/.zshrc | grep lie
