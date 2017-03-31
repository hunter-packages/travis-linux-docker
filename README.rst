.. image:: https://quay.io/repository/ruslo/hunter-travis-trusty/status
  :target: https://quay.io/repository/ruslo/hunter-travis-trusty?tab=builds

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
  Unable to find image 'quay.io/ruslo/hunter-travis-trusty:latest' locally
  latest: Pulling from ruslo/hunter-travis-trusty
  ...
  Digest: sha256:bd37b3d3c47e181ad1512c8393404fb33b7f20849d208152bb3d0d160ee574d3
  Status: Downloaded newer image for quay.io/ruslo/hunter-travis-trusty:latest
  travis@d7593ec7547b:~$

Check installed tools:

.. code-block:: shell

  travis@d7593ec7547b:~$ which g++
  /usr/bin/g++

  travis@d7593ec7547b:~$ g++ --version
  g++ (Ubuntu 4.8.4-2ubuntu1~14.04.3) 4.8.4
  Copyright (C) 2013 Free Software Foundation, Inc.
  This is free software; see the source for copying conditions.  There is NO
  warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  travis@d7593ec7547b:~$ which clang++
  /usr/local/clang-3.5.0/bin/clang++

  travis@d7593ec7547b:~$ clang++ --version
  clang version 3.5.0 (tags/RELEASE_350/final)
  Target: x86_64-unknown-linux-gnu
  Thread model: posix

  travis@d7593ec7547b:~$ which python3
  /opt/python/3.5.2/bin/python3

  travis@d7593ec7547b:~$ python3 --version
  Python 3.5.2

  travis@d7593ec7547b:~$ which pip3
  /opt/python/3.5.2/bin/pip3

  travis@d7593ec7547b:~$ pip3 --version
  pip 8.1.1 from /opt/python/3.5.2/lib/python3.5/site-packages (python 3.5)

  travis@d7593ec7547b:~$ python3 -c 'import requests'

Compare it with real Travis CI job:

* https://travis-ci.org/travis-ci-tester/travis-trusty-env/builds/216185507

Run GUI
-------

You can start GUI which use X11 by allowing connection to localhost and
exporting DISPLAY:

.. code-block:: shell

  travis@d7593ec7547b:~$ xhost +
  travis@d7593ec7547b:~$ docker run -it -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix quay.io/ruslo/hunter-travis-trusty bash
  travis@d7593ec7547b:~$ firefox


* http://fabiorehm.com/blog/2014/09/11/running-gui-apps-with-docker/

Update
------

Note that image is static in sense that there is no git repository fetch on
container start, you have to do it manually:

.. code-block:: shell

  
  travis@d7593ec7547b:~$ (cd polly && git pull)
  travis@d7593ec7547b:~$ (cd hunter && git pull)
  travis@d7593ec7547b:~$ export TOOLCHAIN=... # toolchain to test
  travis@d7593ec7547b:~$ install-ci-dependencies.py # check if tools from Polly updated

If there will be significant changes introduced and new docker image pushed
then you can do:

.. code-block:: shell

  > docker pull quay.io/ruslo/hunter-travis-trusty

Testing
-------

Run some test:

.. code-block:: shell

  travis@d7593ec7547b:~$ cd hunter
  travis@d7593ec7547b:~$ TOOLCHAIN=gcc PROJECT_DIR=examples/GTest ./jenkins.py --verbose --clear-except
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
