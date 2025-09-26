#!/bin/bash

# --- Configuration Variables ---
# Define a standard template file location (if you use external templates)
DEFAULT_TEMPLATE="default_post_template.md"
KEYSTATIC_REPO_DIR="/path/to/your/keystatic/repo"
GITHUB_REPO_DIR="/path/to/your/github/repo"

# --- Function to Get User Input ---
get_input() {
    local prompt_text=$1
    local var_name=$2
    read -r -p "$prompt_text: " "$var_name"
}

# --- Main Script Execution ---

echo "--- Post Composer Setup ---"

# 1. Template Choice
get_input "Enter template file name (e.g., '$DEFAULT_TEMPLATE') or press enter for default" USER_TEMPLATE
TEMPLATE_FILE=${USER_TEMPLATE:-$DEFAULT_TEMPLATE}

# 2. Destination Choice
DESTINATION=""
while [[ "$DESTINATION" != "keystatic" && "$DESTINATION" != "github" ]]; do
    get_input "Push to (keystatic/github)" DESTINATION
    DESTINATION=$(echo "$DESTINATION" | tr '[:upper:]' '[:lower:]') # Lowercase input
done

# Set the target directory
if [ "$DESTINATION" == "keystatic" ]; then
    TARGET_DIR="$KEYSTATIC_REPO_DIR/content/posts" # Adjust path as needed
    REPO_DIR="$KEYSTATIC_REPO_DIR"
else
    TARGET_DIR="$GITHUB_REPO_DIR/_posts" # Adjust path as needed
    REPO_DIR="$GITHUB_REPO_DIR"
fi

# 3. Post Details Input
echo ""
echo "--- Enter Post Details ---"
get_input "Post Title" POST_TITLE
get_input "Author Name" AUTHOR_NAME
get_input "Short Slug (e.g., my-first-post)" POST_SLUG
get_input "Post Content File Path (paste or type content directly)" CONTENT_INPUT

# Simple check to see if input is a file path or direct content
if [ -f "$CONTENT_INPUT" ]; then
    POST_CONTENT=$(cat "$CONTENT_INPUT")
else
    # Assume direct content or an empty start; ask for multi-line input
    echo "Enter your post content now (Ctrl+D when finished):"
    POST_CONTENT=$(cat)
fi

# Format date for the filename and YAML frontmatter (YYYY-MM-DD)
CURRENT_DATE=$(date +%Y-%m-%d)
FILENAME="${CURRENT_DATE}-${POST_SLUG}.md"
POST_FILE="$TARGET_DIR/$FILENAME"

# 4. Generate Markdown File
echo ""
echo "--- Generating $POST_FILE ---"

# The YAML Frontmatter (Essential for Keystatic/Jekyll/etc.)
cat << EOF > "$POST_FILE"
---
title: "$POST_TITLE"
author: "$AUTHOR_NAME"
date: "$CURRENT_DATE"
slug: "$POST_SLUG"
status: "published" # Adjust as needed
---

$POST_CONTENT
EOF

# Optional: Pandoc Formatting Step (if needed to convert the final .md to something else)
# If you just want a standard Markdown file, skip this.
# Example: pandoc -f markdown -t html "$POST_FILE" -o "$TARGET_DIR/${POST_SLUG}.html"

# 5. Git/Push Workflow
echo ""
echo "--- Pushing to $DESTINATION Repository ---"

if cd "$REPO_DIR"; then
    git add "$POST_FILE"
    git commit -m "feat: Add new post - $POST_TITLE"
    git push origin main # Or your default branch name (e.g., 'master')
    
    if [ $? -eq 0 ]; then
        echo "✅ Successfully pushed '$POST_TITLE' to $DESTINATION!"
    else
        echo "❌ Git push failed. Check your repository status."
    fi
    
    cd - > /dev/null # Go back to the original directory
else
    echo "❌ Error: Cannot change directory to $REPO_DIR. Check your path."
fi
