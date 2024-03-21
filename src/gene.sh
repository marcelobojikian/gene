#!/usr/bin/env bash
##########################################################################
# Shellscript:	synopsis - execute gene software
# Author     :	Marcelo Nogueira <marcelo.bojikian@gmail.com>
# Date       :	2024-03-20
# Category   :	System Main
##########################################################################
# Reference
# Gene       : https://github.com/marcelobojikian/gene
##########################################################################
# Description
#   Install and run modules independent of other repositories
#
##########################################################################

################################################# variables
readonly VERSION=1.0
readonly IMPORT_PATH=$HOME/.gene/import
readonly LANG=$(locale | grep LANGUAGE | cut -d= -f2 | cut -d_ -f1)
###########################################################

############################################## dependencies
for check in "curl" ; do
    if ! which "$check" > /dev/null 2>&1
        then echo "Must have $check installed" && exit 1
    fi
done
###########################################################

################################################# functions
version() { echo "Version: $VERSION" && exit 0; }
usage() {
  cat <<"EOF"
Usage: gene [OPTIONS] COMMAND

Commands:
  import <name> <github>   Add modules from github (https://github.com/user/project or
                           user/project); All files are installed on ~/.gene/import

Options:
  -h, --help               Show this message
  -v, --version            Print version information and quit

Run 'gene COMMAND -h' for more information on a command.
For more details, see man gene.
EOF
  exit 0; 
}
die() { printf "%s\nTry 'gene -h' for more information.\n" "${@}" && exit 1 ; }

download() { # ${1} URL; ${2} FILE
  tempFile=$(mktemp -u)
  httpCodeResponse=$(curl -sLo "${tempFile}" -w "%{http_code}" "${1}")
  [ "${httpCodeResponse}" -ne 200 ] && printf "%s\n" "Invalid URL: $1" && exit 1
  [ -f "$tempFile" ] && install -D -m 755 "$tempFile" "${2}"
}

importer() { # ${1} command-name; ${2} command-url

  commandName=${1:?"Command name not defined"}
  commandUrl=${2:?"Github url not defined"}

  withoutPrefix=$(echo "$commandUrl" | sed -e 's/https\:\/\/github.com\///')
  projectDir=$(echo "$withoutPrefix" | cut -d '/' -f 1,2)

  githubCommand=$(printf "https://github.com/%s/raw/main/src/%s" "${projectDir}" "${commandName}")
  # githubUsage=$(printf "https://github.com/%s/raw/main/usage/${LANG}/%s" "${projectDir}" "${commandName}")

  projcetFile="${IMPORT_PATH}/${projectDir}/src/${commandName}"
  # projcetUsage="${IMPORT_PATH}/${projectDir}/usage/${LANG}/${commandName}"
  
  download "${githubCommand}" "${projcetFile}"

}

launch() {

  [ -z "$1" ] && usage && return 0;

  target=$1

  [ "$target" = "import" ] && importer "$2" "$3" && return 0

  for module in "${IMPORT_PATH}"/*/*
  do
    if [ -f "${module}/src/${target}" ] ; then
      # shellcheck source=/dev/null
      . "${module}/src/${target}" "${@:2}"
      return 0
    fi
  done

  echo "Command not found: ${target}" && exit 1

}

###########################################################

################################################# Principal

while getopts ':vh-:' OPTION ; do
    case "$OPTION" in
    h ) usage  ;;
    v ) version ;;
    - ) [ $OPTIND -ge 1 ] && optind=$((OPTIND - 1 )) || optind=$OPTIND
         eval OPTION="\$$optind"
         OPTARG=$(echo "$OPTION" | cut -d'=' -f2)
         OPTION=$(echo "$OPTION" | cut -d'=' -f1)
         case $OPTION in
            --help) usage ;;
            --version) version ;;
            * ) die "Invalid option: $OPTARG ";;
         esac
       OPTIND=1
       shift
      ;;
    ? ) die "Invalid option: $OPTARG " ;;
    esac
done

launch "$@"