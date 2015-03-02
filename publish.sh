#!/bin/sh -ex

SOURCE_BRANCH=$(git rev-parse HEAD)
SOURCE_PARENT=$(git rev-parse -q --verify $SOURCE_BRANCH)
SOURCE_MESSAGE=$(git log -1 --pretty=%B)
PUBLISH_BRANCH=gh-pages
PUBLISH_DIR=public
PUBLISH_PARENT=$(git rev-parse -q --verify "$PUBLISH_BRANCH")

if [ "$SOURCE_BRANCH" = "$PUBLISH_BRANCH" ]; then
    echo "Cannot publish from branch $SOURCE_BRANCH"
    exit 1
fi

rm -rf "$PUBLISH_DIR"
git clone . "$PUBLISH_DIR"
(cd "$PUBLISH_DIR"; git checkout "$PUBLISH_BRANCH"; rm -r *)

# build with a script that will terminate
NODE_ENV=${NODE_ENV:-production} webpack

cd "$PUBLISH_DIR"
git add --all .
git update-ref refs/heads/"$PUBLISH_BRANCH" $(
    git commit-tree \
        ${PUBLISH_PARENT:+-p $PUBLISH_PARENT} \
        -p $SOURCE_PARENT \
        -m "$SOURCE_MESSAGE (built by $0)" \
        $(git write-tree)
)
git push origin "$PUBLISH_BRANCH"
