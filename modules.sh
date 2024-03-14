#!/usr/bin/env bash
##########################################################################
# Shellscript:	synopsis - installs module dependencies
# Author     :	Heiner Steven <heiner.steven@odn.de>
# Date       :	2024-03-14
# Category   :	System Test
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

################################################# functions
gitMudule() {
    git submodule add -f "https://github.com/$1.git third/$2"
}

###########################################################

############################################## dependencies
for check in 'git' ; do
    if ! which "$check" &> /dev/null
        then echo "Must have $check installed" && exit 1
    fi
done
###########################################################

################################################# Principal
gitMudule bats-core/bats-core bats
gitMudule bats-core/bats-support test_helper/bats-support
gitMudule bats-core/bats-assert test_helper/bats-assert
