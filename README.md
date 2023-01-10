# Nitro OpenJDK Builds by Fizzed

Optimized OpenJDK builds for riscv64 architecture!

Most popular ways of installing the JDK do not provide riscv64 builds. If they are provided (such as via debian or
ubuntu), as of 2023, those are with the "Zero VM" which runs in interpreted mode. That mode offers terrible performance.

As of Java 19, the JIT compiler has been ported to risv64, providing significant performance boosts compared to the
"Zero VM".

## Install

To use a simple bootstrap script that installs the jdk to /usr/lib/jvm and sets up your PATH and environment variables:

    curl -O https://raw.githubusercontent.com/jjlauer/provisioning/master/linux/bootstrap-java.sh
    chmod +x bootstrap-java.sh
    ./bootstrap-java.sh --default --url=https://github.com/fizzed/nitro/releases/download/builds/fizzed19.36-jdk19.0.1-linux_riscv64.tar.gz
    rm -f ./bootstrap-java.sh

Alternatively, just download the tarballs and do this yourself. They are all published to the "v1" release in this 
GitHub repository.