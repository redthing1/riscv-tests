set -e -x

export PATH=$PATH:/opt/riscv/bin
git submodule update --init --recursive
autoconf
mkdir -p build
cd build
../configure
make