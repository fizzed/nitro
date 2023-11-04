# Nitro OpenJDK Builds by Fizzed

mkdir ~/workspace/third-party
cd ~/workspace/third-party

sudo pkg install autoconf cups bash

# MUST USE BASH, FOR ENV VARs, etc.

git clone --depth=1 https://github.com/battleblow/jdk18u.git

cd jdk18u

export CPATH=/usr/local/include
export LIBRARY_PATH=/usr/local/include

bash configure --with-toolchain-type=clang --enable-headless-only --disable-warnings-as-errors --with-boot-jdk=/usr/local/openjdk-17

gmake clean images

