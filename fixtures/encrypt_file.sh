#!/bin/sh
set -evx

if [ -z "$BACKUP_CONTEXT_ENCRYPT_COMMAND" ]
then
    echo "no backup command variable set" >&2
    exit 5
fi

$BACKUP_CONTEXT_ENCRYPT_COMMAND github-backups/backup-github.tar.gz github-backups/backup-github.tar.gz.gpg