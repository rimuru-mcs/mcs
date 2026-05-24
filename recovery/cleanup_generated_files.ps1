$ErrorActionPreference = "Stop"

Write-Host "MSR generated-file cleanup" -ForegroundColor Cyan
Write-Host "This will unstage current changes, then remove files ignored by .gitignore." -ForegroundColor Yellow
Write-Host "It will not remove normal untracked source files." -ForegroundColor Yellow

if (-not (Test-Path ".git")) {
    Write-Error "Run this script from the repository root. .git was not found."
}

Write-Host "\nStep 1: Unstaging current Git index..." -ForegroundColor Cyan
git reset

Write-Host "\nStep 2: Previewing ignored generated files that would be removed..." -ForegroundColor Cyan
git clean -fdX -n

Write-Host "\nStep 3: Removing ignored generated files..." -ForegroundColor Cyan
git clean -fdX

Write-Host "\nStep 4: Current status summary..." -ForegroundColor Cyan
git status --short

Write-Host "\nCleanup complete. Review git status, then commit the real recovery files only." -ForegroundColor Green
