#!/usr/bin/env bash
set -euo pipefail

commit="${1:-HEAD}"

repo_root="$(git rev-parse --show-toplevel)"
commit_sha="$(git -C "$repo_root" rev-parse --verify "${commit}^{commit}")"

read -r _commit_sha first_parent _rest < <(git -C "$repo_root" rev-list --parents -n 1 "$commit_sha")

if [[ -n "${first_parent:-}" ]]; then
  changed_files="$(git -C "$repo_root" diff --name-only "$first_parent" "$commit_sha" -- 'dump/**/*.yaml' 'dump/*.yaml')"
else
  changed_files="$(git -C "$repo_root" diff-tree --root --no-commit-id --name-only -r "$commit_sha" -- 'dump/**/*.yaml' 'dump/*.yaml')"
fi

if [[ -n "$changed_files" ]]; then
  printf '%s\n' "$changed_files"
else
  printf 'no changes\n'
fi
