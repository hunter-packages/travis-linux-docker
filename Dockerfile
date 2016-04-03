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
