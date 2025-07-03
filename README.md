# WebX Demo Deploy

This project is used to deploy the WebX Demo web application using Docker compose. The Demo application is composed of the Java backend [WebX Demo Server](https://github.com/ILLGrenoble/webx-demo-server) and the frontend [WebX Demo Client](https://github.com/ILLGrenoble/webx-demo-client).

The WebX Demo Server is provided to test the [WebX Relay](https://github.com/ILLGrenoble/webx-relay) which is Maven library that can be included in other web applications, providing a bridge between the WebX sockets (based on Zeromq) and the websockets used to pipe data to the client. 

The WebX Demo Client uses the [WebX Client](https://github.com/ILLGrenoble/webx-client) NPM library that renders the remote desktop to the user's browser, receiving desktop data from the websocket connected to the relay.

This deployment can be used as part of the [WebX Dev Workspace](https://github.com/ILLGrenoble/webx-dev-workspace) to connect to a running [WebX Engine](https://github.com/ILLGrenoble/webx-engine) or can be used to provide a full multi-user demo of the WebX stack thanks includes the [WebX Router](https://github.com/ILLGrenoble/webx-router), providing full login access to the WebX environment. 

## Deploy the demo for WebX Engine development environment

This project provides a simple way to test the WebX Engine (without explicitly running the WebX Relay and WebX Client libraries). You need to run the WebX Engine in <em>standalone</em> mode (meaning it is running in an unauthenticated mode and can be easily connected to). The deploy script provided in this project is then run as follows:

```bash
./deploy.sh -sh <host>
```

where `<host>` should be replaced with hostname of the machine where the WebX Engine is running.

If you are developing on the local machine you can connect with the command

```bash
./deploy.sh -sh host.docker.internal
```

The WebX Demo Server uses the internal host network to connect to WebX on local ports.

## Deploy the demo for multi-user access

If you have the full WebX server stack running (WebX Router and Engine) you can deploy the demo for multi-user access. The WebX server needs to be entered using the web interface and user's are requested to authenticate to create a WebX session on the server. 

To deploy the demo in this mode use the following command:

```bash
./deploy.sh
```

### SSL Certificates

The docker compose stacks runs an Nginx reverse proxy to redirect traffic to either the front end (path prefix `/`), the backend API (`/relay/api`) and the backend websocket (`/relay/ws`). HTTP requests are redirected to HTTPS. You can provide your own certificates (placing them in the `nginx/certs` folder, named `web.crt` and `web.key`) or you can let the deployment script generate self-signed certificates.

When running `deploy.sh`, the script determines if the certificates are present: if they are not it will automatically generate the self-signed ones.

## Stop the demo

To stop the demo (bringing down the docker compose stack) run the following command:

```bash
./deploy.sh -s
```

## Connecting to the WebX Demo

The Nginx reverse proxy runs on the standard 80/443 ports. If you're running the demo locally then just connect to https://localhost to see the demo in action.

If you're running in <em>standalone</em> mode you'll see the hostname of the WebX Engine server: all you need to do is connect.

If you're running in a multi-user environment then you'll have to specify the host of the WebX Server and specify the username and password.

## Running the demo with pre-configured WebX Host

To simplify the deployment of the full WebX Remote Desktop stack on a server, this project contains a couple of Dockerfiles to build and launch a containerised WebX Host with either a multiuser environment or a standalone WebX Engine.

### Using the multiuser environment

Go to the `webx-host` folder then build and run the multiuser WebX host:

```
cd webx-host
docker build -t webx-host-multiuser -f webx-host-multiuser.dockerfile .
docker run --rm --name webx-host-multiuser -p 5555-5558:5555-5558 webx-host-multiuser
```

In the container the WebX Router is running and waiting for connection requests.

You can then run the demo is multiuser mode:

```
cd ..
./deploy.sh
```

Open a browser at https://localhost and enter the host `host.docker.internal`. For the username and password you can choose from the preconfigured users of the webx-host container (mario, luigi, peach, toad, yoshi and bowser) - the password is the same as the username.

### Using the standalone environment

Go to the `webx-host` folder then build and run the standalone WebX host:

```
cd webx-host
docker build -t webx-host-standalone -f webx-host-standalone.dockerfile .
docker run --rm --name webx-host-standalone -p 5555-5558:5555-5558 webx-host-standalone
```

In the container Xorg and the Xfce window manager have been launched. A WebX Engine is running too waiting for connection events.

You can then run the demo is standalone mode:

```
cd ..
./deploy.sh -sh host.docker.internal
```

Open a browser at https://localhost and connect to the WebX Remote Desktop.



