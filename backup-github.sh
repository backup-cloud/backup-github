#!/bin/bash 
# A simple script to backup an organization's GitHub repositories.

# NOTE: if you have more than 100 repositories, you'll need to step thru the list of repos 
# returned by GitHub one page at a time, as described at https://gist.github.com/darktim/5582423

GHBU_CONFIGFILE=${GHBU_CONFIGFILE-"/usr/local/backup/backup-github.config"}

if [ ! -r $GHBU_CONFIGFILE ]
then
    echo "No configfile $GHBU_CONFIGFILE - aborting"
    exit 5
fi

. "${GHBU_CONFIGFILE}"

for VARNAME in GHBU_ORG
do
    if [ "A" == "A${!VARNAME}" -o "<CHANGE-ME>" == "${!VARNAME}" ]
    then
	echo "${VARNAME} not set.  You need to set it in ${GHBU_CONFIGFILE}." >&2
	exit 5
    fi
done

GHBU_BACKUP_DIR=${GHBU_BACKUP_DIR-"github-backups"}                  # where to place the backup files
GHBU_GITHOST=${GHBU_GITHOST-"github.com"}                            # the GitHub hostname (see comments)
GHBU_PRUNE_OLD=${GHBU_PRUNE_OLD-true}                                # when `true`, old backups will be deleted
GHBU_PRUNE_AFTER_N_DAYS=${GHBU_PRUNE_AFTER_N_DAYS-3}                 # the min age (in days) of backup files to delete
GHBU_SILENT=${GHBU_SILENT-false}                                     # when `true`, only show error messages 
GHBU_API=${GHBU_API-"https://api.github.com"}                        # base URI for the GitHub API

GHBU_GIT_CLONE_CMD=(git clone --quiet --mirror) # base command to use to clone GitHub repos

TSTAMP=$(date "+%Y%m%d-%H%M")

set -e

# The function `tgz` will create a gzipped tar archive of the specified file ($1) and then remove the original
function tgz {
   tar zcf "$1.tar.gz" "$1" && rm -rf "$1"
}

$GHBU_SILENT || (echo "" && echo "=== INITIALIZING ===" && echo "")

$GHBU_SILENT || echo "Using backup directory $GHBU_BACKUP_DIR"
mkdir -p "$GHBU_BACKUP_DIR"

$GHBU_SILENT || echo -n "Fetching list of repositories for ${GHBU_ORG}..."

REPOLIST=$(curl --silent -u "paddlejenkins:$GITHUB_TOKEN" "${GHBU_API}/orgs/${GHBU_ORG}/repos?per_page=200" -q | grep "\"name\"" | awk -F': "' '{print $2}' | sed -e 's/",//g')
# NOTE: if you're backing up a *user's* repos, not an organizations, use this instead:
#REPOLIST=`curl --silent -H "Authorization: token $GITHUB_TOKEN" ${GHBU_API}/user/repos?type=owner -q | grep "\"name\"" | awk -F': "' '{print $2}' | sed -e 's/",//g'`

$GHBU_SILENT || echo "found $(echo "$REPOLIST" | wc -w) repositories."

$GHBU_SILENT || (echo "" && echo "=== BACKING UP ===" && echo "")

for REPO in $REPOLIST; do
   $GHBU_SILENT || echo "Backing up ${GHBU_ORG}/${REPO}"
   "${GHBU_GIT_CLONE_CMD[@]}" "git@${GHBU_GITHOST}:${GHBU_ORG}/${REPO}.git" "${GHBU_BACKUP_DIR}/${GHBU_ORG}-${REPO}-${TSTAMP}.git" && tgz "${GHBU_BACKUP_DIR}/${GHBU_ORG}-${REPO}-${TSTAMP}.git"

   $GHBU_SILENT || echo "Backing up ${GHBU_ORG}/${REPO}.wiki (if any)"
   "${GHBU_GIT_CLONE_CMD[@]}" "git@${GHBU_GITHOST}:${GHBU_ORG}/${REPO}.wiki.git" "${GHBU_BACKUP_DIR}/${GHBU_ORG}-${REPO}.wiki-${TSTAMP}.git" 2>/dev/null && tgz "${GHBU_BACKUP_DIR}/${GHBU_ORG}-${REPO}.wiki-${TSTAMP}.git"

   $GHBU_SILENT || echo "Backing up ${GHBU_ORG}/${REPO} issues"
   curl --silent -H "Authorization: token $GITHUB_TOKEN" "${GHBU_API}/repos/${GHBU_ORG}/${REPO}/issues" -q > "${GHBU_BACKUP_DIR}/${GHBU_ORG}-${REPO}.issues-${TSTAMP}" && tgz "${GHBU_BACKUP_DIR}/${GHBU_ORG}-${REPO}.issues-${TSTAMP}"
done

if $GHBU_PRUNE_OLD; then
  $GHBU_SILENT || (echo "" && echo "=== PRUNING ===" && echo "")
  $GHBU_SILENT || echo "Pruning backup files ${GHBU_PRUNE_AFTER_N_DAYS} days old or older."
  $GHBU_SILENT || echo "Found $(find "$GHBU_BACKUP_DIR" -name '*.tar.gz' -mtime "+$GHBU_PRUNE_AFTER_N_DAYS" | wc -l) files to prune."
  find "$GHBU_BACKUP_DIR" -name '*.tar.gz' -mtime "+$GHBU_PRUNE_AFTER_N_DAYS" -exec rm -fv {} > /dev/null \; 
fi

$GHBU_SILENT || (echo "" && echo "=== UPLOADING ===" && echo "")
$GHBU_SILENT || echo -n "Pushing files to s3..."

#for d in */ ; do
#  cd "$d"
#  for tar in $(find . -name '*.tar.gz'); do
#    cat "$tar" > backup-github.tar.gz
#  done
#done

DATE=`date "+%Y-%m-%d_%H-%M-%S"`

cd $GHBU_BACKUP_DIR && cat *.tar.gz > backup-github-$DATE.tar.gz

cd .. && python3 call_base_backup.py github-backups/backup-github-$DATE.tar.gz

aws s3 --region us-east-1 cp github-backups/backup-github-$DATE.tar.gz.gpg s3://$S3_BUCKET/backup/backup-github/

$GHBU_SILENT || (echo "" && echo "=== DONE ===" && echo "")
$GHBU_SILENT || (echo "GitHub backup completed." && echo "")
