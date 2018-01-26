# Docker quick bind sync

When Docker for Mac performs a bind mount from the host machine into a Docker container, there's a translation of filesystem events between the host and the Linux VM. This translation introduces delays that can be substantial when the mount contains many files.
