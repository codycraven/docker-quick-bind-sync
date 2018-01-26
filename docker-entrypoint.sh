#!/bin/sh
set -e

# Allow setting maximum iNotify
if [ ! -z $MAXIMUM_INOTIFY_WATCHES ]; then
  echo fs.inotify.max_user_watches=$MAXIMUM_INOTIFY_WATCHES | tee -a /etc/sysctl.conf && sysctl -p
fi

# If the first argument passed in looks like a flag
if [ "$(printf %c "$1")" = '-' ]; then
  set -- /sbin/tini -- unison /host /volume "$@"
# If the first argument passed in is unison
elif [ "$1" = 'unison' ]; then
  set -- /sbin/tini -- "$@"
fi

exec "$@"
