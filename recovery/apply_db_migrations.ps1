param(
    [string]$Database = "peq",
    [string]$User = "root",
    [string]$HostName = "127.0.0.1",
    [int]$Port = 3306,
    [string]$MigrationDir = "database\recovery\migrations_safe"
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

$baseArgs = @("-h", $HostName, "-P", [string]$Port, "-u", $User, $Database)
if ($env:MSR_DB_PASSWORD) {
    $baseArgs = @("-h", $HostName, "-P", [string]$Port, "-u", $User, "-p$env:MSR_DB_PASSWORD", $Database)
} else {
    Write-Host "MSR_DB_PASSWORD is not set. The DB client may prompt for a password for each migration file." -ForegroundColor Yellow
    $baseArgs = @("-h", $HostName, "-P", [string]$Port, "-u", $User, "-p", $Database)
}

$files = Get-ChildItem -Path $MigrationDir -Filter "*.sql" | Sort-Object Name
if (-not $files) {
    throw "No safe migration SQL files found in $MigrationDir"
}

Write-Host "About to apply SAFE migrations from $MigrationDir to database '$Database' on $HostName:$Port." -ForegroundColor Yellow
Write-Host "Pending migrations are NOT applied by this script." -ForegroundColor Yellow

foreach ($file in $files) {
    Write-Host "Applying migration $($file.Name)" -ForegroundColor Cyan
    $sql = Get-Content -Path $file.FullName -Raw
    $sql | & $client @baseArgs
    if ($LASTEXITCODE -ne 0) {
        throw "Migration failed: $($file.Name)"
    }
}

Write-Host "Safe migrations applied." -ForegroundColor Green
