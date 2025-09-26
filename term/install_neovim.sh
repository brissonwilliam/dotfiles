#/bin/bash

set -e

sudo echo "Making sure you're sudo"

echo
echo "Installing Neovim"
curl "https://github.com/neovim/neovim/releases/download/v0.11.4/nvim-linux-x86_64.tar.gz" -L > ./nvim.tar.gz
tar xzf nvim.tar.gz 
mv nvim-linux-x86_64 nvim
sudo rm -rf /usr/local/nvim
sudo mv nvim/ /usr/local/nvim
rm nvim.tar.gz

echo "Done!"
echo "Run ./setup.sh to add configurations to installed apps"
