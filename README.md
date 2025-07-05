rm -r .tmp 
mkdir -p .tmp/cli
./module/package.sh -f ./module/cli.json -o .tmp/cli 
cp -r ./module/* .tmp/cli
./module/scripts/deploy.sh .tmp/cli 



When working with Bash, proper quoting of variables within command substitution and redirection is crucial to prevent word splitting and unintended behavior. Here are the best practices:

Use Double Quotes for Variable and Command Substitution: Always enclose variables and command substitutions in double quotes to preserve spaces and prevent word splitting. For example:
today=$(date)
echo "$today"
This ensures that if the output of date contains spaces, it will still be treated as a single unit.
Quoting Within Command Substitution: When using variables inside command substitution, they should also be double-quoted to maintain their integrity. This applies even when nesting command substitutions:
FILE="/path/to/file with spaces.txt"
DIRNAME=$(dirname "$FILE")
Failing to quote $FILE would cause issues because dirname would receive multiple arguments due to the space in the filename.
Redirection and Quoting: When using redirection, especially with here-documents or here-strings, be aware of how quoting affects variable expansion. If the delimiter in a here-document is unquoted, the shell will perform variable and command substitution on the contents. If it is quoted, no such expansion occurs:
cat <<EOF
The current date is: $(date)
EOF
This will expand the $(date) command substitution before printing the text. If you want to prevent this, quote the delimiter:
cat <<'EOF'
The current date is: $(date)
EOF
In this case, the literal string $(date) will be printed without substitution.
Avoid Using Unquoted Variables in Commands: When passing variables to commands, especially those that may contain spaces or special characters, always quote them:
make -D "THING=$var"
This prevents the shell from splitting the variable into multiple arguments if it contains spaces.
Use $() Instead of Backticks: Prefer the $() syntax over backticks for command substitution because it is more readable and easier to nest. Backticks require escaping when nesting, while $() handles it naturally:
echo "The result is: $(grep 'pattern' $(find /path -name "*.txt"))"
This is clearer and less error-prone than using nested backticks.
Handle Edge Cases with Care: If there's a possibility that the output of a command substitution might end with a newline, be cautious, as $() removes trailing newlines. If preserving the newline is important, consider alternative approaches or add a placeholder character to ensure it remains intact.
By following these best practices, you can write more robust and reliable Bash scripts that handle edge cases like spaces in filenames or unexpected command outputs gracefully.