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

# Execute GraphQL query
json_output=$(gh api graphql \
    -F query=@"${SCRIPT_DIR}/queries/get_comment_thread.graphql" \
    -f threadId="$THREAD_ID" 2>/dev/null)

# Return the thread data
echo "$json_output" | jq -c '.data.node'
