#!/bin/bash

# Reply to a GitHub PR comment thread
# Usage: ./reply-to-comment.sh <THREAD_ID> <REPLY_BODY>
# Output: JSON object with posted comment metadata (id, url, createdAt)

set -e

# Check arguments
if [ $# -ne 2 ]; then
    echo "Usage: $0 <THREAD_ID> <REPLY_BODY>" >&2
    echo "Example: $0 PRRT_kwDOPsBd3c5bpKKt 'Fixed in commit abc123.'" >&2
    exit 1
fi

THREAD_ID="$1"
REPLY_BODY="$2"

# GraphQL mutation to post a reply
query='
mutation($threadId: ID!, $body: String!) {
  addPullRequestReviewThreadReply(input: {pullRequestReviewThreadId: $threadId, body: $body}) {
    comment {
      id
      url
      createdAt
    }
  }
}'

# Execute mutation
json_output=$(gh api graphql \
    -f query="$query" \
    -F threadId="$THREAD_ID" \
    -F body="$REPLY_BODY" 2>/dev/null)

# Return success data
echo "$json_output" | jq -c '.data.addPullRequestReviewThreadReply.comment'
