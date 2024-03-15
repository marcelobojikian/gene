#!/usr/bin/env bash
##########################################################################
# Shellscript:	synopsis - installs module dependencies
# Author     :	Marcelo Nogueira <marcelo.bojikian@gmail.com>
# Date       :	2024-03-14
# Category   :	System Modules
##########################################################################
# Reference
# bats-core  : https://bats-core.readthedocs.io/en/stable/tutorial.html
##########################################################################
# Description
#   Installs the modules needed for the programme's code and tests
#
##########################################################################

set -e

################################################# variables

###########################################################

############################################## dependencies
for check in 'git' 'python3' ; do
    if ! which "$check" &> /dev/null
        then echo "Must have $check installed" && exit 1
    fi
done
###########################################################

################################################# functions
gitMudule() {
    git submodule add -f "https://github.com/$1.git third/$2"
}

###########################################################

################################################# Principal
gitMudule bats-core/bats-core bats
gitMudule bats-core/bats-support test_helper/bats-support
gitMudule bats-core/bats-assert test_helper/bats-assert
