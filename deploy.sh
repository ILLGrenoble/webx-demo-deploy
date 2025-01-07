#!/bin/bash

usage() {
	echo "deploy.sh [options]"
	echo
	echo "Options and equivalent environment variables:"
	echo "  -r   or --restart                                              restart all the docker images"
	echo "  -sh  or --standalone-host <host>      WEBX_STANDALONE_HOST     start the demo in standalone mode"
	echo "  -s   or --stop                                                 stop all the docker images"
}

# Function to determine which docker compose command to use
get_docker_compose_cmd() {
    if command -v docker > /dev/null && docker compose version > /dev/null 2>&1; then
        echo "docker compose"
    elif command -v docker-compose > /dev/null; then
        echo "docker-compose"
    else
        echo "Error: Neither 'docker compose' nor 'docker-compose' is available on this machine." >&2
        exit 1
    fi
}

# Get the appropriate docker compose command
DOCKER_COMPOSE_CMD=$(get_docker_compose_cmd)

# Parse command line arguments
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
	-r|--restart)
	RESTART_DOCKER_IMAGES=1
	shift
	;;

	-sh|--standalone-host)
	WEBX_STANDALONE_HOST="$2"
	STANDALONE="-f standalone.override.yml"
	shift
	shift
	;;

	-s|--stop)
	STOP_DOCKER_IMAGES=1
	shift
	;;

	*)
	break
	;;
esac
done

# Verify env file parameter
if [[ ! -f .env ]]; then
	echo "Creating a .env file. You can use this, for example, to specify the WEBX_VERSION environment variable."
  touch .env
fi

SSL_CRT_LOCATION=nginx/certs/web.crt
SSL_KEY_LOCATION=nginx/certs/web.key

# Verify SSL certificate and key are available
if [[ ! -f "$SSL_KEY_LOCATION" || ! -f "$SSL_CRT_LOCATION" ]]; then
	echo "Generating SSL certificate and key"

	openssl req -x509 -nodes -days 36500 -newkey rsa:2048 -keyout $SSL_KEY_LOCATION -out $SSL_CRT_LOCATION -subj "/CN=*"
fi

# Stop current containers if restart or stop
if [ "$RESTART_DOCKER_IMAGES" == 1 ] || [ "$STOP_DOCKER_IMAGES" == 1 ]; then
	echo "Stopping all docker images"
	$DOCKER_COMPOSE_CMD --env-file .env down
fi

# Pull and start all containers if not stop command
if [ -z "$STOP_DOCKER_IMAGES"  ]; then
	echo "Pulling latest docker images"
	# Pull latest images
	$DOCKER_COMPOSE_CMD --env-file .env pull

	# Run new containers
	echo "Starting docker containers"
	WEBX_STANDALONE_HOST=${WEBX_STANDALONE_HOST} $DOCKER_COMPOSE_CMD --env-file .env -f docker-compose.yml ${STANDALONE} up -d
fi

