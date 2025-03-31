#!/bin/bash

set -e

TEMP=$(mktemp)
SLUG=${GITHUB_HEAD_REF#blog/}
git diff --name-only $PREVIOUS_COMMIT origin/main > $TEMP

if [[ $(cat $TEMP | wc -l) > 1 || $(cat $TEMP) != *"src/pages/blog/$SLUG.md" ]]; then
  echo "This PR expects only one blog post '$SLUG.md' to be modified"
  echo "If you want to modify multiple blog posts or other files, please create a new PR"
  # exit 1
fi