#!/bin/sh
set -evx

if [ -z "$BACKUP_CONTEXT_ENCRYPT_COMMAND" ]
then
    echo "no backup command variable set" >&2
    exit 5
fi
$BACKUP_CONTEXT_ENCRYPT_COMMAND backup-github-$DATE.tar.gz backup-github-$DATE.tar.gz.gpg