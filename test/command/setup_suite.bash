#!/usr/bin/env bats

setup_suite() {
    export TMPDIR=$(mktemp -dt bats-gene-XXXXXX)
}

teardown_suite() {
    rm -rf "$TMPDIR"
}