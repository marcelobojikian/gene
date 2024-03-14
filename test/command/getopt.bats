#!/usr/bin/env bats
# bats file_tags=server,command

setup() {
    load "$PROJECT_ROOT/test/helpers/bats_setup"
    methods "global/functions.sh"
    HOST=$(server)
    _setup 
}

teardown() {
    echo "status: ${status}"
    echo "output: ${output}"
}

debug() {
  status="$1"
  output="$2"
  if [[ ! "${status}" -eq "0" ]]; then
    echo "status: ${status}"
    echo "output: ${output}"
  fi
}

show_cache_help() {
    run command.sh --uri=$HOST $1 ${@:2}
    [[ "${status}" -eq 0 ]]
    [[ "${lines[0]}" == "Usage: gene cache"* ]]
}

show_gene_help() {
    run command.sh --uri=$HOST $@
    [[ "${status}" -eq 0 ]]
    [[ "${lines[0]}" == "Usage: gene [OPTIONS] COMMAND"* ]]
}

show_version() {
    run command.sh --uri=$HOST $@ 
    [[ "${status}" -eq 0 ]]
    [[ "${lines[0]}" == "Version: "* ]]
}

invalid_option() {
    run command.sh --uri=$HOST $@
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Invalid option: "* ]]
    [[ "${lines[1]}" == "Try 'gene -h' for more information." ]]
}

@test "Check invalid option" {
    invalid_option -E
    invalid_option -Ehv
    invalid_option -X
    invalid_option --XXXXXX
}

@test "Check gene help" {
    show_gene_help 
    show_gene_help -h
    show_gene_help --help
    show_gene_help -hl info
}

@test "Check cache help" {
    show_cache_help cache
    show_cache_help cache -h
    show_cache_help cache --help
}

@test "Check version option" {
    show_version -hv
    show_version -vh
    show_version -v
    show_version --version
    show_version -vl
}