Docker image Apache2 + PHP5-FPM
===========

Introduction:
======

WARNING: I started this project on Tue Oct 21 2014. At this point it's still in Alpha phase. 

Build docker-image on your own workstation:
======

  ```
    $ cd ~/path/to/apache2-php5-fpm-github-repo
    $ docker build -t quay.io/egbertp/apache2-php5-fpm .
  ```

Usage:
======

Start the docker container interactively 

  ```
    docker run -it --rm -p 80:80 -p 443:443 --name=apache2-php5-fpm -v /Users/egbert/Documents/httpdocs/:/var/www/ quay.io/egbertp/apache2-php5-fpm:latest
  ```

Or start the docker container in production-mode

  ```
    docker run -d --name=apache2-php5-fpm -v /path/to/www/:/var/www/ quay.io/egbertp/apache2-php5-fpm:latest
    docker run -d --name=apache2-php5-fpm -v /Users/egbert/Documents/httpdocs/:/var/www/ quay.io/egbertp/apache2-php5-fpm:latest
  ```

Get overview of all docker conainers

   ```
     docker ps -a 
   ```

Delete a docker container

  ```
    docker rm <containerID>
  ```   

Delete a docker iamge
   
   ```
     docker rmi <imageID>
   ```

Stop the docker container

  ```
    docker stop <containerID>
  ```

Install ``nsenter`` for inspecting containers
---------------------------------------------

An appropriate way to inspect a running container is via ``nsenter``. It
can drop us into a shell inside of the container's filesystem and inspect its
running processes. Unfortunately it only works on linux, so we will create a
``docker-enter`` script that works for us over ssh.

#. Build and install ``nsenter``. You can run this from the host because the
   bind-mounting is still only from the VM::

     docker run --rm -v /var/lib/boot2docker:/target jpetazzo/nsenter

#. Setup ``docker-enter`` script for easy inspection in OS X::

     cat > /usr/local/bin/docker-enter <<'EOF'
     #!/bin/bash
     set -e

     # Check for nsenter. If not found, install it
     boot2docker ssh '[ -f /var/lib/boot2docker/nsenter ] || docker run --rm -v /var/lib/boot2docker/:/target jpetazzo/nsenter'

     # Use bash if no command is specified
     args=$@
     if [[ $# = 1 ]]; then
         args+=(/bin/bash)
     fi

     boot2docker ssh -t sudo /var/lib/boot2docker/docker-enter "${args[@]}"
     EOF

     chmod +x /usr/local/bin/docker-enter

## How to use it?

First, figure out the PID of the container you want to enter:

    $ PID=$(docker inspect --format {{.State.Pid}} <container_name_or_ID>)

    $ PID=$(docker inspect --format {{.State.Pid}} 4dd752450eea)

Then enter the container:

    $ nsenter --target $PID --mount --uts --ipc --net --pid
    $ docker-enter --target $PID --mount --uts --ipc --net --pid



You will get a shell inside the container. That’s it. If you want to run a specific script or program in an automated manner, add it as argument tonsenter. It works a bit like chroot, except that it works with containers instead of plain directories.     