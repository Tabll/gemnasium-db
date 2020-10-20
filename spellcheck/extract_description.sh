#!/bin/bash

BRANCH="$CI_BUILD_REF_NAME"

touch description.txt 

if [[ "$BRANCH" =~ ^adbcurate/[a-zA-Z0-9_]+_yml$ ]]; then
    git diff origin/master --name-only --diff-filter=AU | while read -r file; do
        bundle exec --gemfile spellcheck/Gemfile spellcheck/extract_description.rb "$file" >> description.txt || exit 1
    done
else
    echo "no advisory branch .. nothing to be done"; exit 0; 
fi

exit 0
