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

# Execute GraphQL query with pagination. Stderr is intentionally not suppressed
# so transport-level failures (auth, network, etc.) surface to the caller.
json_output=$(gh api graphql --paginate \
    -F query=@"${SCRIPT_DIR}/queries/list_comment_ids.graphql" \
    -f owner="$OWNER" \
    -f repo="$REPO" \
    -F prNumber="$PR_NUMBER") || exit 1

# GraphQL errors return HTTP 200 with an `errors` array, so `gh` exits 0 even
# when the query was rejected. Detect that explicitly across paginated pages.
if echo "$json_output" | jq -se 'map(.errors // empty) | flatten | length > 0' >/dev/null 2>&1; then
    echo "GraphQL errors from list_comment_ids query:" >&2
    echo "$json_output" | jq -s 'map(.errors // empty) | flatten' >&2
    exit 1
fi

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
