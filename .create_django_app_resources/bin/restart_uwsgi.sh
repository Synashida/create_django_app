#!/bin/sh

HOME=$(dirname $(dirname $(cd $(dirname $0); pwd)))
. $HOME/bridge_data/bin/values

echo "stop uwsgi..."
$BINDIR/stop_uwsgi.sh
echo "stopped."

echo "start uwsgi..."
$BINDIR/start_uwsgi.sh
echo "finish."

