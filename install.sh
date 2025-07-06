#!/bin/zsh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

set_globals ./lie.json

copy_file() {
    local file="$1"
    print_info "Added ${file} to package"
    if [ ! -f "$file" ]; then
        print_error "${file} is not a file"
        return 1
    fi
    cp "$file" ./${MODULE_NAME}/ 
}

if [ ! -d "${MODULE_NAME}" ]; then
    print_error "${MODULE_NAME} is not a dir"
fi

./package.sh $JSON_CONFIG

copy_file lie.json
copy_file lie.sh
copy_file init.sh
copy_file package.sh
copy_file deploy.sh

./deploy.sh ./${MODULE_NAME}/${NAME}.json

rm -r ./${MODULE_NAME}


./shell.sh ${MODULE_HOME}/${NAME}.json

source ~/.zshrc 

cat ~/.zshrc  | grep ${NAME}