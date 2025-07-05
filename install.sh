#!/bin/zsh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"
set_globals config.json

print_info "packing config.json"
./package.sh config.json

print_info "removing .tmp/${NAME}/${NAME}.sh"
rm .tmp/$NAME/$NAME.sh

print_info "copying cmds.sh .tmp/${NAME}/${NAME}.sh"
cp cmds.sh .tmp/$NAME/$NAME.sh

print_info "copying init.sh .tmp/${NAME}/init.sh"
cp init.sh .tmp/$NAME/init.sh

print_info "copying package.sh .tmp/${NAME}/package.sh"
cp package.sh .tmp/$NAME/package.sh

print_info "copying deploy.sh .tmp/${NAME}/deploy.sh"
cp deploy.sh .tmp/$NAME/deploy.sh

print_info "deploying .tmp/${NAME}/${NAME}.json"
./deploy.sh .tmp/$NAME/$NAME.json

source ~/.zshrc 