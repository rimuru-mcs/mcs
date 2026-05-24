param(
    [string]$Database = "peq",
    [string]$User = "root",
    [string]$HostName = "127.0.0.1",
    [int]$Port = 3306,
    [string]$AuditDir = "database\recovery\audits",
    [string]$OutputDir = "database\recovery\audit_output"
)

$ErrorActionPreference = "Stop"

function Find-DbClient {
    foreach ($candidate in @("mariadb.exe", "mysql.exe", "mariadb", "mysql")) {
        $cmd = Get-Command $candidate -ErrorAction SilentlyContinue
        if ($cmd) { return $cmd.Source }
    }
    throw "Could not find mariadb/mysql client on PATH. Install MariaDB client tools or add mysql.exe/mariadb.exe to PATH."
}

$client = Find-DbClient
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$baseArgs = @("-h", $HostName, "-P", [string]$Port, "-u", $User, "--table", $Database)
if ($env:MSR_DB_PASSWORD) {
    $baseArgs = @("-h", $HostName, "-P", [string]$Port, "-u", $User, "-p$env:MSR_DB_PASSWORD", "--table", $Database)
} else {
    Write-Host "MSR_DB_PASSWORD is not set. The DB client may prompt for a password for each audit file." -ForegroundColor Yellow
    $baseArgs = @("-h", $HostName, "-P", [string]$Port, "-u", $User, "-p", "--table", $Database)
}

$files = Get-ChildItem -Path $AuditDir -Filter "*.sql" | Sort-Object Name
if (-not $files) {
    throw "No audit SQL files found in $AuditDir"
}

foreach ($file in $files) {
    $outFile = Join-Path $OutputDir ($file.BaseName + ".txt")
    Write-Host "Running audit $($file.Name) -> $outFile" -ForegroundColor Cyan
    $sql = Get-Content -Path $file.FullName -Raw
    $sql | & $client @baseArgs 2>&1 | Tee-Object -FilePath $outFile
    if ($LASTEXITCODE -ne 0) {
        throw "Audit failed: $($file.Name)"
    }
}

Write-Host "Database audits completed. Output written to $OutputDir" -ForegroundColor Green
