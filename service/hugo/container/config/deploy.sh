#!/bin/sh
set -eu

GIT_REPO_URL="$1"
GIT_BRANCH=$(basename "$2")

if test -z "$GIT_REPO_URL"; then
    echo "Repository URL not defined, aborting..." >&2
    exit 1
elif test -z "$GIT_BRANCH"; then
    echo "Branch name not defined, aborting..." >&2
    exit 1
fi

GIT_DIR_NAME=$(basename "$GIT_REPO_URL" .git)
GIT_SSH_COMMAND="ssh -o StrictHostKeychecking=no -o UserKnownHostsFile=/dev/null"
for t in rsa ecdsa ed25519; do
    GIT_SSH_COMMAND="$GIT_SSH_COMMAND -i /etc/ssh/keys/ssh_host_${t}_key"
done

export GIT_SSH_COMMAND

if test -d "$GIT_DIR_NAME"; then
    cd "$GIT_DIR_NAME"
    git fetch origin "$GIT_BRANCH" && git reset --hard origin
else
    git clone --depth 1 --branch "$GIT_BRANCH" -- "$GIT_REPO_URL" "$GIT_DIR_NAME"
    cd "$GIT_DIR_NAME"
fi

hugo --verbose --destination "/build/${GIT_DIR_NAME}"
