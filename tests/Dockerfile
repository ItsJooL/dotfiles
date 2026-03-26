FROM fedora:latest

# Install base dependencies that the dotfiles expect
RUN dnf install -y \
    git \
    curl \
    coreutils \
    findutils \
    gzip \
    unzip \
    tar \
    rsync \
    stow \
    sudo \
    which \
    diffutils \
    ShellCheck \
    && dnf clean all

# Install bats-core for test framework
RUN git clone --depth 1 https://github.com/bats-core/bats-core.git /tmp/bats-core && \
    /tmp/bats-core/install.sh /usr/local && \
    rm -rf /tmp/bats-core

# Install bats helpers
RUN git clone --depth 1 https://github.com/bats-core/bats-support.git /usr/local/lib/bats-support && \
    git clone --depth 1 https://github.com/bats-core/bats-assert.git /usr/local/lib/bats-assert

# Create a non-root test user (mirrors real usage)
RUN useradd -m -s /bin/bash testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Copy the dotfiles repo into the container
COPY --chown=testuser:testuser . /home/testuser/dotfiles

USER testuser
WORKDIR /home/testuser/dotfiles

CMD ["bats", "tests/"]
