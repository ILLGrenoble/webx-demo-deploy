# WebX Demo Deploy

This project is used to deploy the WebX Demo web application using Docker compose. The Demo application is composed of the Java backend [WebX Demo Server](https://github.com/ILLGrenoble/webx-demo-server) and the frontend [WebX Demo Client](https://github.com/ILLGrenoble/webx-demo-client).

The WebX Demo Server is provided to test the [WebX Relay](https://github.com/ILLGrenoble/webx-relay) which is Maven library that can be included in other web applications, providing a bridge between the WebX sockets (based on Zeromq) and the websockets used to pipe data to the client. 

The WebX Demo Client uses the [WebX Client](https://github.com/ILLGrenoble/webx-client) NPM library that renders the remote desktop to the user's browser, receiving desktop data from the websocket connected to the relay.

This deployment can be used as part of the [WebX Engine development environment](https://github.com/ILLGrenoble/webx-dev-env) to connect to a running [WebX Engine](https://github.com/ILLGrenoble/webx-engine) or can be used to provide a full multi-user demo of the WebX stack including the [WebX Router](https://github.com/ILLGrenoble/webx-router) and [WebX Session Manager](https://github.com/ILLGrenoble/webx-session-manager) which provide full login access to the WebX environment. 

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

If you have the full WebX server stack running (WebX Router, Session Manager and Engine) you can deploy the demo for multi-user access. The WebX server needs to be entered using the web interface and user's are requested to authenticate to create a WebX session on the server. 

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

