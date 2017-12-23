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

.. code-block:: none

  > docker run -it ruslo/travis-linux-docker bash
  Unable to find image 'ruslo/hunter-travis-trusty' locally
  latest: Pulling from ruslo/hunter-travis-trusty
  ...
  Digest: sha256:bd37b3d3c47e181ad1512c8393404fb33b7f20849d208152bb3d0d160ee574d3
  Status: Downloaded newer image for ruslo/hunter-travis-trusty
  travis@d7593ec7547b:~$

Check installed tools:

.. code-block:: none

  travis@9681b443a3fb:~$ which g++-5
  /usr/bin/g++-5

  travis@9681b443a3fb:~$ g++-5 --version
  g++-5 (Ubuntu 5.4.1-2ubuntu1~14.04) 5.4.1 20160904
  Copyright (C) 2015 Free Software Foundation, Inc.
  This is free software; see the source for copying conditions.  There is NO
  warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  travis@9681b443a3fb:~$ which clang++
  /usr/local/clang-5.0.0/bin/clang++

  travis@9681b443a3fb:~$ clang++ --version
  clang version 5.0.0 (tags/RELEASE_500/final)
  Target: x86_64-unknown-linux-gnu
  Thread model: posix
  InstalledDir: /usr/local/clang-5.0.0/bin

  travis@9681b443a3fb:~$ which python3
  /usr/bin/python3

  travis@9681b443a3fb:~$ python3 --version
  Python 3.4.3

  travis@9681b443a3fb:~$ which pip3
  /usr/bin/pip3

  travis@9681b443a3fb:~$ pip3 --version
  pip 1.5.4 from /usr/lib/python3/dist-packages (python 3.4)

  travis@9681b443a3fb:~$ python3 -c 'import requests'

Compare it with real Travis CI job:

* https://travis-ci.org/travis-ci-tester/travis-trusty-env/builds/320739476

Run GUI
-------

You can start GUI which use X11 by allowing connection to localhost and
exporting DISPLAY:

.. code-block:: none

  > xhost +
  > docker run -it -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix ruslo/hunter-travis-trusty bash
  travis@d7593ec7547b:~$ firefox


* http://fabiorehm.com/blog/2014/09/11/running-gui-apps-with-docker/

Update
------

Note that image is static in sense that there is no git repository fetch on
container start, you have to do it manually:

.. code-block:: none


  travis@d7593ec7547b:~$ (cd polly && git pull)
  travis@d7593ec7547b:~$ (cd hunter && git pull)
  travis@d7593ec7547b:~$ export TOOLCHAIN=... # toolchain to test
  travis@d7593ec7547b:~$ install-ci-dependencies.py # check if tools from Polly updated

If there will be significant changes introduced and new docker image pushed
then you can do:

.. code-block:: none

  > docker pull ruslo/travis-linux-docker

Testing
-------

Run some test:

.. code-block:: none

  travis@d7593ec7547b:~$ cd hunter
  travis@d7593ec7547b:~$ TOOLCHAIN=gcc PROJECT_DIR=examples/GTest ./jenkins.py --verbose --clear-except
  ...
  -- [hunter] [ Hunter-ID: ... | Toolchain-ID: 8456c41 | Config-ID: ... ]
  ...

Note that ``Toolchain-ID: 8456c41`` match one on Travis perfectly:

* https://travis-ci.org/ingenue/hunter/jobs/217499907#L839

Extra software
--------------

This ``.travis.yml`` code:

.. code-block:: yaml

  addons:
    apt:
      packages:
        - g++-5
        - gcc-5

Equivalent to running next commands:

.. code-block:: none

  > sudo apt-get -y install g++-5 gcc-5

Build
-----

To build image yourself:

.. code-block:: none

  > git clone http://github.com/hunter-packages/travis-linux-docker
  > cd travis-linux-docker
  [travis-linux-docker]> docker build .

Push if needed:

.. code-block:: none

   ---> Running in a284f95cb56e
   ---> edfa2debece5
  Removing intermediate container a284f95cb56e
  Successfully built edfa2debece5

.. code-block:: none

  > docker tag edfa2debece5 ruslo/travis-linux-docker
  > docker push ruslo/travis-linux-docker

Documentation:
* https://docs.docker.com/engine/reference/commandline/push/
