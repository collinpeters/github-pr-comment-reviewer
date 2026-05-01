#!/bin/bash

# Get full comment thread data by thread ID
# Usage: ./get-comment-thread.sh <THREAD_ID>
# Output: JSON object with complete thread data including all comments and replies

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check arguments
if [ $# -ne 1 ]; then
    echo "Usage: $0 <THREAD_ID>" >&2
    echo "Example: $0 PRRT_kwDOPsBd3c5bpKKt" >&2
    exit 1
fi

THREAD_ID="$1"

# Execute GraphQL query. Stderr is intentionally not suppressed so
# transport-level failures (auth, network, etc.) surface to the caller.
json_output=$(gh api graphql \
    -F query=@"${SCRIPT_DIR}/queries/get_comment_thread.graphql" \
    -f threadId="$THREAD_ID")

# GraphQL errors return HTTP 200 with an `errors` array, so `gh` exits 0 even
# when the query was rejected (unknown thread ID, permissions, etc.).
if echo "$json_output" | jq -e '.errors' >/dev/null 2>&1; then
    echo "GraphQL errors from get_comment_thread query:" >&2
    echo "$json_output" | jq '.errors' >&2
    exit 1
fi

# Null-guard the success path: a missing node means the thread ID didn't
# resolve. Fail rather than print `null` and exit 0.
node=$(echo "$json_output" | jq -c '.data.node // empty')
if [ -z "$node" ]; then
    echo "get_comment_thread query returned no node for thread $THREAD_ID:" >&2
    echo "$json_output" >&2
    exit 1
fi

echo "$node"
