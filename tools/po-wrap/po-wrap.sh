#!/bin/sh

_usage() {
  cat <<EOF
usage: po-wrap file [width]
EOF
}

which msgcat > /dev/null

if [ $? -ne 0 ]; then
  echo "msgcat not found";
  exit 1;
fi

if [ $# -eq 0 ]; then
  echo $#
  _usage;
  exit 1;
fi

file=$1
width=${2:-80}

msgcat -w ${width} ${file} > tmp
mv tmp ${file}
