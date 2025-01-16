FROM ghcr.io/illgrenoble/webx-dev-env-ubuntu:22.04

# Get and build latest stable WebX Engine
RUN git clone https://github.com/ILLGrenoble/webx-engine \
    && cd /app/webx-engine \
    && cmake . \
    && cmake --build . -j 4 --target webx-engine \
    && cp bin/webx-engine /usr/bin

RUN mkdir /var/log/webx

COPY run_standalone_webx_host.sh /usr/bin

ENTRYPOINT ["/usr/bin/run_standalone_webx_host.sh"]
