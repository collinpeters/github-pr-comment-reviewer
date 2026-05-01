#!/bin/bash

# Get comment thread IDs for unresolved PR comments
# Usage: ./list-comment-ids.sh <PR_URL>
# Output: JSON array of unresolved thread objects with id, author, url, preview

set -e

# Get script directory and source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Check arguments
if [ $# -ne 1 ]; then
    echo "Usage: $0 <PR_URL>" >&2
    echo "Example: $0 https://github.com/owner/repo/pull/123" >&2
    exit 1
fi

PR_URL="$1"

# Parse PR URL
if ! parse_pr_url "$PR_URL"; then
    exit 1
fi

# Execute GraphQL query with pagination
json_output=$(gh api graphql --paginate \
    -F query=@"${SCRIPT_DIR}/queries/list_comment_ids.graphql" \
    -f owner="$OWNER" \
    -f repo="$REPO" \
    -F prNumber="$PR_NUMBER" 2>/dev/null)

# Extract IDs, authors, URLs, and comment previews of unresolved threads
echo "$json_output" | jq -s -c '
    map(
        .data.repository.pullRequest.reviewThreads.nodes[] |
        select(.isResolved == false) |
        {
            id: .id,
            author: (.comments.nodes[0].author.login // "unknown"),
            url: (.comments.nodes[0].url // ""),
            preview: ((.comments.nodes[0].body // "") | gsub("\\n"; " ") | if length > 30 then .[0:30] + "..." else . end)
        }
    )'
