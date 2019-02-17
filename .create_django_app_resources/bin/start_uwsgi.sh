#!/bin/sh

# valuesファイルをインクルード
HOME=$(dirname $(dirname $(cd $(dirname $0); pwd)))
. $HOME/bridge_data/bin/values

# カレントディレクトリをHOMEに移動
cd $HOME

# uwsgiの起動
if [ -e $WSGI_INI ]; then
  uwsgi --ini $WSGI_INI
fi
