# collin-claude-skills

A Claude Code plugin marketplace for skills I've built and use. Currently hosts one plugin:

- **`github-pr-comment-reviewer`** — Systematically review and resolve GitHub PR comments: classify threads, apply fixes, commit, and reply.

## Install

In Claude Code:

```
/plugin marketplace add collinpeters/collin-claude-skills
/plugin install github-pr-comment-reviewer@collin-claude-skills
```

Once installed, the plugin's skill activates automatically when a PR review task is detected, or you can invoke it explicitly as `github-pr-comment-reviewer:github-pr-comment-reviewer`.

## Plugins

### github-pr-comment-reviewer

**Requirements:**

- [`gh`](https://cli.github.com/) authenticated against the target repo
- `jq`
- A git repository with write access

**Usage:** give Claude a PR URL or a specific comment URL:

- `Review https://github.com/owner/repo/pull/123`
- `Address https://github.com/owner/repo/pull/123#discussion_r456`

The plugin's skill picks the right workflow based on the URL shape. See `plugins/github-pr-comment-reviewer/skills/github-pr-comment-reviewer/SKILL.md` for the full behavior spec.

## Repo layout

```
.claude-plugin/marketplace.json          Marketplace manifest
plugins/
  github-pr-comment-reviewer/
    .claude-plugin/plugin.json           Plugin manifest
    skills/github-pr-comment-reviewer/
      SKILL.md                           Skill entry point
      scripts/                           Helper bash scripts (gh + jq)
```

## License

MIT
