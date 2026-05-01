#!/bin/bash

# Common functions for GitHub PR Review scripts
# Shared utilities for URL parsing, JSON escaping, and error handling

# Function to validate PR URL and extract components
# Sets global variables: OWNER, REPO, PR_NUMBER, COMMENT_ID, REVIEW_ID
parse_pr_url() {
    local pr_url="$1"
    # Handle URLs with comment IDs: #discussion_r123456, /files#r123456, or /changes#r123456
    if [[ "$pr_url" =~ ^https://github.com/([^/]+)/([^/]+)/pull/([0-9]+)(/(files|changes))?#(discussion_)?r([0-9]+)$ ]]; then
        OWNER=${BASH_REMATCH[1]}
        REPO=${BASH_REMATCH[2]}
        PR_NUMBER=${BASH_REMATCH[3]}
        COMMENT_ID=${BASH_REMATCH[7]}
        REVIEW_ID=""
    # Handle URLs with review IDs: #pullrequestreview-123456
    elif [[ "$pr_url" =~ ^https://github.com/([^/]+)/([^/]+)/pull/([0-9]+)#pullrequestreview-([0-9]+)$ ]]; then
        OWNER=${BASH_REMATCH[1]}
        REPO=${BASH_REMATCH[2]}
        PR_NUMBER=${BASH_REMATCH[3]}
        COMMENT_ID=""
        REVIEW_ID=${BASH_REMATCH[4]}
    # Handle basic PR URLs without comment IDs
    elif [[ "$pr_url" =~ ^https://github.com/([^/]+)/([^/]+)/pull/([0-9]+)$ ]]; then
        OWNER=${BASH_REMATCH[1]}
        REPO=${BASH_REMATCH[2]}
        PR_NUMBER=${BASH_REMATCH[3]}
        COMMENT_ID=""
        REVIEW_ID=""
    else
        echo "Error: Invalid GitHub PR URL format. Please use: https://github.com/owner/repo/pull/number, https://github.com/owner/repo/pull/number#discussion_r123456, or https://github.com/owner/repo/pull/number#pullrequestreview-123456" >&2
        return 1
    fi
}

# Function to escape JSON strings
json_escape() {
    local str="$1"
    # Escape backslashes, quotes, and control characters
    echo "$str" | sed 's/\\/\\\\/g; s/"/\\"/g; s/'"$(printf '\t')"'/\\t/g; s/'"$(printf '\n')"'/\\n/g; s/'"$(printf '\r')"'/\\r/g'
}

# Get the directory where the calling script is located
get_script_dir() {
    echo "$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"
}
