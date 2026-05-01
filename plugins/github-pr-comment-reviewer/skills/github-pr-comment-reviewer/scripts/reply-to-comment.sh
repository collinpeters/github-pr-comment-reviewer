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

# Execute mutation. Stderr is intentionally not suppressed so transport-level
# failures (auth, network, etc.) surface to the caller.
json_output=$(gh api graphql \
    -f query="$query" \
    -F threadId="$THREAD_ID" \
    -F body="$REPLY_BODY") || exit 1

# GraphQL errors return HTTP 200 with an `errors` array, so `gh` exits 0 even
# when the mutation was rejected (rate limit, validation, permissions, etc.).
# Detect that explicitly.
if echo "$json_output" | jq -e '.errors' >/dev/null 2>&1; then
    echo "GraphQL errors from addPullRequestReviewThreadReply:" >&2
    echo "$json_output" | jq '.errors' >&2
    exit 1
fi

# Verify a comment was actually created. A null comment with no `errors` is
# unexpected, but treat it as a failure rather than printing `null` to stdout.
comment=$(echo "$json_output" | jq -c '.data.addPullRequestReviewThreadReply.comment // empty')
if [ -z "$comment" ]; then
    echo "Reply mutation returned no comment payload:" >&2
    echo "$json_output" >&2
    exit 1
fi

echo "$comment"
