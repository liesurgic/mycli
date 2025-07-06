#!/bin/zsh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

set_globals ./lie.json

# copy_file() {
#     local file="$1"
#     print_info "Added ${file} to package"
#     if [ ! -f "$file" ]; then
#         print_error "${file} is not a file"
#         return 1
#     fi
#     cp "$file" ./${MODULE_NAME}/ 
# }

$PACKAGE_SCRIPT $JSON_CONFIG

if [ ! -d "${MODULE_NAME}" ]; then
    print_error "${MODULE_NAME} is not a dir"
fi


cp *.sh ./${MODULE_NAME}/ 
ls ./${MODULE_NAME}/ 
# copy_file lie.json
# copy_file lie.sh
# copy_file init.sh
# copy_file package.sh
# copy_file deploy.sh
# copy_file shell.sh

$DEPLOY_SCRIPT ./${MODULE_NAME}/${NAME}.json

rm -r ./*.cli


$SHELL_SCRIPT ${MODULE_HOME}/${MODULE_NAME}/${NAME}.json

source ~/.zshrc 

cat ~/.zshrc  | grep ${NAME}