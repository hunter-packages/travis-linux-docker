This repository contains ``Dockerfile`` which can be used in ``docker build``
command to create image similar to one that used while running Hunter builds on
Travis CI Trusty.

Install Docker
--------------

Install docker, e.g. Ubuntu:

* https://docs.docker.com/engine/installation/linux/ubuntulinux/

Run
---

Start new docker container from this image:

.. code-block:: shell

  > docker run -it quay.io/ruslo/hunter-travis-trusty bash

Check installed tools:

.. code-block:: shell

  > g++ --version
  g++-4.8 (Ubuntu 4.8.1-2ubuntu1~12.04) 4.8.1
  Copyright (C) 2013 Free Software Foundation, Inc.
  This is free software; see the source for copying conditions.  There is NO
  warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  > clang++ --version
  clang version 3.4 (tags/RELEASE_34/final)
  Target: x86_64-unknown-linux-gnu
  Thread model: posix

  > python3 --version
  Python 3.2.3

  > python3 -c 'import requests'

Run GUI
-------

You can start GUI which use X11 by allowing connection to localhost and
exporting DISPLAY:

.. code-block:: shell

  > xhost +
  > docker run -it -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix quay.io/ruslo/hunter-travis-trusty bash
  travis@...:~$ firefox


* http://fabiorehm.com/blog/2014/09/11/running-gui-apps-with-docker/

Update
------

Note that image is static in sense that there is no git repository fetch on
container start, you have to do it manually:

.. code-block:: shell

  > (cd polly && git pull)
  > (cd hunter && git pull)
  > export TOOLCHAIN=... # toolchain to test
  > install-ci-dependencies.py # check if tools from Polly updated

If there will be significant changes introduced and new docker image pushed
then you can do:

.. code-block:: shell

  > docker pull quay.io/ruslo/hunter-travis-trusty

Testing
-------

Run some test:

.. code-block:: shell

  > cd hunter
  > TOOLCHAIN=gcc PROJECT_DIR=examples/GTest ./jenkins.py --verbose --clear-except
  ...
  -- [hunter] [ Hunter-ID: ... | Config-ID: ... | Toolchain-ID: 7a9f5db ]
  ...

Note that ``Toolchain-ID: 7a9f5db`` match one on Travis perfectly:

* https://travis-ci.org/forexample/hunter-simple/jobs/118003296

Build
-----

To build image yourself:

.. code-block:: shell

  > git clone http://github.com/hunter-packages/travis-linux-docker
  > cd travis-linux-docker
  [travis-linux-docker]> docker build .
