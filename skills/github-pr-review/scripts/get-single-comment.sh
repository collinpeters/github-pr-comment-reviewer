#!/bin/bash

# Get a single PR comment thread by comment URL
# Usage: ./get-single-comment.sh <PR_COMMENT_URL>
# Output: JSON object with comment thread data
#
# Supported URL formats:
#   - https://github.com/owner/repo/pull/123#discussion_r456789
#   - https://github.com/owner/repo/pull/123/files#r456789
#   - https://github.com/owner/repo/pull/123/changes#r456789
#   - https://github.com/owner/repo/pull/123#pullrequestreview-456789

set -e

# Get script directory and source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Check arguments
if [ $# -ne 1 ]; then
    echo "Usage: $0 <PR_COMMENT_URL>" >&2
    echo "Example: $0 https://github.com/owner/repo/pull/123#discussion_r456789" >&2
    exit 1
fi

PR_URL="$1"

# Parse PR URL to extract comment ID or review ID
if ! parse_pr_url "$PR_URL"; then
    exit 1
fi

# Check if either comment ID or review ID was extracted
if [[ -z "$COMMENT_ID" && -z "$REVIEW_ID" ]]; then
    echo "Error: No comment ID or review ID found in URL. Please provide a URL with comment ID like: https://github.com/owner/repo/pull/123#discussion_r456789 or review ID like: https://github.com/owner/repo/pull/123#pullrequestreview-456789" >&2
    exit 1
fi

# Handle comment ID (discussion_r* or files#r*)
if [[ -n "$COMMENT_ID" ]]; then
    # Execute GraphQL query
    json_output=$(gh api graphql \
        -F query=@"${SCRIPT_DIR}/queries/find_thread_by_comment.graphql" \
        -f owner="$OWNER" \
        -f repo="$REPO" \
        -F prNumber="$PR_NUMBER" 2>/dev/null)

    # Extract thread ID where any comment URL contains our comment ID
    thread_node_id=$(echo "$json_output" | jq -r --arg commentId "$COMMENT_ID" '
        .data.repository.pullRequest.reviewThreads.nodes[] |
        select(.comments.nodes[]?.url // "" | contains($commentId)) |
        .id'
    )

# Handle review ID (pullrequestreview-*)
elif [[ -n "$REVIEW_ID" ]]; then
    echo "Error: Review URLs (with pullrequestreview- IDs) point to review summaries, not specific comment threads." >&2
    echo "Please use a specific comment URL instead, such as:" >&2
    echo "  - https://github.com/owner/repo/pull/123#discussion_r456789" >&2
    echo "  - https://github.com/owner/repo/pull/123/files#r456789" >&2
    exit 1
fi

# Check if we found a thread node ID
if [[ -z "$thread_node_id" || "$thread_node_id" == "null" ]]; then
    echo "Error: Could not find review thread for the specified comment or review ID" >&2
    exit 1
fi

# Use get-comment-thread.sh to get the full thread data
"$SCRIPT_DIR/get-comment-thread.sh" "$thread_node_id"
