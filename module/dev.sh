dev() {
    local script="$1"
    local func="$2"
    shift 2
    # Always use bash to source and call the function
    (bash -c "source \"$script\" && $func \"$@\"")
}