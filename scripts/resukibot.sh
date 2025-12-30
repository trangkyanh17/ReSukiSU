#!/bin/env bash

str="$COMMIT_MESSAGE"
len=${#str}

echo "INFO: Char length: $len"

if [ $len -gt 1024 ]; then
msg="*$TITLE*
\\\\#ci\\\\_$VERSION

[Commit]($COMMIT_URL)
[Workflow run]($RUN_URL)
"
else
msg="*$TITLE*
\\\\#ci\\\\_$VERSION
\`\`\`
$COMMIT_MESSAGE
\`\`\`
[Commit]($COMMIT_URL)
[Workflow run]($RUN_URL)
"
fi

files=("$@")
if [ ${#files[@]} -eq 0 ]; then
    echo "ERROR: No files specified"
    exit 1
fi

media_json="["
max_idx=$(( ${#files[@]} - 1 ))
for idx in $(seq 0 $max_idx); do
    if [ $idx -eq $max_idx ]; then
        media_json+="{\"type\":\"document\",\"media\":\"attach://file${idx}\",\"caption\":\"${msg}\",\"parse_mode\":\"MarkdownV2\",\"disable_web_page_preview\":true}"
    else
        media_json+="{\"type\":\"document\",\"media\":\"attach://file${idx}\"},"
    fi
done
media_json+="]"

curl -s "https://api.telegram.org/bot$BOT_TOKEN/sendMediaGroup" \
        -F chat_id="$CHAT_ID" \
        -F message_thread_id="$MESSAGE_THREAD_ID" \
        -F media="$media_json" \
        $(for i in "${!files[@]}"; do echo -n "-F file$i=@${files[$i]} "; done)
