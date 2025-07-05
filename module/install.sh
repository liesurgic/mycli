set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"
set_globals config.json
./package.sh config.json
rm .tmp/$NAME/$NAME.sh
cp commands.sh .tmp/$NAME/$NAME.sh
cp init.sh .tmp/$NAME/init.sh
cp package.sh .tmp/$NAME/package.sh
cp deploy.sh .tmp/$NAME/deploy.sh
./deploy.sh .tmp/$NAME/$NAME.json