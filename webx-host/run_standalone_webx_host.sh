#!/bin/bash

cleanup() {
    echo -e "\nContainer stopped, performing cleanup..."
    /usr/bin/run_wm.sh -s
}

trap 'cleanup' SIGTERM
trap 'cleanup' SIGINT

## Run default window manager
/usr/bin/run_wm.sh $@ &

sleep 5

# Run the WebX Engine
DISPLAY=:20 /usr/bin/webx-engine -s &

wait $!

