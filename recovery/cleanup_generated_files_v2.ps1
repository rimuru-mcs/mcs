$ErrorActionPreference = "Stop"

Write-Host "MSR generated-file cleanup v2" -ForegroundColor Cyan
Write-Host "This unstages current changes, verifies key ignore rules, then removes ignored generated files." -ForegroundColor Yellow

if (-not (Test-Path ".git")) {
    Write-Error "Run this script from the repository root. .git was not found."
}

Write-Host "`nStep 1: Unstaging current Git index..." -ForegroundColor Cyan
git reset

Write-Host "`nStep 2: Checking representative ignore rules..." -ForegroundColor Cyan
$checkTargets = @(
    "build/vs2022/bin/Release/world.exe",
    "perl/x64/c/bin/ar.exe",
    "vcpkg/vcpkg-export-x64.zip",
    "libs/zlibng/zconf-ng.h.included",
    "build_release_log.txt"
)
foreach ($target in $checkTargets) {
    git check-ignore -v -- $target 2>$null
}

Write-Host "`nStep 3: Previewing ignored generated files that would be removed..." -ForegroundColor Cyan
git clean -fdX -n

Write-Host "`nStep 4: Removing ignored generated files..." -ForegroundColor Cyan
git clean -fdX

Write-Host "`nStep 5: Current status summary..." -ForegroundColor Cyan
git status --short

Write-Host "`nCleanup v2 complete. Review GitHub Desktop after it refreshes." -ForegroundColor Green
