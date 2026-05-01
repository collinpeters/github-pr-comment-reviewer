# github-pr-comment-reviewer

A Claude Code skill (packaged as a plugin) for systematically reviewing and resolving GitHub pull request comments.

The skill walks the full review cycle: classifying unresolved threads by type, reading the relevant code, applying fixes, committing changes, and replying to reviewers.

## Requirements

- [Claude Code](https://docs.claude.com/en/docs/claude-code/overview)
- [`gh`](https://cli.github.com/) authenticated against the target repo
- `jq`
- A git repository with write access

## Install

### As a Claude Code plugin (recommended)

```
/plugin marketplace add itscollin/github-pr-comment-reviewer
/plugin install github-pr-comment-reviewer@itscollin
```

Once installed, the skill is invoked automatically when a PR review task is detected, or explicitly via the namespaced skill `github-pr-comment-reviewer:github-pr-review`.

### As a plain skill

If you don't want the plugin layer, copy the skill folder into your skills directory:

```
cp -r skills/github-pr-review ~/.claude/skills/
```

### Local development

Symlink directly from this repo into your skills directory so edits are picked up immediately:

```
ln -s "$PWD/skills/github-pr-review" ~/.claude/skills/github-pr-review
```

## Usage

Give Claude a PR URL or a specific comment URL:

- `Review https://github.com/owner/repo/pull/123`
- `Address https://github.com/owner/repo/pull/123#discussion_r456`

The skill picks the right workflow based on the URL shape. See `skills/github-pr-review/SKILL.md` for the full behavior spec, `reference.md` for command details, and `examples.md` for worked examples.

## Repo layout

```
.claude-plugin/plugin.json     Plugin manifest
skills/github-pr-review/       The skill itself
  SKILL.md                     Entry point
  reference.md                 Command reference
  examples.md                  Worked examples
  scripts/                     Helper bash scripts (gh + jq)
```

## License

MIT
