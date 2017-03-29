# https://docs.travis-ci.com/user/common-build-problems/#Running-a-Container-Based-Docker-Image-Locally

# Using tag from https://hub.docker.com/r/travisci/ci-garnet/tags/ because tag 'latest' not found
# (see issue https://github.com/travis-ci/travis-ci/issues/7518)

# Environment analyze:
# * https://travis-ci.org/travis-ci-tester/travis-trusty-env/builds/216185507

FROM travisci/ci-garnet:packer-1487190256

MAINTAINER Ruslan Baratov <ruslan_baratov@yahoo.com>

USER travis

ENV PATH /opt/python/3.5.2/bin:/usr/local/clang-3.5.0/bin:$PATH

RUN pip3 install --user requests

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

ENV TOOLCHAIN android-ndk-r10e-api-19-armeabi-v7a-neon # for NDK downloading
RUN install-ci-dependencies.py

ENV TOOLCHAIN ""

ENV PATH /home/travis/_ci/cmake/bin:$PATH
ENV ANDROID_NDK_r10e /home/travis/_ci/android-ndk-r10e
