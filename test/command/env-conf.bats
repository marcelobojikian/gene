#!/usr/bin/env bats
# bats file_tags=server,command

setup_file() {
    load "$PROJECT_ROOT/test/helpers/bats_setup"
    loadThirdHelpers
    setSrcPath

    local HOST=$(testServer)

    export ENV_EMPTY=$(getEnv "URI="        \
                              "CACHEABLE="  \
                              "CACHE_PATH=" \
                              "LOG_LEVEL="  \
                              "FILE_GLOBAL_FUNC=")

    export ENV_MIN=$(getEnv "URI=$HOST")

    export CACHE_DIR=$(mktemp -d)
    export ENV_FILE=$(getEnv "URI=$HOST"      \
                             "CACHEABLE=true" \
                             "CACHE_PATH=$CACHE_DIR")

}

teardown_file() {
    rm -rf "$CACHE_DIR"
    rm -f "$ENV_EMPTY"
    rm -f "$ENV_MIN"
    rm -f "$ENV_FILE"
}

setup() {
    load "$PROJECT_ROOT/test/helpers/bats_setup"
    loadThirdHelpers
    echo "------ env ------ $ENV_FILE"
    cat $ENV_FILE
    echo "-----------------"
    echo "------ env ------ $ENV_MIN"
    cat $ENV_MIN
    echo "-----------------"
    echo "------ env ------ $ENV_EMPTY"
    cat $ENV_EMPTY
    echo "-----------------"
}

teardown() {
    echo "CACHE_DIR: ${CACHE_DIR}"
    echo "ENV_EMPTY: ${ENV_EMPTY}"
    echo "ENV_MIN: ${ENV_MIN}"
    echo "ENV_FILE: ${ENV_FILE}"
    echo "status: ${status}"
    echo "output: ${output}"
}

launch_param() {
    run command.sh ${@}
}

launch_env() {
    run command.sh "--env-file=${1}" ${@:2}
}

launch_default() {
    launch_env $ENV_FILE $@
}

@test "Should fail when configure file is invalid" {
    local TEST_FILE=$(mktemp -up "$CACHE_DIR")
    launch_env "$TEST_FILE"
    assert_failure
    assert_line "Invalid configuration file: $TEST_FILE"
}

@test "Should fail when variable URI is empty" {
    launch_env "$ENV_EMPTY"
    assert_failure
    assert_line "Unknown uri, use option --uri to set valid url."
}

@test "Should fail when URI is invalid" {
    local URI=http://invalid.uri
    launch_env $(getEnv "URI=$URI")
    assert_failure
    assert_line "Url invalida: $URI"
}

@test "Should show usage message when URI is OK" {
    launch_env "$ENV_MIN"
    assert_success
    assert_line 'Usage: gene [OPTIONS] COMMAND'
}