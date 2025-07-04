rm -r .tmp 
mkdir -p .tmp/cli
./module/package.sh -f ./module/cli.json -o .tmp/cli 
cp -r ./module/* .tmp/cli
./module/scripts/deploy.sh .tmp/cli 

