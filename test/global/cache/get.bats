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
    run cache.sh get
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Set cache path" ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]
}

@test "Should fail when option --path or -p is after get" {
    run cache.sh get --path=XYZ
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Set cache path" ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]
}

@test "Should fail when get without cache object" {
    run cache.sh --path=$TMPDIR get
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Cache object must be informed" ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]
}

@test "Should fail when object not exist" {

    KEY="folder/notExistObject"

    run cache.sh --path=$TMPDIR get $KEY
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Cache not found: $TMPDIR/$KEY" ]]

    run cache.sh -p $TMPDIR get $KEY
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Cache not found: $TMPDIR/$KEY" ]]

}

@test "Should get object when command is requered" {

    KEY="folder/getFirstObject"
    mkdir -p $(dirname "$TMPDIR/$KEY")
    > "$TMPDIR/$KEY"

    run cache.sh --path="$TMPDIR" get "$KEY"
    [[ "${status}" -eq 0 ]]
    [[ "${lines[0]}" == "$TMPDIR/$KEY" ]]

    KEY="folder/getSecondObject"
    mkdir -p $(dirname "$TMPDIR/$KEY")
    > "$TMPDIR/$KEY"

    run cache.sh --path="$TMPDIR" get "$KEY"
    [[ "${status}" -eq 0 ]]
    [[ "${lines[0]}" == "$TMPDIR/$KEY" ]]

}
