#!/usr/bin/env bash

# Very simple templating system that replaces {{VAR}} by the value of $VAR.
# Supports default values by writting {{VAR=value}} in the template.

# Replaces all {{VAR}} by the $VAR value in a template file and outputs it

readonly PROGNAME=$(basename $0)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Usage string
usage="
Usage:
  ${PROGNAME} -h|--help
  ${PROGNAME} [-c|--config config_file] template_file [...template_file]

Options:
  -h --help    Show this help text
  -c --config  Specify config file
"

# Declare storage
declare -A TOKENS
declare -A TEMPLATES
INDEX=0

# Parse arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help)
      echo "$usage"
      exit 0
      ;;
    -c|--config)
      shift
      if [[ -f "${1}" ]]; then
        while IFS='=' read key value; do
          TOKENS["$key"]="$value"
        done <<< "$(${DIR}/ini.sh ${1})"
      fi
      ;;
    *)
      if [[ -f "${1}" ]]; then
        TEMPLATES[$INDEX]="${1}"
        INDEX=$(( $INDEX + 1 ))
      fi
      ;;
  esac
  shift
done

# Cancel if we have no config files
if [ "${INDEX}" -eq 0 ]; then
  echo "ERROR: You need to specify a template file" >&2
  echo "$usage"
  exit 1
fi

# Replace tokens by values
for templatefile in "${TEMPLATES[@]}"; do
  CONTENT=$(cat $templatefile);
  for token in "${!TOKENS[@]}"; do
    CONTENT=${CONTENT//"{{$token}}"/"${TOKENS[$token]}"}
  done
  echo -e "$CONTENT"
done
