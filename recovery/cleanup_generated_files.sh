#!/usr/bin/env bash
set -euo pipefail

printf 'MSR generated-file cleanup\n'
printf 'This will unstage current changes, then remove files ignored by .gitignore.\n'
printf 'It will not remove normal untracked source files.\n\n'

if [ ! -d .git ]; then
  printf 'ERROR: Run this script from the repository root. .git was not found.\n' >&2
  exit 1
fi

printf 'Step 1: Unstaging current Git index...\n'
git reset

printf '\nStep 2: Previewing ignored generated files that would be removed...\n'
git clean -fdX -n

printf '\nStep 3: Removing ignored generated files...\n'
git clean -fdX

printf '\nStep 4: Current status summary...\n'
git status --short

printf '\nCleanup complete. Review git status, then commit the real recovery files only.\n'
