.PHONY: build package deploy install uninstall clean shell

LIE_HOME := $(HOME)/.lie
MODULES_DIR := $(LIE_HOME)/modules
CLI_HOME := $(MODULES_DIR)/lie.cli



build:
	@echo "RUNNING COMMAND: ./build.sh $(name)"
	@./build.sh $(name)

package:
	@echo "RUNNING COMMAND: ./package.sh $(name)"
	@./package.sh $(name)

deploy:
	@echo "RUNNING COMMAND: ./deploy.sh $(name)"
	@./deploy.sh $(name)

install:
	$(MAKE) package name=lie
	$(MAKE) build name=lie
	@cp *.sh ./lie.cli/
	@ls ./lie.cli/
	$(MAKE) deploy name=lie
	$(MAKE) shell name=lie
	$(MAKE) clean name=lie
	

uninstall:
	@./uninstall.sh 
	$(MAKE) clean name=lie

clean:
	@echo "RUNNING COMMAND: rm -r ./$(name).cli"
	@rm -r ./$(name).cli

shell:
	@echo "RUNNING COMMAND: ./shell.sh $(MODULES_DIR)/$(name).cli/$(name).json"
	@./shell.sh $(MODULES_DIR)/$(name).cli/$(name).json
	@cat ~/.zshrc | grep lie
