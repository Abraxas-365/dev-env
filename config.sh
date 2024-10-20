
#!/bin/bash

set -e

install_langs=false

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --install-langs) install_langs=true ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Update and install essential packages
sudo apt-get update
sudo apt-get install -y curl wget git build-essential software-properties-common gcc make pkg-config libssl-dev unzip ninja-build gettext libtool libtool-bin autoconf automake cmake g++ doxygen zsh tmux mosh

if [ "$install_langs" = true ] ; then
    echo "Installing programming languages..."

    # Install Rust
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env

    # Install Go
    wget https://golang.org/dl/go1.21.3.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go1.21.3.linux-amd64.tar.gz
    rm go1.21.3.linux-amd64.tar.gz
    echo 'export PATH=$PATH:/usr/local/go/bin' >> $HOME/.zshrc

    # Install Node.js
    curl -fsSL https://nodejs.org/dist/v18.18.2/node-v18.18.2-linux-x64.tar.xz | sudo tar -xJ -C /usr/local --strip-components=1
    sudo ln -s /usr/local/bin/node /usr/local/bin/nodejs

    # Install Bun
    curl -fsSL https://bun.sh/install | bash
    echo 'export PATH=$HOME/.bun/bin:$PATH' >> $HOME/.zshrc
else
    echo "Skipping installation of programming languages..."
fi

# Install Neovim
git clone https://github.com/neovim/neovim.git --branch release-0.9 /tmp/neovim
cd /tmp/neovim
make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install
cd -
rm -rf /tmp/neovim

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Set Zsh as the default shell
sudo chsh -s $(which zsh) $USER

# Copy configuration files
cp -r $HOME/dev-env/.tmux $HOME/
cp $HOME/dev-env/.tmux.conf $HOME/
cp $HOME/dev-env/.tmux.conf.local $HOME/
cp $HOME/dev-env/.zshrc $HOME/
mkdir -p $HOME/.local/bin
cp -r $HOME/dev-env/bin/* $HOME/.local/bin/
mkdir -p $HOME/.env/nvim
cp -r $HOME/dev-env/nvim/* $HOME/.config/nvim/

# Ensure the PATH is updated in .zshrc
echo 'export PATH=$HOME/.local/bin:$PATH' >> $HOME/.zshrc

# Clean up
rm -rf $HOME/dev-config

echo "Development environment setup complete!"
echo "Please log out and log back in for all changes to take effect."
