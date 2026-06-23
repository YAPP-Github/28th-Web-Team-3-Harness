#!/usr/bin/env bash
# Post a code review (summary body + inline comments) to a PR via gh api.
# Usage: post-review.sh <pr_number> <findings_json_path>
# findings JSON: {"summary": str, "findings": [{path,line,severity,body}, ...]}
set -u

PR="${1:-}"; FINDINGS="${2:-}"
[ -n "$PR" ] && [ -n "$FINDINGS" ] && [ -f "$FINDINGS" ] \
  || { echo "usage: post-review.sh <pr_number> <findings_json_path>" >&2; exit 2; }
command -v jq >/dev/null 2>&1 || { echo "error: jq required" >&2; exit 3; }

REPO="YAPP-Github/28th-Web-Team-3-FE"

# Build the reviews API request body: event=COMMENT, summary as body,
# findings mapped to inline comments (severity prefixed into the comment body).
BODY_FILE="$(mktemp)"
jq '{
  event: "COMMENT",
  body: ("## fe-reviewer\n\n" + .summary),
  comments: [ .findings[] | {
    path: .path,
    line: .line,
    body: ("**" + (.severity // "note") + "**: " + .body)
  } ]
}' "$FINDINGS" > "$BODY_FILE"

gh api --method POST \
  -H "Accept: application/vnd.github+json" \
  "repos/$REPO/pulls/$PR/reviews" \
  --input "$BODY_FILE" >/dev/null || { echo "error: gh api reviews failed" >&2; exit 1; }

echo "review posted to PR #$PR"
