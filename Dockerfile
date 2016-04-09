# https://docs.travis-ci.com/user/common-build-problems/#Running-a-Container-Based-Docker-Image-Locally
FROM quay.io/travisci/travis-ruby
MAINTAINER Ruslan Baratov <ruslan_baratov@yahoo.com>

USER travis

# Default command from .travis.yml, e.g.:
# * https://travis-ci.org/ruslo/hunter/jobs/120167345
RUN sudo -E apt-add-repository -y "ppa:ubuntu-toolchain-r/test"
RUN sudo -E apt-get -yq update && sudo -E apt-get -yq --no-install-suggests \
    --no-install-recommends \
    --force-yes \
    install \
    python3 \
    python3-setuptools \
    libstdc++-4.8-dev \
    g++-4.8
RUN easy_install3 --user requests

# Install tools
WORKDIR /home/travis

# Install Hunter repo with testing fork
RUN git clone https://github.com/ruslo/hunter

WORKDIR /home/travis/hunter
RUN git submodule update --init gate
RUN git checkout develop

RUN git remote add ci https://github.com/ingenue/hunter
RUN git fetch ci
RUN git branch --track pkg.template ci/pkg.template

# Install Polly toolchains
WORKDIR /home/travis

RUN git clone https://github.com/ruslo/polly
WORKDIR /home/travis/polly
RUN git checkout develop

ENV PATH /home/travis/polly/bin:$PATH

WORKDIR /home/travis

ENV TOOLCHAIN android-ndk-r10e-api-19-armeabi-v7a-neon # for NDK downloading
RUN install-ci-dependencies.py

ENV TOOLCHAIN ""

ENV PATH /home/travis/_ci/cmake/bin:$PATH
ENV ANDROID_NDK_r10e /home/travis/_ci/android-ndk-r10e
