#!/bin/bash

# Get all unresolved PR comment threads with enough data for classification
# Returns thread IDs, path, line, author, full comment bodies, and URLs
# Does NOT return diffHunk (to keep response size manageable)
# Usage: ./list-threads-for-classification.sh <PR_URL>
# Output: JSON array of unresolved thread objects

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
    -F query=@"${SCRIPT_DIR}/queries/list_threads_for_classification.graphql" \
    -f owner="$OWNER" \
    -f repo="$REPO" \
    -F prNumber="$PR_NUMBER") || exit 1

# GraphQL errors return HTTP 200 with an `errors` array, so `gh` exits 0 even
# when the query was rejected. Detect that explicitly across paginated pages.
if echo "$json_output" | jq -se 'map(.errors // empty) | flatten | length > 0' >/dev/null 2>&1; then
    echo "GraphQL errors from list_threads_for_classification query:" >&2
    echo "$json_output" | jq -s 'map(.errors // empty) | flatten' >&2
    exit 1
fi

# Extract unresolved threads with classification-relevant data
echo "$json_output" | jq -s -c '
    [
        .[] |
        .data.repository.pullRequest.reviewThreads.nodes[] |
        select(.isResolved == false) |
        {
            id: .id,
            path: .path,
            line: .line,
            originalLine: .originalLine,
            comments: [
                .comments.nodes[] |
                {
                    author: (.author.login // "unknown"),
                    body: .body,
                    url: .url,
                    createdAt: .createdAt
                }
            ]
        }
    ]'
