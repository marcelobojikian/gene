#!/usr/bin/env bats
# bats file_tags=server,command

setup_file() {
    load "$PROJECT_ROOT/test/helpers/bats_setup"
    setSrcPath

    local HOST=$(testServer)

    export ENV_FILE=$(getEnv "URI=$HOST"  \
                         "CACHEABLE=true" \
                         "CACHE_PATH=$TMPDIR")

}

teardown_file() { rm -f "$ENV_FILE"; }

setup() { cat $ENV_FILE; }

teardown() {
    echo "status: ${status}"
    echo "output: ${output}"
}

launch() {
    run command.sh --env-file=$ENV_FILE $@
}

subcommand_help() {
    launch $1 ${@:2}
    [[ "${status}" -eq 0 ]]
    [[ "${lines[0]}" == "Usage: gene $1"* ]]
}

command_help() {
    launch $@
    [[ "${status}" -eq 0 ]]
    [[ "${lines[0]}" == "Usage: gene [OPTIONS] COMMAND"* ]]
}

command_version() {
    launch $@ 
    [[ "${status}" -eq 0 ]]
    [[ "${lines[0]}" == "Version: "* ]]
}

invalid_option() {
    launch $@
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Invalid option: "* ]]
    [[ "${lines[1]}" == "Try 'gene -h' for more information." ]]
}

@test "Should show invalid option" {
    invalid_option -E
    invalid_option -Ehv
    invalid_option -X
    invalid_option --XXXXXX
}

@test "Should show cache usage" {
    subcommand_help cache
    subcommand_help cache -h
    subcommand_help cache --help
}

@test "Should show gene usage" {
    command_help 
    command_help -h
    command_help --help
    command_help -hl info
}

@test "Should show gene version" {
    command_version -hv
    command_version -vh
    command_version -v
    command_version --version
    command_version -vl
}