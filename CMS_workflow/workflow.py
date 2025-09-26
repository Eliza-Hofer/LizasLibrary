import argparse
import os
import subprocess
from datetime import datetime
import tempfile
import sys
import re

# --- Configuration ---
# NOTE: Replace '_posts' with your desired directory (e.g., '_content' for Keystatic)
POSTS_DIR = os.path.join(os.getcwd(), '_content')

def get_editor():
    """Tries to find the user's preferred editor (EDITOR env var) or defaults."""
    editor = os.environ.get('EDITOR')
    if editor:
        return editor.split()
    # Fallback editors
    if sys.platform == 'win32':
        return ['notepad']
    return ['nvim'] # Default for Unix/Linux/macOS

def slugify(title):
    """Converts a title into a safe, URL-friendly slug."""
    # Convert to lowercase
    title = title.lower()
    # Replace non-alphanumeric characters with hyphens
    title = re.sub(r'[^a-z0-9\s-]', '', title)
    # Replace spaces and multiple hyphens with a single hyphen
    title = re.sub(r'[\s_]+', '-', title).strip('-')
    return title

def assemble_post(title, slug, tags, content):
    """Generates the final post content with YAML front matter."""
    date_str = datetime.now().strftime('%Y-%m-%d %H:%M:%S %z')
    
    # Format tags for YAML list
    tag_list = f'[{", ".join(f"\'{t.strip()}'" for t in tags.split(","))}]' if tags else '[]'

    front_matter = f"""---
title: "{title}"
date: {date_str}
slug: {slug}
tags: {tag_list}
layout: post  # Change this if using a different layout (Keystatic often uses 'default')
published: false # Set to true when ready to publish
---

"""
    return front_matter + content

def write_post_content(title, initial_content=""):
    """Opens the user's default editor to write the post body."""
    editor_cmd = get_editor()
    
    # Create a temporary file
    with tempfile.NamedTemporaryFile(mode='w+', suffix='.md', delete=False) as tf:
        temp_filepath = tf.name
        tf.write(initial_content)
        tf.flush()
    
    print(f"Opening editor: {' '.join(editor_cmd)} for post content...")
    try:
        # Launch the editor and wait for it to close
        subprocess.run(editor_cmd + [temp_filepath], check=True)
        
        # Read the content back after editing
        with open(temp_filepath, 'r') as tf:
            content = tf.read()
        
        return content
    
    except FileNotFoundError:
        print(f"\nERROR: Editor command '{editor_cmd[0]}' not found.")
        print("Please set your EDITOR environment variable (e.g., export EDITOR=vim).")
        return None
    except subprocess.CalledProcessError:
        print("\nERROR: Editor closed unexpectedly or failed.")
        return None
    finally:
        # Clean up the temporary file
        if os.path.exists(temp_filepath):
            os.remove(temp_filepath)

def run_pandoc_formatting(input_filepath, output_filepath):
    """
    Runs Pandoc to process the file.
    NOTE: This is the user-requested step. Here we use it to clean/normalize the Markdown.
    If you needed HTML output, you would change the output format (-t html).
    """
    print(f"\nRunning Pandoc on {input_filepath}...")
    try:
        # Convert Markdown -> Markdown (ensures consistent formatting/structure)
        pandoc_command = ['pandoc', '-s', input_filepath, '-o', output_filepath, '-t', 'markdown']
        subprocess.run(pandoc_command, check=True, capture_output=True, text=True)
        print("Pandoc formatting complete.")
        return True
    except FileNotFoundError:
        print("\nWARNING: Pandoc command not found. Skipping formatting step.")
        print("Install Pandoc to enable this feature.")
        return False
    except subprocess.CalledProcessError as e:
        print(f"\nERROR running Pandoc: {e.stderr}")
        return False

