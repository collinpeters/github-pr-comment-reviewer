# GitHub PR Review - Examples

This document provides real-world examples of PR comment scenarios and how to address them. The git command blocks show only the per-thread `git add` and `git commit`. Pushing happens once at the end of the whole review (SKILL.md Step 6), not after each commit.

## Table of Contents

- [Example 1: Performance Optimization](#example-1-performance-optimization)
- [Example 2: Code Duplication](#example-2-code-duplication)
- [Example 3: Security Vulnerability](#example-3-security-vulnerability)
- [Example 4: Missing Error Handling](#example-4-missing-error-handling)
- [Example 5: Complex Thread with Multiple Comments](#example-5-complex-thread-with-multiple-comments)
- [Example 6: Won't Fix Decision](#example-6-wont-fix-decision)

---

## Example 1: Performance Optimization

### PR Comment Thread

**Reviewer (bob):**
> This is doing a linear search on every request. With 10k+ users, this will be slow. Can we use a Map instead?

**File:** `src/cache/userCache.js:78`

**Code:**
```javascript
function findUserInCache(userId) {
  return cachedUsers.find(u => u.id === userId);
}
```

### Analysis

- **Concern**: O(n) linear search on potentially large array
- **Valid**: Yes, Map lookup would be O(1)
- **Action**: Refactor to use Map

### Fix

**Before:**
```javascript
const cachedUsers = [];

function addUserToCache(user) {
  cachedUsers.push(user);
}

function findUserInCache(userId) {
  return cachedUsers.find(u => u.id === userId);
}
```

**After:**
```javascript
const cachedUsers = new Map();

function addUserToCache(user) {
  cachedUsers.set(user.id, user);
}

function findUserInCache(userId) {
  return cachedUsers.get(userId);
}
```

### Git Commands

```bash
git add src/cache/userCache.js
git commit -m "Optimize user cache with Map for O(1) lookups

Addresses PR review comment about linear search performance.
Replaces array with Map to improve lookup time from O(n) to O(1)."
```

### Reply Message

```
Fixed in commit f9e4d12. Replaced array with Map for constant-time lookups.

This addresses the performance concern about O(n) linear search and improves query time from O(n) to O(1).

🤖 Generated with Claude Code
```

---

## Example 2: Code Duplication

### PR Comment Thread

**Reviewer (carol):**
> This validation logic is duplicated in three places. Could we extract it into a shared function?

**File:** `src/models/user.js:34`

**Code duplicated in:**
- `src/models/user.js:34`
- `src/models/profile.js:45`
- `src/api/userController.js:89`

### Analysis

- **Concern**: Code duplication makes maintenance harder
- **Valid**: Yes, validation should be centralized
- **Action**: Extract to shared utility

### Fix

**Create new file: `src/utils/validators.js`**
```javascript
export function validateEmail(email) {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!email || !emailRegex.test(email)) {
    throw new Error('Invalid email format');
  }
}
```

**Update all three files:**
```javascript
import { validateEmail } from '../utils/validators.js';

// Replace inline validation with:
validateEmail(user.email);
```

### Git Commands

```bash
git add src/utils/validators.js
git add src/models/user.js
git add src/models/profile.js
git add src/api/userController.js
git commit -m "Extract email validation to shared utility

Addresses PR review comment about code duplication.
- Created validateEmail() in utils/validators.js
- Updated User, Profile, and UserController to use shared validator
- Ensures consistent validation logic across codebase"
```

### Reply Message

```
Fixed in commit 3d8a9f1. Extracted validation logic into shared validateEmail() utility function.

Addressed the original concern about code duplication and ensures consistent validation across all three locations.

🤖 Generated with Claude Code
```

---

## Example 3: Security Vulnerability

### PR Comment Thread

**Reviewer (security-bot):**
> 🚨 Security: User input is not sanitized before rendering. This could allow XSS attacks.

**File:** `src/components/UserProfile.jsx:67`

**Code:**
```jsx
function UserProfile({ user }) {
  return (
    <div>
      <h1>{user.displayName}</h1>
      <div dangerouslySetInnerHTML={{__html: user.bio}} />
    </div>
  );
}
```

### Analysis

- **Concern**: Unsanitized user input rendered as HTML
- **Valid**: Critical security issue - XSS vulnerability
- **Action**: Sanitize HTML or remove dangerouslySetInnerHTML

### Fix

**Before:**
```jsx
<div dangerouslySetInnerHTML={{__html: user.bio}} />
```

**After:**
```jsx
import DOMPurify from 'dompurify';

function UserProfile({ user }) {
  const sanitizedBio = DOMPurify.sanitize(user.bio);
  return (
    <div>
      <h1>{user.displayName}</h1>
      <div dangerouslySetInnerHTML={{__html: sanitizedBio}} />
    </div>
  );
}
```

### Git Commands

```bash
npm install dompurify
git add package.json package-lock.json
git add src/components/UserProfile.jsx
git commit -m "Fix XSS vulnerability in user bio rendering

Addresses security review comment about unsanitized HTML.
Added DOMPurify to sanitize user-provided bio content before rendering."
```

### Reply Message

```
Fixed in commit c8b4e21. Added DOMPurify to sanitize user bio content before rendering.

This addresses the security concern about XSS attacks by sanitizing all user-provided HTML content.

🤖 Generated with Claude Code
```

---

## Example 4: Missing Error Handling

### PR Comment Thread

**Reviewer (dave):**
> If the API call fails, this will crash the app. Should we add error handling?

**File:** `src/api/fetchData.js:23`

**Code:**
```javascript
async function fetchUserData(userId) {
  const response = await fetch(`/api/users/${userId}`);
  const data = await response.json();
  return data;
}
```

### Analysis

- **Concern**: No error handling for network failures or API errors
- **Valid**: Yes, should handle errors gracefully
- **Action**: Add try-catch and response validation

### Fix

**Before:**
```javascript
async function fetchUserData(userId) {
  const response = await fetch(`/api/users/${userId}`);
  const data = await response.json();
  return data;
}
```

**After:**
```javascript
async function fetchUserData(userId) {
  try {
    const response = await fetch(`/api/users/${userId}`);

    if (!response.ok) {
      throw new Error(`API error: ${response.status} ${response.statusText}`);
    }

    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Failed to fetch user data:', error);
    throw new Error(`Failed to fetch user ${userId}: ${error.message}`);
  }
}
```

### Git Commands

```bash
git add src/api/fetchData.js
git commit -m "Add error handling to fetchUserData

Addresses PR review comment about missing error handling.
- Added try-catch for network failures
- Added response.ok check for HTTP errors
- Added descriptive error messages for debugging"
```

### Reply Message

```
Fixed in commit 5e2f9a3. Added comprehensive error handling with try-catch and response validation.

Addressed the concern about unhandled API errors and network failures.

🤖 Generated with Claude Code
```

---

## Example 5: Complex Thread with Multiple Comments

### PR Comment Thread

**Reviewer (eve) - Comment 1:**
> This function is doing too much. Can we split it?

**Author (you) - Comment 2:**
> Good point. What would you suggest for the split?

**Reviewer (eve) - Comment 3:**
> I'd extract the validation into `validateInput()` and the database logic into `saveToDatabase()`. The main function should just orchestrate.

**Author (you) - Comment 4:**
> Makes sense! I'll refactor it.

**File:** `src/services/createUser.js:45`

### Analysis

- **Original concern**: Function too complex
- **Conversation**: Discussed approach
- **Current action**: Implement agreed-upon refactoring
- **Note**: Address both the complexity AND the specific suggestion from Comment 3

### Fix

**Before:**
```javascript
async function createUser(userData) {
  if (!userData.email || !userData.name) {
    throw new Error('Missing required fields');
  }

  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(userData.email)) {
    throw new Error('Invalid email');
  }

  const user = {
    id: generateId(),
    email: userData.email,
    name: userData.name,
    createdAt: new Date()
  };

  await database.insert('users', user);
  await database.insert('user_profiles', { userId: user.id });

  return user;
}
```

**After:**
```javascript
function validateInput(userData) {
  if (!userData.email || !userData.name) {
    throw new Error('Missing required fields');
  }

  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(userData.email)) {
    throw new Error('Invalid email');
  }
}

async function saveToDatabase(user) {
  await database.insert('users', user);
  await database.insert('user_profiles', { userId: user.id });
}

async function createUser(userData) {
  validateInput(userData);

  const user = {
    id: generateId(),
    email: userData.email,
    name: userData.name,
    createdAt: new Date()
  };

  await saveToDatabase(user);

  return user;
}
```

### Git Commands

```bash
git add src/services/createUser.js
git commit -m "Refactor createUser to separate concerns

Addresses PR review discussion about function complexity.
- Extracted validateInput() for validation logic
- Extracted saveToDatabase() for database operations
- Main function now orchestrates with clear separation of concerns"
```

### Reply Message

```
Fixed in commit 7a3b8f2. Refactored into three focused functions: validateInput(), saveToDatabase(), and createUser().

Addressed the original concern about function complexity and the follow-up discussion regarding separation of concerns. The main function now orchestrates while validation and persistence are handled by dedicated functions.

🤖 Generated with Claude Code
```

---

## Example 6: Won't Fix Decision

### PR Comment Thread

**Reviewer (frank):**
> Should we add a mutex lock here to prevent race conditions?

**File:** `src/cache/refreshCache.js:89`

**Code:**
```javascript
async function refreshCache() {
  const data = await fetchLatestData();
  cache = data;
}
```

### Analysis

- **Concern**: Potential race condition if called concurrently
- **Context**: This function is only called from a single-threaded cron job
- **Decision**: Not necessary in current architecture
- **Action**: Explain reasoning, don't implement

### Reply Message (No Code Changes)

```
After reviewing this suggestion, I believe the current implementation is appropriate because refreshCache() is only invoked by the nightly cron job in src/jobs/cacheSyncJob.js:12, which runs in a single-threaded context.

Adding a mutex would add complexity without providing additional safety, as concurrent calls cannot occur in our current architecture. The cron job also has a built-in lock mechanism to prevent overlapping executions.

If we later add additional callers or move to a multi-threaded environment, we should revisit this. Happy to discuss further if you have concerns about future use cases.

🤖 Generated with Claude Code
```

**Classification**: This is an auto-proceed **dismiss** item. The reasoning is clear and the suggestion doesn't apply to the current architecture. It would appear in the upfront summary as:

| # | Thread | Author | File | Concern | Action |
|---|--------|--------|------|---------|--------|
| 7 | https://github.com/owner/repo/pull/123#discussion_r789012 | frank | src/cache/refreshCache.js:89 | Add mutex lock | Dismiss: single-threaded cron job context, mutex unnecessary |

### Key Points

- No commit made
- Explained reasoning clearly
- Referenced specific code location (`src/jobs/cacheSyncJob.js:12`)
- Acknowledged future scenarios where concern would be valid
- Invited continued discussion
- Classified as dismiss — auto-proceeded without individual confirmation

---

## Quick Tips from Examples

1. **Classify before acting** — present the full plan upfront, pause once for gut-check
2. **Always include commit hash** when you make a fix
3. **Reference the original concern** in your reply
4. **For complex threads**, acknowledge the full conversation arc
5. **For dismissals**, provide clear reasoning with evidence
6. **Multi-file changes** need comprehensive commit messages
7. **Security issues** are always needs-confirmation
8. **Performance claims** should include complexity analysis (O(n) → O(1))
9. **When extracting code**, ensure all call sites are updated
10. **Final summary** must list every thread with link, action taken, and commit hash
