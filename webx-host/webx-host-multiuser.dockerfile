FROM ghcr.io/illgrenoble/webx-dev-env-ubuntu:22.04

# Install dependencies
RUN apt install -y apt-utils libclang-dev libpam-dev clang

# Install webx user
RUN addgroup --system --quiet webx \
 && adduser --system --quiet --ingroup webx --no-create-home --home /nonexistent webx

# Install Rust
RUN curl https://sh.rustup.rs -sSf > /tmp/rustup-init.sh \
    && chmod +x /tmp/rustup-init.sh \
    && sh /tmp/rustup-init.sh -y \
    && rm -rf /tmp/rustup-init.sh

RUN ~/.cargo/bin/rustup default nightly

# Create standard users
RUN useradd -m -U -s /bin/bash -p $(openssl passwd -6 'mario') mario \
    && useradd -m -U -s /bin/bash -p $(openssl passwd -6 'luigi') luigi \
    && useradd -m -U -s /bin/bash -p $(openssl passwd -6 'peach') peach \
    && useradd -m -U -s /bin/bash -p $(openssl passwd -6 'toad') toad \
    && useradd -m -U -s /bin/bash -p $(openssl passwd -6 'bowser') bowser \
    && useradd -m -U -s /bin/bash -p $(openssl passwd -6 'yoshi') yoshi

# Update X config to allow creation of Xorg and xfce4 desktop manager by non-root user
RUN sed -i 's/console/anybody/g' /etc/X11/Xwrapper.config \
    && echo "needs_root_rights = no" | tee -a /etc/X11/Xwrapper.config \
    && cp /etc/X11/xrdp/xorg.conf /etc/X11/xorg.conf

RUN mkdir /var/log/webx \
    && mkdir -p /etc/webx/webx-session-manager

# Get and build latest stable WebX Engine
RUN git clone https://github.com/ILLGrenoble/webx-engine \
    && cd /app/webx-engine \
    && cmake . \
    && cmake --build . -j 4 --target webx-engine \
    && cp bin/webx-engine /usr/bin

# Get and build latest stable WebX Router
RUN git clone https://github.com/ILLGrenoble/webx-router \
    && cd /app/webx-router \
    && ~/.cargo/bin/cargo build --release \
    && cp target/release/webx-router /usr/bin/webx-router \
    && cp config.yml /etc/webx/webx-router-config.yml

# Get and build latest stable WebX Session Manager
RUN git clone https://github.com/ILLGrenoble/webx-session-manager \
    && cd /app/webx-session-manager \
    && ~/.cargo/bin/cargo build --release \
    && cp target/release/server /usr/bin/webx-session-manager \
    && cp config.example.yml /etc/webx/webx-session-manager-config.yml \
    && cp bin/pam-webx /etc/pam.d/webx \
    && cp bin/startwm.sh /etc/webx/webx-session-manager/startwm.sh

# Update X config to allow creation of xfce4 desktop manager
RUN sed -i 's/startxfce4/dbus-launch startxfce4/g' /etc/webx/webx-session-manager/startwm.sh \
    && sed -i 's|/etc/X11/xrdp/xorg.conf|xorg.conf|g' /etc/webx/webx-session-manager-config.yml \
    && sed -i 's/console/anybody/g' /etc/X11/Xwrapper.config \
    && echo "needs_root_rights = no" | tee -a /etc/X11/Xwrapper.config \
    && cp /etc/X11/xrdp/xorg.conf /etc/X11/xorg.conf

COPY run_multiuser_webx_host.sh /usr/bin

ENTRYPOINT ["/usr/bin/run_multiuser_webx_host.sh"]
