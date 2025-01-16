#!/bin/bash

cleanup() {
    echo -e "\nContainer stopped, performing cleanup..."
}

trap 'cleanup' SIGTERM
trap 'cleanup' SIGINT

# Run the WebX Router
/usr/bin/webx-router &

# Run the WebX Session Manager
/usr/bin/webx-session-manager &

echo "WebX multiuser host running"

wait $!

