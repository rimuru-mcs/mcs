param(
    [string]$Database = $(if ($env:MSR_DB_NAME) { $env:MSR_DB_NAME } elseif ($env:MSR_DB_DATABASE) { $env:MSR_DB_DATABASE } else { "msr_world_recovery" }),
    [string]$User = $(if ($env:MSR_DB_USER) { $env:MSR_DB_USER } elseif ($env:MSR_DB_USERNAME) { $env:MSR_DB_USERNAME } else { "msr_migrate" }),
    [string]$HostName = $(if ($env:MSR_DB_HOST) { $env:MSR_DB_HOST } else { "localhost" }),
    [int]$Port = $(if ($env:MSR_DB_PORT) { [int]$env:MSR_DB_PORT } else { 3306 }),
    [string]$MigrationDir = "database\recovery\migrations_safe",
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function Find-DbClient {
    if ($env:MSR_DB_CLIENT) {
        $cmd = Get-Command $env:MSR_DB_CLIENT -ErrorAction SilentlyContinue
        if ($cmd) { return $cmd.Source }
        throw "MSR_DB_CLIENT was set, but could not be found: $env:MSR_DB_CLIENT"
    }

    foreach ($candidate in @("mariadb.exe", "mysql.exe", "mariadb", "mysql")) {
        $cmd = Get-Command $candidate -ErrorAction SilentlyContinue
        if ($cmd) { return $cmd.Source }
    }

    throw "Could not find mariadb/mysql client on PATH. Install MariaDB client tools or add mysql.exe/mariadb.exe to PATH."
}

if ($User -eq "root" -and $env:MSR_ALLOW_ROOT_MIGRATIONS -ne "1") {
    throw "Refusing to run migrations as root. Use msr_migrate, or set MSR_ALLOW_ROOT_MIGRATIONS=1 only on a disposable dev DB."
}

$client = Find-DbClient

if (-not (Test-Path -Path $MigrationDir -PathType Container)) {
    throw "Migration directory not found: $MigrationDir"
}

$files = Get-ChildItem -Path $MigrationDir -Filter "*.sql" | Sort-Object Name
if (-not $files) {
    throw "No safe migration SQL files found in $MigrationDir"
}

$baseArgs = @("-h", $HostName, "-P", [string]$Port, "-u", $User, $Database)
if ($env:MSR_DB_PASSWORD) {
    $baseArgs = @("-h", $HostName, "-P", [string]$Port, "-u", $User, "-p$env:MSR_DB_PASSWORD", $Database)
} else {
    Write-Host "MSR_DB_PASSWORD is not set. The DB client may prompt for each migration." -ForegroundColor Yellow
}

Write-Host "MSR safe migration apply" -ForegroundColor Cyan
Write-Host "  Host:          $HostName"
Write-Host "  Port:          $Port"
Write-Host "  User:          $User"
Write-Host "  Database:      $Database"
Write-Host "  Client:        $client"
Write-Host "  Migration dir: $MigrationDir"
Write-Host "  File count:    $($files.Count)"
Write-Host "  Dry run:       $DryRun"
Write-Host ""

if ($DryRun) {
    Write-Host "Dry run only. Migrations that would be applied:" -ForegroundColor Yellow
    foreach ($file in $files) {
        Write-Host "  - $($file.Name)"
    }
    exit 0
}

Write-Host "Applying SAFE migrations only. Pending/review migrations are not applied by this script." -ForegroundColor Yellow
foreach ($file in $files) {
    Write-Host "Applying migration $($file.Name)" -ForegroundColor Cyan
    $sql = Get-Content -Path $file.FullName -Raw
    $sql | & $client @baseArgs
    if ($LASTEXITCODE -ne 0) {
        throw "Migration failed: $($file.Name)"
    }
}

Write-Host "Safe migrations applied. Run recovery/run_db_audit.sh next to verify." -ForegroundColor Green
