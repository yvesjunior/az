# Export Azure resource group to Terraform - output in this folder (wss)
# Run from: c:\Users\ybationo\workspace\aztfexport\wss
# Captures all output and errors to export-log.txt
#
# If Initializing runs indefinitely: ensure Terraform is on PATH, try -Parallelism 1,
# or run "terraform init" in this folder once to pre-download the provider.

param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [string]$SubscriptionId = "5918db9c-25c1-4564-9079-665362a0b0c2",
    [switch]$HCLOnly = $true,
    [switch]$ContinueOnError = $true,
    [int]$Parallelism = 1
)

$OutDir = $PSScriptRoot
$LogFile = Join-Path $OutDir "export-log.txt"
$env:Path = [Environment]::GetEnvironmentVariable("Path", "User") + ";" + [Environment]::GetEnvironmentVariable("Path", "Machine")

$args = @(
    "resource-group",
    "-s", $SubscriptionId,
    "-o", $OutDir,
    "-n",
    "-f",
    "--plain-ui",
    "--parallelism", $Parallelism
)
if ($HCLOnly) { $args += "--hcl-only" }
if ($ContinueOnError) { $args += "--continue" }
$args += $ResourceGroupName

Write-Host "Exporting RG: $ResourceGroupName -> $OutDir" -ForegroundColor Cyan
Write-Host "Log file: $LogFile" -ForegroundColor Gray

# Run and capture stdout + stderr to log
& aztfexport @args *> $LogFile
$exitCode = $LASTEXITCODE

# Show last 40 lines (usually contains errors if any)
Write-Host "`n--- Last 40 lines of log ---" -ForegroundColor Gray
Get-Content $LogFile -Tail 40 -ErrorAction SilentlyContinue

if ($exitCode -ne 0) {
    Write-Host "`nExport finished with errors (exit code $exitCode). Full log: $LogFile" -ForegroundColor Red
}
exit $exitCode
