#!/bin/bash

set -e

SLUG=${GITHUB_HEAD_REF#blog/}
DIFF=$(git diff --name-only $PREVIOUS_COMMIT origin/main)
echo $DIFF | wc -l

if [[ $(echo $DIFF | wc -l) > 1 || $DIFF != *"src/pages/blog/$SLUG.md" ]]; then
  echo "This PR expects only one blog post '$SLUG.md' to be modified"
  echo "If you want to modify multiple blog posts or other files, please create a new PR"
  # exit 1
fi