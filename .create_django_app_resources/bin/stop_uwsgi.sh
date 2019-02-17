#!/bin/sh

# valuesファイルをインクルード
HOME=$(dirname $(dirname $(cd $(dirname $0); pwd)))
. $HOME/bridge_data/bin/values

if [ -e $WSGIPID ]; then
  while read line
  do
    echo "stop pid ${line}"
    kill -KILL $line
  done < $WSGIPID

  rm $WSGIPID
fi

