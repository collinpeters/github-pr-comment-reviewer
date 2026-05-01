# GitHub PR Review - Reference Guide

This document provides detailed patterns, templates, and best practices for PR review resolution.

## Table of Contents

- [User Verification Patterns](#user-verification-patterns)
- [Reply Message Templates](#reply-message-templates)
- [Common Code Review Patterns](#common-code-review-patterns)
- [Thread Analysis Strategies](#thread-analysis-strategies)
- [Git Workflow Patterns](#git-workflow-patterns)
- [Error Handling](#error-handling)

---

## Upfront Summary Pattern

After loading and classifying all threads, present the full plan before doing any work.

### Pattern: Upfront Classification Summary

**Thread links MUST be bare fully-qualified URLs** (e.g. `https://github.com/owner/repo/pull/123#discussion_r456789`), not markdown `[text](url)` syntax — CLI terminals only auto-linkify raw URLs.

```
## PR Review Plan — N threads

### Auto-proceed (X threads)

| # | Thread | Author | File | Concern | Action |
|---|--------|--------|------|---------|--------|
| 1 | https://github.com/owner/repo/pull/123#discussion_r111 | reviewer1 | src/foo.ts:42 | Typo in comment | Fix: correct spelling |
| 2 | https://github.com/owner/repo/pull/123#discussion_r222 | reviewer2 | src/bar.ts:15 | Unused import | Fix: remove import |
| 3 | https://github.com/owner/repo/pull/123#discussion_r333 | reviewer1 | src/baz.ts:88 | Suggestion doesn't apply | Dismiss: already handled by validation on L72 |

### Needs confirmation (Y threads)

| # | Thread | Author | File | Concern | Why |
|---|--------|--------|------|---------|-----|
| 4 | https://github.com/owner/repo/pull/123#discussion_r444 | reviewer1 | src/auth.ts:30 | Token validation logic | Security-relevant change |
| 5 | https://github.com/owner/repo/pull/123#discussion_r555 | reviewer2 | src/api.ts:112 | Change return type | Public API change |
```

Then pause once with user options:
- **go** — start execution as planned
- **confirm #N** — promote an auto-proceed item to needs-confirmation
- **auto #N** — demote a needs-confirmation item to auto-proceed
- **confirm all** — pause on every item
- **auto all** — proceed through everything without pausing

### Pattern: Needs-Confirmation Pause (During Execution)

For items classified as needs-confirmation, pause before executing:

```
## Thread #4 — Needs Confirmation

**Thread**: [link]
**Author**: reviewer1
**File**: src/auth.ts:30
**Concern**: Token validation logic

**Current Code**:
```[language]
[relevant code snippet]
```

**Reviewer's Suggestion**: [what they want changed]

**My Plan**: [what I intend to do]

Proceed with this fix?
```

### Pattern: Final Summary

After all threads are processed:

```
## PR Review Complete — N threads processed

### Fixed (X threads)

| # | Thread | File | Change | Commit |
|---|--------|------|--------|--------|
| 1 | https://github.com/owner/repo/pull/123#discussion_r111 | src/foo.ts:42 | Corrected typo | abc1234 |

### Dismissed (Y threads)

| # | Thread | File | Concern | Reason |
|---|--------|------|---------|--------|
| 3 | https://github.com/owner/repo/pull/123#discussion_r333 | src/baz.ts:88 | Doesn't apply | Already handled on L72 |

### Skipped (Z threads)

(none)
```

Every thread row MUST include the fully-qualified GitHub URL as bare text (not markdown link syntax) so CLI terminals can auto-linkify it.

---

## Reply Message Templates

### Template: Bug Fix

```
Fixed in commit {commit_sha}. {brief_description_of_fix}

Addressed the concern about {original_issue}.

🤖 Generated with Claude Code
```

**Example:**
```
Fixed in commit a3b9c21. Added null check before dereferencing the user object.

Addressed the concern about potential null pointer exception.

🤖 Generated with Claude Code
```

### Template: Performance Improvement

```
Fixed in commit {commit_sha}. {optimization_description}

This addresses the performance concern about {specific_issue} and improves {metric} by {improvement}.

🤖 Generated with Claude Code
```

**Example:**
```
Fixed in commit f4e2d10. Replaced linear search with HashMap lookup.

This addresses the performance concern about O(n) lookups and improves query time from O(n) to O(1).

🤖 Generated with Claude Code
```

### Template: Refactoring

```
Fixed in commit {commit_sha}. {refactoring_description}

Addressed the original concern about {code_quality_issue} and the follow-up discussion regarding {additional_points}.

🤖 Generated with Claude Code
```

**Example:**
```
Fixed in commit 7b3f891. Extracted validation logic into a separate validateInput() function.

Addressed the original concern about code duplication and the follow-up discussion regarding maintainability.

🤖 Generated with Claude Code
```

### Template: Security Fix

```
Fixed in commit {commit_sha}. {security_fix_description}

This addresses the security concern about {vulnerability_type} by {mitigation_approach}.

🤖 Generated with Claude Code
```

**Example:**
```
Fixed in commit c9d8e12. Added input sanitization to prevent XSS attacks.

This addresses the security concern about unescaped user input by using DOMPurify to sanitize all user-provided content.

🤖 Generated with Claude Code
```

### Template: Test Addition

```
Fixed in commit {commit_sha}. Added {test_type} tests covering {scenarios}.

Addressed the concern about {missing_coverage} with {number} new test cases.

🤖 Generated with Claude Code
```

**Example:**
```
Fixed in commit 2e9f4a1. Added unit tests covering edge cases for date parsing.

Addressed the concern about missing test coverage with 5 new test cases for invalid date formats.

🤖 Generated with Claude Code
```

### Template: Documentation Update

```
Fixed in commit {commit_sha}. {documentation_improvement}

Addressed the concern about {documentation_gap}.

🤖 Generated with Claude Code
```

**Example:**
```
Fixed in commit 8a7b3c2. Added JSDoc comments explaining the retry logic and parameters.

Addressed the concern about unclear function behavior.

🤖 Generated with Claude Code
```

### Template: Won't Fix (With Reasoning)

```
After reviewing this suggestion, I believe the current implementation is appropriate because {reasoning}.

{additional_context_or_tradeoffs}

Happy to discuss further if you have concerns.

🤖 Generated with Claude Code
```

**Example:**
```
After reviewing this suggestion, I believe the current implementation is appropriate because the error is already caught and logged at the caller level in main().

Adding redundant error handling here would increase code complexity without providing additional safety, as this function is only called from one location.

Happy to discuss further if you have concerns.

🤖 Generated with Claude Code
```

### Template: Already Fixed

```
This has already been addressed in commit {commit_sha}. {description_of_existing_fix}

The current code now {current_behavior}.

🤖 Generated with Claude Code
```

**Example:**
```
This has already been addressed in commit d4f8e23. The validation was moved to the constructor.

The current code now validates all inputs before object creation, preventing invalid states.

🤖 Generated with Claude Code
```

---

## Common Code Review Patterns

### Pattern: Null/Undefined Checks

**Concern**: Missing null checks, potential null pointer exceptions

**Analysis checklist:**
- Is the value guaranteed to be non-null by caller?
- Does the type system enforce non-nullability?
- Would adding a check be defensive or necessary?

**Fix approaches:**
- Add explicit null/undefined check
- Use optional chaining (`?.`)
- Add type guards or assertions
- Document assumptions

### Pattern: Error Handling

**Concern**: Uncaught exceptions, missing error handling

**Analysis checklist:**
- What errors can occur in this code path?
- Are they already handled upstream?
- Should they be caught here or propagated?
- Is the error message helpful for debugging?

**Fix approaches:**
- Add try-catch blocks
- Return error results instead of throwing
- Add proper error logging
- Validate inputs early

### Pattern: Performance Issues

**Concern**: Inefficient algorithms, unnecessary loops, redundant operations

**Analysis checklist:**
- What is the time complexity?
- Is this code on a hot path?
- Are there obvious optimizations?
- What is the data size in practice?

**Fix approaches:**
- Use more efficient data structures
- Cache computed results
- Reduce redundant operations
- Add early returns

### Pattern: Code Duplication

**Concern**: Duplicated logic, copy-pasted code

**Analysis checklist:**
- Is the duplication intentional?
- Will these code paths diverge in the future?
- Is abstraction worth the complexity?
- How many instances are duplicated?

**Fix approaches:**
- Extract common function/method
- Use composition or inheritance
- Create utility functions
- Use configuration over code

### Pattern: Security Vulnerabilities

**Concern**: SQL injection, XSS, CSRF, authentication issues

**Analysis checklist:**
- Is user input properly sanitized?
- Are queries parameterized?
- Is output properly escaped?
- Are authentication/authorization checks in place?

**Fix approaches:**
- Use parameterized queries
- Sanitize and escape all user input
- Add authentication middleware
- Implement proper access controls

### Pattern: Missing Tests

**Concern**: Insufficient test coverage, missing edge cases

**Analysis checklist:**
- What are the critical paths?
- What edge cases exist?
- What can fail?
- Are error paths tested?

**Fix approaches:**
- Add unit tests for happy path
- Add tests for edge cases
- Add tests for error conditions
- Add integration tests if needed

---

## Thread Analysis Strategies

### Strategy 1: Chronological Review

Always process comments in chronological order:

```bash
# In jq, sort by createdAt
.comments.nodes | sort_by(.createdAt)
```

Identify:
1. **Original concern** (first comment)
2. **Author responses** (subsequent author comments)
3. **Reviewer clarifications** (subsequent reviewer comments)
4. **Current status** (latest actionable feedback)

### Strategy 2: Author vs. Reviewer Tracking

Track the conversation flow:

- **Reviewer comments**: What they're asking for
- **Author responses**: What's been tried or explained
- **Bot comments**: CI/CD results, automated suggestions

Focus on the latest **human reviewer** feedback, not bot comments.

### Strategy 3: Context Extraction

From thread data, extract:

- **File path**: `thread.path`
- **Line number**: `thread.line` or `thread.originalLine`
- **Diff hunk**: `comments[0].diffHunk`
- **Comment body**: `comments[].body`
- **URLs**: `comments[].url`

### Strategy 4: Actionability Assessment

Determine if the feedback is:

- **Actionable**: Clear request for change
- **Discussion**: Open-ended question or suggestion
- **Informational**: FYI, no action needed
- **Already addressed**: Fixed in later commits

---

## Git Workflow Patterns

### Pattern: Single Fix Commit

For single-file, focused fixes (commit locally — push is deferred to Step 6):

```bash
# Stage specific file
git add path/to/file.js

# Commit with descriptive message
git commit -m "Fix null check in processUser function

Addresses PR review comment about potential null pointer.
Adds explicit null check before accessing user.profile."

# Capture the commit hash for the thread tracker
git rev-parse --short HEAD
```

### Pattern: Multi-file Fix

For fixes spanning multiple files (still a single thread — still one commit):

```bash
# Stage each file individually
git add src/utils/validator.js
git add src/models/user.js
git add tests/user.test.js

# Commit with comprehensive message
git commit -m "Add input validation for user creation

Addresses PR review comment about missing validation.
- Added validateUserInput() utility function
- Updated User model to validate on creation
- Added tests for validation edge cases"

# Capture the commit hash for the thread tracker
git rev-parse --short HEAD
```

### Pattern: Deferred Push

All thread commits are pushed together at the end of the review, not after each one. This keeps CI runs to a single build:

```bash
# After all threads have been processed and committed locally:
git log --oneline origin/<branch>..HEAD   # Sanity check the local commits
git push                                   # One push, one CI run
```

### Pattern: Get Latest Commit Hash

After committing:

```bash
# Get short commit hash
git rev-parse --short HEAD

# Get full commit hash
git rev-parse HEAD
```

Use this hash in your reply message.

### Pattern: Check Current Branch

Before making changes:

```bash
# Verify you're on a feature branch, not main/master
git branch --show-current
```

Never commit directly to main/master.

---

## Error Handling

### Script Errors

If a script fails:

1. **Check the error message** - Scripts output errors to stderr
2. **Verify prerequisites** - Ensure `gh` and `jq` are installed
3. **Check authentication** - Run `gh auth status`
4. **Validate inputs** - Ensure URLs are in correct format

### Common Errors

#### "Error: Invalid GitHub PR URL format"

**Cause**: URL doesn't match expected pattern

**Fix**: Ensure URL is one of:
- `https://github.com/owner/repo/pull/123`
- `https://github.com/owner/repo/pull/123#discussion_r456789`
- `https://github.com/owner/repo/pull/123/files#r456789`

#### "Error: Could not find review thread"

**Cause**: Comment ID doesn't exist or is not in this PR

**Fix**:
- Verify the comment URL is correct
- Check if comment was deleted
- Ensure you're using the right PR number

#### "Error: GraphQL query failed"

**Cause**: GitHub API error, authentication issue, or rate limiting

**Fix**:
- Check `gh auth status`
- Verify network connectivity
- Check GitHub API rate limits
- Retry after a moment

### Recovery Strategies

#### If a thread was partially processed:

1. Check what was committed: `git log -1`
2. Check if reply was posted on GitHub
3. Continue from where you left off
4. Update todo list to reflect current state

#### If commit pushed but reply failed:

1. Get the commit hash: `git rev-parse --short HEAD`
2. Manually retry the reply script
3. Or inform user to post reply manually

#### If reply posted but todo not updated:

1. Verify the work is complete on GitHub
2. Update todo list to mark as completed
3. Move to next thread

---

## Advanced Patterns

### Handling Complex Conversations

For threads with 5+ comments:

1. **Summarize the conversation arc** - What evolved?
2. **Identify resolution** - Was consensus reached?
3. **Check for scope creep** - Is the ask now different?
4. **Address the core issue** - What's the actual concern?

### Batching Related Fixes

If multiple comments address the same underlying issue:

1. **Identify the pattern** - Same root cause?
2. **Fix comprehensively** - Address all instances
3. **Reply to each thread** - With same commit hash
4. **Reference related threads** - Help reviewer see full picture

### Disagreeing Respectfully

If you believe a suggestion shouldn't be implemented:

1. **Acknowledge the concern** - Show you understand
2. **Explain your reasoning** - Why current approach is better
3. **Provide evidence** - Performance data, examples, docs
4. **Offer alternatives** - Different ways to address concern
5. **Invite discussion** - Keep it collaborative

---

## Quick Reference Commands

```bash
# Load all unresolved threads with classification data (bodies, paths — no diffHunks)
bash skills/github-pr-review/scripts/list-threads-for-classification.sh "PR_URL"

# List unresolved thread IDs only (lightweight)
bash skills/github-pr-review/scripts/list-comment-ids.sh "PR_URL"

# Get full thread data including diffHunks (for execution phase)
bash skills/github-pr-review/scripts/get-comment-thread.sh "THREAD_ID"

# Get single comment by URL
bash skills/github-pr-review/scripts/get-single-comment.sh "COMMENT_URL"

# Reply to thread
bash skills/github-pr-review/scripts/reply-to-comment.sh "THREAD_ID" "MESSAGE"

# Get current commit hash
git rev-parse --short HEAD

# Check current branch
git branch --show-current

# Stage and commit (push is deferred to Step 6 — one push for all review commits)
git add FILE && git commit -m "MESSAGE"

# Push once, after all review commits are done
git push
```
