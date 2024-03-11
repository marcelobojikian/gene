#!/usr/bin/env bash
# https://bats-core.readthedocs.io/en/stable/tutorial.html

export PROJECT_ROOT="$( cd "$(pwd)/.." >/dev/null 2>&1 && pwd )"

../third/bats/bin/bats -p global/cache
