#!/usr/bin/env bats
# bats file_tags=server,command

setup_file() {
    load "$PROJECT_ROOT/test/helpers/bats_setup"

    export TEST_DIR_CACHE=$(mktemp -dp "$TMPDIR")

    export PARAM_HOST=URI=$(testServer)
    export PARAM_FILE_FUNC=FILE_GLOBAL_FUNC=$TEST_DIR_CACHE/global/functions.sh
    export PARAM_CACHE_PATH="CACHE_PATH=$TEST_DIR_CACHE"

}

setup() {
    load "$PROJECT_ROOT/test/helpers/bats_setup"
    loadAssert
    setSrcPath
}

teardown() {
    echo "status: ${status}"
    echo "output: ${output}"
}

launch_param() { run command.sh ${@}; }
launch_env() { launch_param "--env-file=${1}" ${@:2}; }

be_cached() { [[ -f "$TEST_DIR_CACHE/$1" ]]; }
be_cached_on() { [[ -f "$1/$2" ]]; }
no_cached() { [[ ! -f "$TEST_DIR_CACHE/$1" ]]; }
rm_cache() {
    [[ -f "$TEST_DIR_CACHE/$1" ]] && rm "$TEST_DIR_CACHE/$1"
    [[ -f "$TEST_DIR_CACHE/$1" ]] && return 1
    return 0
}

clear() {
    rm_cache usage/en/gene
    rm_cache global/cache.sh
}

@test "Should cache automatic with environment file" {
    ENV=$(getEnv "$PARAM_HOST"       \
                 "CACHEABLE=true"    \
                 "$PARAM_CACHE_PATH" \
                 "$PARAM_FILE_FUNC")
    clear
    launch_env $ENV
    assert_success
    be_cached usage/en/gene
    be_cached global/cache.sh
}

@test "Should fail when use option -C" {
    ENV=$(getEnv "$PARAM_HOST" \
                 "$PARAM_FILE_FUNC")
    launch_env $ENV -C
    assert_failure
    [[ "${lines[0]}" == *"Set cache path" ]]
}

@test "Should cache when use option -C" {
    ENV=$(getEnv "$PARAM_HOST"       \
                 "$PARAM_CACHE_PATH" \
                 "$PARAM_FILE_FUNC")
    clear
    launch_env $ENV -C
    assert_success
    be_cached usage/en/gene
    be_cached global/cache.sh
}

@test "Should change cache-path when use option -c or --cache-path" {
    ENV=$(getEnv "$PARAM_HOST"       \
                 "$PARAM_CACHE_PATH" \
                 "$PARAM_FILE_FUNC")

    SHORT_PARAM_PATH=$(mktemp -dp "$TEST_DIR_CACHE")
    clear
    launch_env $ENV -c $SHORT_PARAM_PATH
    assert_success
    no_cached usage/en/gene
    no_cached global/cache.sh
    be_cached_on $SHORT_PARAM_PATH usage/en/gene
    be_cached_on $SHORT_PARAM_PATH global/cache.sh

    LONG_PARAM_PATH=$(mktemp -dp "$TEST_DIR_CACHE")
    clear
    launch_env $ENV --cache-path=$LONG_PARAM_PATH
    assert_success
    no_cached usage/en/gene
    no_cached global/cache.sh
    be_cached_on $LONG_PARAM_PATH usage/en/gene
    be_cached_on $LONG_PARAM_PATH global/cache.sh

}