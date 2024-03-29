# Nitro OpenJDK Builds by Fizzed

## Overview

Optimized OpenJDK builds for riscv64 architecture!

Most popular ways of installing the JDK do not provide riscv64 builds. If they are provided (such as via debian or
ubuntu), as of 2023, those are with the "Zero VM" which runs in interpreted mode. That mode offers terrible performance.

As of Java 19, the JIT compiler has been ported to risv64, providing significant performance boosts compared to the
"Zero VM".

## Sponsorship & Support

![](https://cdn.fizzed.com/github/fizzed-logo-100.png)

Project by [Fizzed, Inc.](http://fizzed.com) (Follow on Twitter: [@fizzed_inc](http://twitter.com/fizzed_inc))

**Developing and maintaining opensource projects requires significant time.** If you find this project useful or need
commercial support, we'd love to chat. Drop us an email at [ping@fizzed.com](mailto:ping@fizzed.com)

Project sponsors may include the following benefits:

- Priority support (outside of Github)
- Feature development & roadmap
- Priority bug fixes
- Privately hosted continuous integration tests for their unique edge or use cases

## Install

To use a simple bootstrap script that installs the jdk to /usr/lib/jvm and sets up your PATH and environment variables:
    
    curl -s https://raw.githubusercontent.com/jjlauer/provisioning/master/linux/bootstrap-java.sh | sudo sh

Alternatively, just download the tarballs and do this yourself. They are all published to the "v1" release in this 
GitHub repository.

## Building

If you're interested in building this yourself, this repository is setup for an x86_64 host + docker.  There are some
automated scripts that will setup a docker container w/ the necessary dependencies to build the OpenJDK w/ the riscv64
toolchain, and cross compile it.  It takes around 3 minutes to build on an AMD 7950x.

    java -jar setup/blaze.jar setup/blaze.java build_containers
    java -jar setup/blaze.jar setup/blaze.java build_jdk19s
    
Once done building, the ./target/ directory will contain a .tar.gz ready for deployment.
