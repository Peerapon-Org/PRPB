#!/bin/bash

set -e

TEMP=$(mktemp)
SLUG=${GITHUB_HEAD_REF#blog/}
git diff --name-only origin/main > $TEMP

cat $TEMP

if [[ $(cat $TEMP | wc -l) > 1 || $(cat $TEMP) != *"src/pages/blog/$SLUG.mdx" ]]; then
  echo "This PR expects only one blog post 'src/pages/blog/$SLUG.mdx' to be modified"
  echo "If you want to modify multiple blog posts or other non-blog files, please create a new PR"
  exit 1
fi