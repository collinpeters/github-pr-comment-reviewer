# github-pr-comment-reviewer

A Claude Code skill (packaged as a plugin) for systematically reviewing and resolving GitHub pull request comments.

The skill walks the full review cycle: classifying unresolved threads by type, reading the relevant code, applying fixes, committing changes, and replying to reviewers.

## Requirements

- [Claude Code](https://docs.claude.com/en/docs/claude-code/overview)
- [`gh`](https://cli.github.com/) authenticated against the target repo
- `jq`
- A git repository with write access

## Install

In Claude Code:

```
/plugin marketplace add collinpeters/github-pr-comment-reviewer
/plugin install github-pr-comment-reviewer@collinpeters-github-pr-comment-reviewer
```

Once installed, the skill activates automatically when a PR review task is detected, or you can invoke it explicitly as `github-pr-comment-reviewer:github-pr-review`.

## Usage

Give Claude a PR URL or a specific comment URL:

- `Review https://github.com/owner/repo/pull/123`
- `Address https://github.com/owner/repo/pull/123#discussion_r456`

The skill picks the right workflow based on the URL shape. See `skills/github-pr-review/SKILL.md` for the full behavior spec.

## Repo layout

```
.claude-plugin/plugin.json     Plugin manifest
skills/github-pr-review/       The skill itself
  SKILL.md                     Entry point
  scripts/                     Helper bash scripts (gh + jq)
```

## License

MIT
