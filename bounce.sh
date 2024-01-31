#!/bin/sh

usage() {
    echo "usage: $0 archive_path pkg_name child_name new_remote"
    exit -1
}

die() {
    echo "error: $1"
    echo "manual cleanup may be required"
    exit -1
}

# check args
if [ $# -lt 4 ]; then
    usage
elif [ $# -gt 4 ]; then
    usage
fi

# unpack source archive
echo ">>> unpacking..."
cd "$(dirname "$0")" || die "couldnt cd!"
ROOT="$(pwd)"
mkdir -p "work" || die "couldnt create work dir!"
cd "work"
curl "$1" | tar xzf - || die "couldnt extract source archive!"
cd "$2" || die "couldnt cd! (wrong package names?)"

# revive the git repo
echo ">>> bouncing..."
mv "$3" ".git" || die "couldnt move .git! (wrong package names?)"
git init || die "couldnt init git repo!"
git checkout -f || die "couldnt checkout git repo!"

# replace origin with our own and push
git remote set-url origin "$4" || die "couldnt set origin!"
git push --force || die "couldnt push to origin!"

# clean up!
echo ">>> cleaning up..."
cd "$ROOT" || die "couldnt cd back to root to clean up!"
rm -rf "work" || "couldnt clean up!"
