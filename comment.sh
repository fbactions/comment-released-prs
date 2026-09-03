#!/usr/bin/env bash
# Comments on every pull request linked from the notes of a GitHub release.
# action.yml passes the inputs through the environment: TAG, COMMENT, DRY_RUN.
set -euo pipefail

url=$(gh release view "$TAG" --json url --jq .url) ||
  { echo "::error::Cannot read release $TAG of $GH_REPO"; exit 1; }
echo "Release $TAG: $url"

# Pull request links to this repository, as GitHub writes them into generated notes
link="${GITHUB_SERVER_URL:-https://github.com}/$GH_REPO/pull/"
prs=$(gh release view "$TAG" --json body --jq .body |
  grep -oE "${link//./\\.}[0-9]+" | grep -oE '[0-9]+$' | sort -un || true)
[ -n "$prs" ] || echo "::notice::No pull requests are linked in the notes of $TAG"

COMMENT=${COMMENT//\{tag\}/$TAG}
COMMENT=${COMMENT//\{url\}/$url}
failed=0
while read -r pr; do
  [ -n "$pr" ] || continue
  if [ "$(gh pr view "$pr" --json comments --jq 'any(.comments[]; .body == env.COMMENT)')" = true ]; then
    echo "#$pr: already commented"
  elif [ "$DRY_RUN" = true ]; then
    echo "#$pr: would comment (dry run)"
  elif out=$(gh pr comment "$pr" --body "$COMMENT"); then
    echo "#$pr: $out"
    sleep 1 # stay below the secondary rate limit for content creation
  else
    echo "::warning::#$pr: failed to comment"
    failed=$((failed + 1))
  fi
done <<<"$prs"

{
  echo "release-url=$url"
  echo "pull-requests=${prs//$'\n'/ }"
} >>"${GITHUB_OUTPUT:-/dev/null}"

if [ "$failed" -gt 0 ]; then
  echo "::error::Failed to comment on $failed pull request(s)"
  exit 1
fi
