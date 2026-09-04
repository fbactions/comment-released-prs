# comment-released-prs

Comments on every pull request included in a GitHub release.

The action reads the notes of the release, picks up every pull request GitHub
listed there, and posts a comment such as
"🎉 Released in [v1.2.3](https://github.com/owner/repo/releases/tag/v1.2.3)"
on each of them. Comments and release notes therefore always cover the same
pull requests. A pull request that already carries the comment is skipped, so
re-running the workflow is safe.

## Usage

Run it whenever a release is published:

```yaml
name: comment-released-prs
on:
  release:
    types: [published]
permissions:
  contents: read
  pull-requests: write
jobs:
  comment:
    runs-on: ubuntu-latest
    steps:
      - uses: fbactions/comment-released-prs@v1
```

Or right after creating the release in a tag-triggered job:

```yaml
      - run: gh release create "$GITHUB_REF_NAME" --generate-notes
        env:
          GH_TOKEN: ${{ github.token }}
      - uses: fbactions/comment-released-prs@v1
```

The release notes must contain the pull request list GitHub generates, either
with `--generate-notes` or with the "Generate release notes" button. Notes
passed with `--notes` are kept in front of the generated list. Use
`--notes-start-tag` to control the range, and `.github/release.yml` to exclude
pull requests from both the notes and the comments. For a first release the
notes, and so the comments, cover the whole history.

The runner needs the `gh` CLI, which GitHub-hosted runners provide.

## Inputs

| Name | Default | Description |
| --- | --- | --- |
| `tag` | `${{ github.ref_name }}` | Tag of the release to read. |
| `comment` | `🎉 Released in [{tag}]({url})` | Comment body. `{tag}` and `{url}` are replaced with the tag and the URL of the release. |
| `token` | `${{ github.token }}` | Token with `pull-requests: write` permission, and `contents: read` to view the release. |
| `dry-run` | `false` | Log the pull requests that would be commented on without commenting. |

## Outputs

| Name | Description |
| --- | --- |
| `pull-requests` | Space-separated numbers of the pull requests linked in the release notes. |
| `release-url` | URL of the release. |

## Versioning

Every release tag is immutable. `v1` is a branch that is only ever
fast-forwarded to the latest `v1.x.y` release, so `@v1` follows the current
major version without any tag being moved. Pin to a full commit SHA if you
prefer.

## License

[MIT](LICENSE)
