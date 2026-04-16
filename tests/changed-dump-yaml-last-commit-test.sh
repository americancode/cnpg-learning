#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
script="$repo_root/scripts/changed-dump-yaml-last-commit.sh"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

failures=0

assert_eq() {
  local name="$1"
  local expected="$2"
  local actual="$3"

  if [[ "$actual" == "$expected" ]]; then
    printf 'ok - %s\n' "$name"
  else
    printf 'not ok - %s\nexpected:\n%s\nactual:\n%s\n' "$name" "$expected" "$actual"
    failures=$((failures + 1))
  fi
}

new_repo() {
  local path="$1"

  mkdir -p "$path"
  git -C "$path" init -q
  git -C "$path" symbolic-ref HEAD refs/heads/main
  git -C "$path" config user.email test@example.com
  git -C "$path" config user.name "Test User"
}

commit_all() {
  local path="$1"
  local message="$2"

  git -C "$path" add .
  git -C "$path" commit -q -m "$message"
}

run_script() {
  local path="$1"

  (cd "$path" && "$script")
}

repo="$tmpdir/direct-yaml"
new_repo "$repo"
mkdir -p "$repo/dump" "$repo/cnpg-pitr"
printf 'base\n' > "$repo/README.md"
commit_all "$repo" "base"
printf 'kind: ConfigMap\n' > "$repo/dump/config.yaml"
printf 'kind: Secret\n' > "$repo/cnpg-pitr/ignored.yaml"
printf 'not yaml\n' > "$repo/dump/readme.txt"
commit_all "$repo" "change yaml under dump"
assert_eq "direct commit reports dump yaml only" "dump/config.yaml" "$(run_script "$repo")"

repo="$tmpdir/no-dump-yaml"
new_repo "$repo"
mkdir -p "$repo/dump" "$repo/other"
printf 'base\n' > "$repo/README.md"
commit_all "$repo" "base"
printf 'kind: Secret\n' > "$repo/other/config.yaml"
printf 'not yaml\n' > "$repo/dump/config.txt"
commit_all "$repo" "change non matching files"
assert_eq "direct commit without dump yaml reports no changes" "no changes" "$(run_script "$repo")"

repo="$tmpdir/merge-yaml"
new_repo "$repo"
mkdir -p "$repo/dump"
printf 'base\n' > "$repo/README.md"
commit_all "$repo" "base"
git -C "$repo" checkout -q -b feature
printf 'kind: ConfigMap\n' > "$repo/dump/z.yaml"
commit_all "$repo" "add z"
mkdir -p "$repo/dump/nested" "$repo/manifests"
printf 'kind: Secret\n' > "$repo/dump/nested/x.yaml"
printf 'kind: Ignored\n' > "$repo/manifests/ignored.yaml"
commit_all "$repo" "add x"
git -C "$repo" checkout -q main
printf 'target\n' > "$repo/main.txt"
commit_all "$repo" "target branch change"
git -C "$repo" merge -q --no-ff feature -m "merge feature"
assert_eq "merge commit reports accumulated dump yaml changes" $'dump/nested/x.yaml\ndump/z.yaml' "$(run_script "$repo")"

if [[ "$failures" -gt 0 ]]; then
  exit 1
fi
