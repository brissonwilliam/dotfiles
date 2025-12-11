set -e 

mkdir -p ~/dev
cd ~/dev

if [[ -d "~/dev/ghostty" ]]; then
    echo "Git clone"
    git clone https://github.com/ghostty-org/ghostty.git
else
    echo Ghostty already exists in ~/dev
fi

cd ~/dev/ghostty

echo "Install deps"
sudo dnf install gtk4-devel zig libadwaita-devel blueprint-compiler gtk4-layer-shell-devel

echo "Starting build"
sudo zig build -p /usr -Doptimize=ReleaseFast
