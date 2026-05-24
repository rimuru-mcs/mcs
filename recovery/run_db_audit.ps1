$ErrorActionPreference = "Stop"

$RootDir = Resolve-Path (Join-Path $PSScriptRoot "..")
$AuditDir = Join-Path $RootDir "database\recovery\audits"
$OutputDir = Join-Path $RootDir "database\recovery\audit_output"

$HostName = if ($env:MSR_DB_HOST) { $env:MSR_DB_HOST } else { "localhost" }
$Port = if ($env:MSR_DB_PORT) { $env:MSR_DB_PORT } else { "3306" }
$UserName = if ($env:MSR_DB_USER) { $env:MSR_DB_USER } elseif ($env:MSR_DB_USERNAME) { $env:MSR_DB_USERNAME } else { "root" }
$Database = if ($env:MSR_DB_NAME) { $env:MSR_DB_NAME } elseif ($env:MSR_DB_DATABASE) { $env:MSR_DB_DATABASE } else { "msr_world_recovery" }
$MysqlBin = if ($env:MSR_DB_CLIENT) { $env:MSR_DB_CLIENT } else { "mariadb" }

if (!(Test-Path $AuditDir)) {
    throw "Audit directory not found: $AuditDir"
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
$AuditFiles = Get-ChildItem -Path $AuditDir -Filter "*.sql" | Sort-Object Name

if ($AuditFiles.Count -eq 0) {
    throw "No audit SQL files found in: $AuditDir"
}

Write-Host "MSR database audit"
Write-Host "  Host:     $HostName"
Write-Host "  Port:     $Port"
Write-Host "  User:     $UserName"
Write-Host "  Database: $Database"
Write-Host "  Audits:   $($AuditFiles.Count)"
Write-Host ""

foreach ($AuditFile in $AuditFiles) {
    $OutputFile = Join-Path $OutputDir ($AuditFile.BaseName + ".txt")
    Write-Host "Running audit $($AuditFile.Name) -> database/recovery/audit_output/$($AuditFile.BaseName).txt"

    $Args = @("-h", $HostName, "-P", $Port, "-u", $UserName, "--table", $Database)
    if ($env:MSR_DB_PASSWORD) {
        $Args = @("-h", $HostName, "-P", $Port, "-u", $UserName, "-p$($env:MSR_DB_PASSWORD)", "--table", $Database)
    } else {
        Write-Warning "MSR_DB_PASSWORD is not set. The DB client may prompt for a password for each audit file."
    }

    Get-Content -Raw $AuditFile.FullName | & $MysqlBin @Args | Out-File -Encoding utf8 $OutputFile
}

Write-Host ""
Write-Host "Audit complete."
Write-Host "Output directory: database/recovery/audit_output"
