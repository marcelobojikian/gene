#!/usr/bin/env bash

git submodule add -f https://github.com/bats-core/bats-core.git third/bats
git submodule add -f https://github.com/bats-core/bats-support.git third/test_helper/bats-support
git submodule add -f https://github.com/bats-core/bats-assert.git third/test_helper/bats-assert