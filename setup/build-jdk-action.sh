#!/bin/sh -l
# Use a shell as though we logged in

BASEDIR=$(dirname "$0")
cd "$BASEDIR/.." || exit 1
PROJECT_DIR=$PWD

BUILDOS=$1
BUILDARCH=$2

echo "Build OS: ${BUILDOS}"
echo "Build Arch: ${BUILDARCH}"

if [ -z "${BUILDOS}" ] || [ -z "${BUILDOS}" ]; then
  echo "Usage: script [os] [arch]"
  exit 1
fi

mkdir -p target
cd target

# we drive everything in our build off a tagged version in the openjdk repository
REPO_TAG="19+36"

if [ "$REPO_TAG" = "19+36" ]; then
  # what does oracle claim this tag represents?
  BUILD_MAJOR=19
  BUILD_MINOR=0
  BUILD_PATCH=1
  BUILD_BUILD=10
else
  echo "Unsupported openjdk repo tag ${REPO_TAG}. You need to tweak the build-jdk-action.sh script for this tag!"
fi

# generate our own tag with no + char
VERSION_TAG=$(echo "$REPO_TAG" | sed -e "s/+/\./g");

# we always generate our vendor version off the openjdk tag
#https://cdn.azul.com/zulu/bin/zulu19.30.11-ca-jdk19.0.1-linux_x64.tar.gz
BUILD_VERSION_STRING="Fizzed${VERSION_TAG}"
BUILD_ARCHIVE_NAME="fizzed${VERSION_TAG}-jdk${BUILD_MAJOR}.${BUILD_MINOR}.${BUILD_PATCH}-${BUILDOS}_${BUILDARCH}"

echo "Wil build archive: ${BUILD_ARCHIVE_NAME}"

# checkout jdk
JDK_DIR="jdk-${REPO_TAG}"
if [ ! -d "$JDK_DIR" ]; then
  #git clone --depth=1 -b jdk-19+36 https://github.com/openjdk/jdk.git jdk19
  # is this 19.0.1 ===  19.28 ?
  git clone --depth=1 -b "jdk-${REPO_TAG}" https://github.com/openjdk/jdk.git "$JDK_DIR"
fi
cd "$JDK_DIR"


# NOTE: http://cr.openjdk.java.net/~fyang/openjdk-riscv-port/BuildRISCVJDK.md
# add riscv toolchain to PATH and LD_LIBRARY_PATH
export RISCV64=/opt/riscv_toolchain_linux
export LD_LIBRARY_PATH=$RISCV64/lib64:/usr/local/gcc/lib64:/usr/local/gcc/lib
export PATH="$RISCV64/bin:$PATH"
export CC=$RISCV64/bin/riscv64-unknown-linux-gnu-gcc
export CXX=$RISCV64/bin/riscv64-unknown-linux-gnu-g++

# clean build every time
rm -Rf build
chmod +x ./configure

#./configure --help
#exit 1

# Other flags that could potentially be added
# --enable-headless-only
#
# How is the version generated?
# openjdk 19.0.1 2022-10-18
# OpenJDK Runtime Environment Zulu19.30+11-CA (build 19.0.1+10)
# OpenJDK 64-Bit Server VM Zulu19.30+11-CA (build 19.0.1+10, mixed mode, sharing)
# the 19.0.1 is from the feature/interim/update values
# the build of 19.0.1+10 is the "build" value, which from what I can see does not correlated to openjdk tagged versions
# the Zulu19.30+11-CA is entirely the "vendor version string"
./configure --openjdk-target=riscv64-unknown-linux-gnu \
  --with-sysroot=/opt/fedora28_riscv_root \
  --with-jvm-variants=server \
  --enable-unlimited-crypto \
  --with-build-user=Fizzed \
  --with-vendor-name=Fizzed \
  --with-version-pre="" \
  --with-version-opt="" \
  --with-version-feature=$BUILD_MAJOR \
  --with-version-interim=$BUILD_MINOR \
  --with-version-update=$BUILD_PATCH \
  --with-version-build=$BUILD_BUILD \
  --with-vendor-version-string=$BUILD_VERSION_STRING \
  --with-vendor-url=http://fizzed.com \
  BUILD_CC=/usr/local/gcc/bin/gcc-7.5 \
  BUILD_CXX=/usr/local/gcc/bin/g++-7.5

CONF=linux-riscv64-server-release make clean images

# https://cdn.azul.com/zulu/bin/zulu19.30.11-ca-jdk19.0.1-linux_x64.tar.gz
# https://cdn.azul.com/zulu/bin/zulu19.30.11-ca-jdk19.0.1-linux_aarch64.tar.gz
# helpful script for how this is packaged https://github.com/AdoptOpenJDK/openjdk11-upstream-binaries/blob/master/build-openjdk11.sh
cd build
mv linux-riscv64-server-release/images/jdk "${BUILD_ARCHIVE_NAME}"
tar -c -f ${BUILD_ARCHIVE_NAME}.tar --exclude='**.debuginfo' "${BUILD_ARCHIVE_NAME}"
gzip ${BUILD_ARCHIVE_NAME}.tar

mv ${BUILD_ARCHIVE_NAME}.tar.gz ../../

RELEASE_TGZ="${BUILD_ARCHIVE_NAME}.tar.gz"

echo "Built $PWD/$RELEASE_TGZ"