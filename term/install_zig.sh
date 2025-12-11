set -e

echo "Fetch"
url="https://ziglang.org/download/0.15.2/zig-x86_64-linux-0.15.2.tar.xz"
curl $url > zig.tar.xz

echo "Unzip"
tar xJf zig.tar.xz

echo "Cleanup tar"
rm zig.tar.xz

echo "Deploy"
sudo mv zig-x86_64* /usr/local/zig/
sudo ln -s /usr/local/zig/zig /usr/local/bin/zig
