#!/usr/bin/env bash
set -euo pipefail

printf 'MSR generated-file cleanup v2\n'
printf 'This unstages current changes, verifies key ignore rules, then removes ignored generated files.\n\n'

if [ ! -d .git ]; then
  printf 'ERROR: Run this script from the repository root. .git was not found.\n' >&2
  exit 1
fi

printf 'Step 1: Unstaging current Git index...\n'
git reset

printf '\nStep 2: Checking representative ignore rules...\n'
for target in \
  'build/vs2022/bin/Release/world.exe' \
  'perl/x64/c/bin/ar.exe' \
  'vcpkg/vcpkg-export-x64.zip' \
  'libs/zlibng/zconf-ng.h.included' \
  'build_release_log.txt'; do
  git check-ignore -v -- "$target" 2>/dev/null || true
done

printf '\nStep 3: Previewing ignored generated files that would be removed...\n'
git clean -fdX -n

printf '\nStep 4: Removing ignored generated files...\n'
git clean -fdX

printf '\nStep 5: Current status summary...\n'
git status --short

printf '\nCleanup v2 complete. Review GitHub Desktop after it refreshes.\n'
