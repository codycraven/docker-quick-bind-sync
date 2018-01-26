# Docker quick bind sync

When Docker for Mac performs a bind mount from the host machine into a Docker container, there's a translation of filesystem events between the host and the Linux VM. This translation introduces delays that can be substantial when the mount contains many files.

This project circumvents the issue by:

1. creating a docker-volume:

    ```bash
    docker volume create quick-sync-volume
    ```

    _The volume's name doesn't matter as long it's consitently used through the remaining commands._

1. mounting the Docker Volume to the container you want your host files in:

    ```bash
    docker run --rm -v quick-sync-volume:/var/www/html php:7.2-apache
    ```

    _Example using php:7.2-apache image, you would of course use your own image and path within the container._

1. create the quick-bind-sync container, attaching your volume and a bind mount from your host machine:

    ```bash
    docker run --rm \
    -v quick-sync-volume:/volume \
    -v `pwd`:/host \
    codycraven/quick-bind-sync:latest
    ```

1. wait for the container to synchronize your bind mount with your volume.

Since the Docker container will not be reading files from the host's bind mount, the Docker container will be able to execute quickly - while maintaining a bidirectional file sync.

## Sync options

Under the hood, the quick-bind-sync container is simply using [Unison](https://www.cis.upenn.edu/~bcpierce/unison/) to maintain a bidirectional sync. You may override the commands built into the Docker image like so:

```bash
docker run --rm \
-v quick-sync-volume:/volume \
-v `pwd`:/host \
codycraven/quick-bind-sync:latest \
unison /host /volume [options]
```

A list of options are available in the [Unison manual](https://www.cis.upenn.edu/~bcpierce/unison/download/releases/stable/unison-manual.html#prefs).

When no commands are passed in the `docker run` command, the following options are used:

* -auto
* -batch
* -repeat watch
* -copyonconflict
* -prefer newer

## Docker Compose example

Using the same example as above, this can be formatted in docker-compose like so:

```yml
version: "3.2"

services:
  php:
    image: php:7.2-apache
    volumes:
      - type: volume
        source: quick-sync-volume
        target: /var/www/html

  php_sync:
    image: codycraven/quick-bind-sync:latest
    depends_on:
      - php
    volumes:
      - type: bind
        source: .
        target: /host
      - type: volume
        source: quick-sync-volume
        target: /volume

volumes:
  quick-sync-volume:
```

## Build image

```bash
docker build -t codycraven/quick-bind-sync:latest .
```

## Alternatives

Docker hasn't yet provided a solution for bind mounts that are satisfactory for very large projects (such as those the size of Drupal 8). There are very many alternatives that I've attempted and come across, however most are only one-way syncs and all have flaws of some sort that I haven't been satisfied with.

The approach this project takes is inspired by [docker-sync](https://docker-sync.io/) with the native_osx strategy. However my team (and many other users) continually ran into problems where docker-sync would stop synchronizing, requiring tearing down the entire container stack, running a `docker-sync clean`, and then bringing the whole stack back up (not a fun process). Not to mention the installation process of docker-sync itself.

By making the synchronization container easily accessible, this project should make it easier to fix synchronization problems without tearing down your containers. Since containers are meant to be ephermal, you should be able to remove only the synchronization container and start a new instance without affecting the rest of your stack.
