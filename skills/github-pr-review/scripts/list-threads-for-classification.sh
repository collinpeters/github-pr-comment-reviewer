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

# Execute GraphQL query with pagination
json_output=$(gh api graphql --paginate \
    -F query=@"${SCRIPT_DIR}/queries/list_threads_for_classification.graphql" \
    -f owner="$OWNER" \
    -f repo="$REPO" \
    -F prNumber="$PR_NUMBER" 2>/dev/null)

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
