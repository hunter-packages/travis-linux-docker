# https://docs.travis-ci.com/user/common-build-problems/#Running-a-Container-Based-Docker-Image-Locally

# From top of the travis log:
#
#   instance: travis-job-8e411e98-ed41-4479-86ab-ab46e24a6bd4 travis-ci-sardonyx-xenial-1547455603-2c98a19 (via amqp)
#
# Go to https://hub.docker.com/r/travisci
# -> https://hub.docker.com/r/travisci/ci-sardonyx
#
# Using tag from https://hub.docker.com/r/travisci/ci-sardonyx/tags/ because tag 'latest' not found
# (see issue https://github.com/travis-ci/travis-ci/issues/7518)

FROM travisci/ci-sardonyx:packer-1547455648-2c98a19

MAINTAINER Ruslan Baratov <ruslan_baratov@yahoo.com>

USER travis

# From '.travis.yml':
# sources:
#   - ubuntu-toolchain-r-test
RUN sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test

RUN sudo apt-get update

ENV PATH /usr/local/clang-7.0.0/bin:$PATH

# From '.travis.yml':
# packages:
#   - g++-7
RUN sudo apt-get -y install g++-7

# From '.travis.yml':
# packages:
#   - gfortran
RUN sudo apt-get -y install gfortran
RUN sudo apt-get -y install gfortran-7

# Dependencies for Qt:
# * https://github.com/ruslo/hunter/wiki/pkg.qt#pitfalls
RUN sudo apt-get install -y libegl1-mesa-dev libgl1-mesa-dev libegl1-mesa-drivers

# Travis also install glu:
# * https://github.com/travis-ci-tester/travis-test-linux-glu
RUN sudo apt-get install -y libglu1-mesa-dev

# Dependencies for Qt Android development:
# * http://superuser.com/a/360398/252568
RUN sudo dpkg --add-architecture i386

# Install pip3
RUN sudo apt-get install -y python3-pip

RUN sudo apt-get install libncurses5:i386 libstdc++6:i386 zlib1g:i386

# For upload
RUN pip3 install --user requests
RUN pip3 install --user gitpython

# Install CUDA {
WORKDIR /home/travis

ENV CUDA_INSTALL_PATH /usr/local/cuda-10.0/
RUN sudo mkdir -p ${CUDA_INSTALL_PATH}
RUN wget https://developer.nvidia.com/compute/cuda/10.0/Prod/local_installers/cuda_10.0.130_410.48_linux -O cuda-install.run
RUN chmod +x cuda-install.run
RUN sudo ./cuda-install.run --silent --toolkit --toolkitpath=${CUDA_INSTALL_PATH}
ENV PATH ${CUDA_INSTALL_PATH}/bin:${PATH}
# }

# Dirty hack to fix mxnet compile error:
# * OSError: libcuda.so.1: cannot open shared object file: No such file or directory
RUN sudo ln -s /usr/local/cuda-10.0/lib64/stubs/libcuda.so /usr/lib/x86_64-linux-gnu/libcuda.so.1

# Install tools
WORKDIR /home/travis

# Install Hunter repo with testing fork
RUN git clone https://github.com/ruslo/hunter

WORKDIR /home/travis/hunter
RUN git submodule update --init gate

RUN git remote add ci https://github.com/ingenue/hunter
RUN git fetch ci
RUN git branch --track pkg.template ci/pkg.template

# Install Polly toolchains
WORKDIR /home/travis

RUN git clone https://github.com/ruslo/polly
WORKDIR /home/travis/polly

ENV PATH /home/travis/polly/bin:$PATH

WORKDIR /home/travis

ENV TOOLCHAIN android-ndk-r17-api-24-arm64-v8a-clang-libcxx14 # for NDK downloading
RUN install-ci-dependencies.py

ENV TOOLCHAIN ""

ENV PATH /home/travis/_ci/cmake/bin:$PATH
ENV ANDROID_NDK_r17 /home/travis/_ci/android-ndk-r17
