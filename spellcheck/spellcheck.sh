#!/bin/bash

#RULES="WORD_CONTAINS_UNDERSCORE,SENTENCE_WHITESPACE,EN_QUOTES,DOUBLE_PUNCTUATION,EN_UNPAIRED_BRACKETS,MORFOLOGIK_RULE_EN_US,EN_GROS,NE,UPPERCASE_SENTENCE_START,ARROWS"

BRANCH="$CI_BUILD_REF_NAME"
INFILE=$(realpath description.txt)

if [[ "$BRANCH" =~ ^adbcurate/[a-zA-Z0-9_]+_yml$ ]]; then
    cd "/LanguageTool-5.0" || {
        echo "cannot cd into LanguageTool-5.0"
        exit 1
    }

    java -jar languagetool-commandline.jar -l en-GB "$INFILE" | tee log.out

    if grep "Message" log.out> /dev/null 2>&1; then
        exit 1
    fi
else
    echo "no advisory branch .. nothing to be done"; exit 0; 
fi

exit 0