def new_post():
    """Interactive creation of a new post."""
    
    # 1. Get metadata
    title = input("Enter Post Title (Required): ").strip()
    if not title:
        print("Title cannot be empty. Aborting.")
        return
        
    default_slug = slugify(title)
    slug = input(f"Enter Slug (Default: {default_slug}): ").strip() or default_slug
    tags = input("Enter Tags (comma-separated, e.g., tech, python): ").strip()
    
    # 2. Write content
    content_body = write_post_content(title)
    if content_body is None:
        return
    
    # 3. Assemble final content
    final_content = assemble_post(title, slug, tags, content_body)
    
    # 4. Determine filepath
    date_prefix = datetime.now().strftime('%Y-%m-%d')
    # Filename format: YYYY-MM-DD-slug.md (Jekyll default)
    filename = f"{date_prefix}-{slug}.md"
    filepath = os.path.join(POSTS_DIR, filename)

    # Ensure the target directory exists
    os.makedirs(POSTS_DIR, exist_ok=True)
    
    # 5. Save the file (pre-pandoc)
    temp_post_path = os.path.join(tempfile.gettempdir(), f"pre-pandoc-{filename}")
    with open(temp_post_path, 'w') as f:
        f.write(final_content)
        
    # 6. Run Pandoc formatting (optional)
    if run_pandoc_formatting(temp_post_path, filepath):
        # Pandoc success, post is at 'filepath'
        os.remove(temp_post_path)
    else:
        # Pandoc failed or skipped, save the raw assembled content
        print("\nSaving raw assembled content.")
        os.rename(temp_post_path, filepath)

    print(f"\nSUCCESS: New post created at: {filepath}")
    
def publish():
    """Performs Git operations to commit and push the changes."""
    
    # Check if we are in a Git repository
    if not os.path.exists(os.path.join(os.getcwd(), '.git')):
        print("ERROR: Not a Git repository.")
        print("Please initialize Git and commit an initial setup before publishing.")
        return

    commit_message = input("Enter Git Commit Message (e.g., 'New post: Post Title'): ").strip()
    if not commit_message:
        print("Commit message cannot be empty. Aborting publish.")
        return
    
    print("\nStarting Git workflow (add, commit, push)...")
    
    try:
        # Git Add
        subprocess.run(['git', 'add', POSTS_DIR], check=True, capture_output=True, text=True)
        print(f"1. Files in '{POSTS_DIR}' staged successfully.")

        # Git Commit
        subprocess.run(['git', 'commit', '-m', commit_message], check=True, capture_output=True, text=True)
        print(f"2. Committed with message: '{commit_message}'")
        
        # Git Push
        # Note: Assumes the default remote (origin) and branch (main/master)
        subprocess.run(['git', 'push'], check=True, capture_output=True, text=True)
        print("\n3. SUCCESS: Changes pushed to remote repository!")
        
    except subprocess.CalledProcessError as e:
        print("\n--- GIT ERROR ---")
        if 'nothing to commit' in e.stdout:
            print("No changes detected since the last commit. Nothing to publish.")
        else:
            print(f"Error during Git operation. Check your remote status and credentials.")
            print(f"STDOUT: {e.stdout.strip()}")
            print(f"STDERR: {e.stderr.strip()}")
        print("-----------------")
    except FileNotFoundError:
        print("\nERROR: 'git' command not found. Ensure Git is installed and in your PATH.")


def main():
    """Main function to handle command-line arguments."""
    parser = argparse.ArgumentParser(description="Terminal-based CMS for Jekyll/Keystatic setup.")
    subparsers = parser.add_subparsers(dest="command", required=True)

    # Subcommand for creating a new post
    parser_new = subparsers.add_parser("new", help="Create a new blog post.")
    parser_new.set_defaults(func=new_post)

    # Subcommand for publishing changes
    parser_publish = subparsers.add_parser("publish", help="Commit and push recent changes via Git.")
    parser_publish.set_defaults(func=publish)
    
    args = parser.parse_args()
    args.func()

if __name__ == "__main__":
    main()

