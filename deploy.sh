#!/usr/bin/env bash
set -euo pipefail

read -rp "Tag: " ver

if [[ -z "${ver}" ]]; then
  echo "Tag cannot be empty" >&2
  exit 1
fi

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Please start releases from a clean working tree." >&2
  exit 1
fi

git tag "${ver}"

current_branch=$(git rev-parse --abbrev-ref HEAD)

git push origin "${current_branch}"
git push origin "${ver}"
