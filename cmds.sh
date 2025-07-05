#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

init() {
    $SCRIPT_DIR/init.sh "$1"
}

build() {
    $SCRIPT_DIR/build.sh "$1"
}

deploy() {
    $SCRIPT_DIR/deploy.sh "$1"
}