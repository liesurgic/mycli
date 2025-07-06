.PHONY: build package deploy install uninstall clean

build:
	./build.sh ./lie.json

package:
	./package.sh ./lie.json

deploy:
	./package.sh ./lie.cli/lie.json

install:
	./install.sh 

uninstall:
	./uninstall.sh 

clean:
	rm -r ./lie.cli
