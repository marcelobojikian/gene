#!/usr/bin/env bash

loadSupport() { load "$PROJECT_ROOT/third/test_helper/bats-support/load"; }
loadAssert() { load "$PROJECT_ROOT/third/test_helper/bats-assert/load"; }
loadMethods() { . "$PROJECT_ROOT/src/${1}"; }

testServer() { echo http://localhost:8000; }

setSrcPath() { PATH="$PROJECT_ROOT/src:$PATH"; }
setPath() { PATH="$PROJECT_ROOT/src/${1}:$PATH"; }

