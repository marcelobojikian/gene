#!/usr/bin/env bash

_setup() {
    load "$PROJECT_ROOT/third/test_helper/bats-support/load"
    load "$PROJECT_ROOT/third/test_helper/bats-assert/load"  
    PATH="$PROJECT_ROOT/src:$PATH"
}

_path() {
    load "$PROJECT_ROOT/third/test_helper/bats-support/load"
    load "$PROJECT_ROOT/third/test_helper/bats-assert/load"  
    PATH="$PROJECT_ROOT/src/${1}:$PATH"
}

methods() {
    load "$PROJECT_ROOT/third/test_helper/bats-support/load"
    load "$PROJECT_ROOT/third/test_helper/bats-assert/load" 
    source "$PROJECT_ROOT/src/${1}"
}

server() {
    echo http://localhost:8000
}
