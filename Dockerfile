#k Start with Ubuntu as the base image
FROM ubuntu:latest

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive
# Update and install essential packages and Neovim build dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    software-properties-common \
    gcc \
    make \
    pkg-config \
    libssl-dev \
    unzip \
    ninja-build \
    gettext \
    libtool \
    libtool-bin \
    autoconf \
    automake \
    cmake \
    g++ \
    pkg-config \
    doxygen \
    zsh \
    tmux \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install Go
RUN wget https://golang.org/dl/go1.21.3.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go1.21.3.linux-amd64.tar.gz \
    && rm go1.21.3.linux-amd64.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"

# Install Node.js manually
RUN curl -fsSL https://nodejs.org/dist/v18.18.2/node-v18.18.2-linux-x64.tar.xz | tar -xJ -C /usr/local --strip-components=1 \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"

# Clone Neovim 0.9 and build from source
RUN git clone https://github.com/neovim/neovim.git --branch release-0.9 /tmp/neovim \
    && cd /tmp/neovim \
    && make CMAKE_BUILD_TYPE=RelWithDebInfo \
    && make install \
    && rm -rf /tmp/neovim

# Install Oh My Zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Set Zsh as the default shell
RUN chsh -s $(which zsh)

# Copy configuration files
COPY .tmux /root/.tmux
COPY .tmux.conf /root/.tmux.conf
COPY .tmux.conf.local /root/.tmux.conf.local
COPY .zshrc /root/.zshrc
COPY bin /root/.local/bin
COPY nvim /root/.config/nvim

# Set the working directory
WORKDIR /root

# Ensure all environment variables are available in non-interactive shells
RUN echo "export PATH=$PATH" >> /root/.zshrc

# Set the default command to zsh
CMD ["zsh"]
