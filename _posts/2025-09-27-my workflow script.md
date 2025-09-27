---
layout: post
title: "Workflow"
author: "Eliza Hofer"
date: "2025-09-27"
categories: blog
---

This is the code I use to post my content to my jekyll site. #!/bin/bash

DEFAULT_TEMPLATE="default_post_template.md"
KEYSTATIC_REPO_DIR="/path/to/your/keystatic/repo"
GITHUB_REPO_DIR="/path/to/github/repo"

get_input() {
    local prompt_text=$1
    local var_name=$2
    read -r -p "$prompt_text: " "$var_name"
}

echo "--- Post Composer Setup ---"

get_input "Enter template file name (or press enter for default)" USER_TEMPLATE
TEMPLATE_FILE=${USER_TEMPLATE:-$DEFAULT_TEMPLATE}

DESTINATION=""
while [[ "$DESTINATION" != "keystatic" && "$DESTINATION" != "github" ]]; do
    get_input "Push to (keystatic/github)" DESTINATION
    DESTINATION=$(echo "$DESTINATION" | tr '[:upper:]' '[:lower:]')
done

if [ "$DESTINATION" == "keystatic" ]; then
    TARGET_DIR="$KEYSTATIC_REPO_DIR/content/posts"
    REPO_DIR="$KEYSTATIC_REPO_DIR"
else
    TARGET_DIR="$GITHUB_REPO_DIR/_posts"
    REPO_DIR="$GITHUB_REPO_DIR"
fi

echo ""
echo "--- Enter Post Details ---"
get_input "Post Title" POST_TITLE
get_input "Author Name" AUTHOR_NAME
get_input "Short Slug (e.g., my-first-post)" POST_SLUG
get_input "Post Content File Path (or leave blank to type)" CONTENT_INPUT

if [ -f "$CONTENT_INPUT" ]; then
    POST_CONTENT=$(cat "$CONTENT_INPUT")
else
    echo "Enter your post content now (Ctrl+D when finished):"
    POST_CONTENT=$(cat)
fi

CURRENT_DATE=$(date +%Y-%m-%d)
FILENAME="${CURRENT_DATE}-${POST_SLUG}.md"
POST_FILE="$TARGET_DIR/$FILENAME"

mkdir -p "$TARGET_DIR"

cat << EOF > "$POST_FILE"
---
layout: post
title: "$POST_TITLE"
author: "$AUTHOR_NAME"
date: "$CURRENT_DATE"
categories: blog
---

$POST_CONTENT
EOF

echo ""
echo "--- Pushing to $DESTINATION Repository ---"

if cd "$REPO_DIR"; then
    git add "$POST_FILE"
    git commit -m "Add post: $POST_TITLE"
    git push origin main
    cd - > /dev/null
else
    echo "Error: Cannot change directory to $REPO_DIR"
fi
