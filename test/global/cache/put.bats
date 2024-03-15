#!/usr/bin/env bats
# bats file_tags=cache

setup_file() {
    load "$PROJECT_ROOT/test/helpers/bats_setup"
    setPath global 
}

teardown() {
    echo "status: ${status}"
    echo "output: ${output}"
}

@test "Should fail when option --path or -p is not set" {
    run cache.sh put
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Set cache path" ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]
}

@test "Should fail when option --path or -p is after put" {
    run cache.sh put --path=XYZ
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Set cache path" ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]
}

@test "Should fail when put without cache object and file" {
    run cache.sh --path=$TMPDIR put
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Cache object and file must be informed" ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]
}

@test "Should fail when put with cache object and without cache file" {
    run cache.sh --path=$TMPDIR put XYZ
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Cache object and file must be informed" ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]
}

@test "Should fail when file not exist" {

    KEY="folder/object"
    FILE="$(mktemp -up "$TMPDIR")"

    run cache.sh --path=$TMPDIR put $KEY "$FILE"
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "File not found: $TMPDIR/$KEY" ]]

    run cache.sh --path=$TMPDIR put $KEY "$FILE"
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "File not found: $TMPDIR/$KEY" ]]

}

@test "Should put file when command is requered" {
    
    KEY="folder/XYZ"
    FILE="$(mktemp -p "$TMPDIR")"  

    [[ -f "$FILE" ]]
    [[ ! -f "$TMPDIR/$KEY" ]]

    run cache.sh --path=$TMPDIR put $KEY "$FILE"
    [[ "${status}" -eq 0 ]]
    [[ "${lines[0]}" == "$TMPDIR/$KEY" ]]

    [[ -f "$TMPDIR/$KEY" ]]

}
