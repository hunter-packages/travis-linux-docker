This is instructions of creating docker image similar to one used on Travis.

Install
-------

Install docker, e.g. Ubuntu:

* https://docs.docker.com/engine/installation/linux/ubuntulinux/

Build
-----

Use ``Dockerfile`` to build image:

.. code-block:: shell

  > docker build -t quay.io/ruslo/hunter-travis .
  Sending build context to Docker daemon 7.168 kB
  Step 1 : FROM quay.io/travisci/travis-ruby
   ---> e41062702ee0
  Step 2 : MAINTAINER Ruslan Baratov <ruslan_baratov@yahoo.com>
   ---> Running in e2de4a2d941f
   ---> 2c6fe59fe8e1
  Removing intermediate container e2de4a2d941f
  Step 3 : USER travis
   ---> Running in 95ef6e46b62c
   ---> 7aaa36275b6b
  Removing intermediate container 95ef6e46b62c
  Step 4 : RUN sudo -E apt-add-repository -y "ppa:ubuntu-toolchain-r/test"
   ---> Running in fe1514348e0b
  gpg: keyring `/tmp/tmpZUUZTo/secring.gpg' created
  gpg: keyring `/tmp/tmpZUUZTo/pubring.gpg' created
  gpg: requesting key BA9EF27F from hkp server keyserver.ubuntu.com
  gpg: /tmp/tmpZUUZTo/trustdb.gpg: trustdb created
  gpg: key BA9EF27F: public key "Launchpad Toolchain builds" imported
  gpg: Total number processed: 1
  gpg:               imported: 1  (RSA: 1)
  OK
   ---> 33c00fdd86a6
  Removing intermediate container fe1514348e0b
  Step 5 : RUN sudo -E apt-get -yq update && sudo -E apt-get -yq --no-install-suggests     --no-install-recommends     --force-yes     install     python3     python3-setuptools     libstdc++-4.8-dev     g++-4.8
   ---> Running in e0a90f1bee3b
  Get:1 http://www.rabbitmq.com testing Release.gpg [198 B]
  Get:2 http://apt.postgresql.org precise-pgdg Release.gpg [819 B]
  Get:3 http://downloads-distro.mongodb.org dist Release.gpg [490 B]
  ...
  Processing dependencies for requests
  Finished processing dependencies for requests
   ---> 42f0c5f04ec4
  Removing intermediate container be930bd9fd63
  Successfully built 42f0c5f04ec4

The last line contains resulting docker ``image-id``:

.. code-block:: shell

  > docker images
  REPOSITORY                     TAG                 IMAGE ID            CREATED             SIZE
  ...
  quay.io/ruslo/hunter-travis            latest              42f0c5f04ec4        26 seconds ago      5.916 GB
  ...

Run
---

Start new docker container from this image:

.. code-block:: shell

  > docker run -it quay.io/ruslo/hunter-travis bash

Check installed tools:

.. code-block:: shell

  > g++-4.8 --version
  g++-4.8 (Ubuntu 4.8.1-2ubuntu1~12.04) 4.8.1
  Copyright (C) 2013 Free Software Foundation, Inc.
  This is free software; see the source for copying conditions.  There is NO
  warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  > /usr/local/clang-3.4/bin/clang++ --version
  clang version 3.4 (tags/RELEASE_34/final)
  Target: x86_64-unknown-linux-gnu
  Thread model: posix

  > python3 --version
  Python 3.2.3

  > python3 -c 'import requests'

Update
------

Note that image is static in sense that there is no git repository fetch on
container start, you have to do it manually:

.. code-block:: shell

  > (cd polly && git pull)
  > (cd hunter && git pull)
  > export TOOLCHAIN=... # toolchain to test
  > install-ci-dependencies.py # check if tools from Polly updated

*Warning: branch develop set as a default for both Hunter and Polly keep this fact it mind!*

If there will be significant changes introduced and new docker image pushed then you can do:

.. code-block:: shell

  > docker pull quay.io/ruslo/hunter-travis

Testing
-------

Run some test:

.. code-block:: shell

  > cd hunter
  > TOOLCHAIN=gcc-4-8 PROJECT_DIR=examples/GTest ./jenkins.py --verbose --clear-except
  ...
  -- [hunter] [ Hunter-ID: ... | Config-ID: ... | Toolchain-ID: 7a9f5db ]
  ...

Note that ``Toolchain-ID: 7a9f5db`` match one on Travis perfectly:

* https://travis-ci.org/forexample/hunter-simple/jobs/118003296

Push
----

**Warning**: doesn't work for me! Error message::

  could not verify layer data for: sha256:.... This may be because internal files
  in the layer store were modified. Re-pulling or rebuilding this image may
  resolve the issue

Pushing image to Docker Hub:

.. code-block:: shell

  > docker login
  > docker push ruslo/hunter-travis

Pulling image from Docker Hub is quite the same as running image since ``ruslo/hunter-travis`` is effectively similar to ``hub.docker.com/ruslo/hunter-travis``:

.. code-block:: shell
  
  > docker run --workdir /home/travis -it ruslo/hunter-travis bash

Building remotely
-----------------

Since push failed for me I've found alternative way for image creating. Can be done using remote building on https://quay.io. You just need to create new project and run build with Dockerfile from this repo.

You can pull created image by:

.. code-block:: shell

  > docker pull quay.io/ruslo/hunter-travis
  
and run it:

.. code-block:: shell

  > docker run -it quay.io/ruslo/hunter-travis bash
