param(
  [ValidateSet('status','on','off')]
  [string]$Action = 'status'
)

$RootDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$ManualDir = Join-Path $RootDir 'database/recovery/manual_tests'

$HostName = if ($env:MSR_DB_HOST) { $env:MSR_DB_HOST } else { 'localhost' }
$Port = if ($env:MSR_DB_PORT) { $env:MSR_DB_PORT } else { '3306' }
$UserName = if ($env:MSR_DB_USER) { $env:MSR_DB_USER } elseif ($env:MSR_DB_USERNAME) { $env:MSR_DB_USERNAME } else { 'msr_migrate' }
$DbName = if ($env:MSR_DB_NAME) { $env:MSR_DB_NAME } elseif ($env:MSR_DB_DATABASE) { $env:MSR_DB_DATABASE } else { 'msr_world_recovery' }
$Client = if ($env:MSR_DB_CLIENT) { $env:MSR_DB_CLIENT } else { 'mariadb' }

if ($UserName -eq 'root' -and $env:MSR_ALLOW_ROOT_MIGRATIONS -ne '1') {
  throw 'Refusing to run as MariaDB root. Set MSR_DB_USER to msr_migrate or set MSR_ALLOW_ROOT_MIGRATIONS=1 intentionally.'
}

$argsList = @('-h', $HostName, '-P', $Port, '-u', $UserName, '--table', $DbName)
if ($env:MSR_DB_PASSWORD) {
  $argsList = @('-h', $HostName, '-P', $Port, '-u', $UserName, "-p$($env:MSR_DB_PASSWORD)", '--table', $DbName)
} else {
  Write-Warning 'MSR_DB_PASSWORD is not set. The DB client may prompt for a password.'
}

if ($Action -eq 'on') {
  $sqlFile = Join-Path $ManualDir 'enable_permanent_server_buffs_dev_only.sql'
  Get-Content $sqlFile | & $Client @argsList
} elseif ($Action -eq 'off') {
  $sqlFile = Join-Path $ManualDir 'disable_permanent_server_buffs_dev_only.sql'
  Get-Content $sqlFile | & $Client @argsList
} else {
  & $Client @argsList -e "SELECT ruleset_id, rule_name, rule_value, notes FROM rule_values WHERE rule_name = 'Custom:PermanentServerBuffsEnabled' ORDER BY ruleset_id;"
}
