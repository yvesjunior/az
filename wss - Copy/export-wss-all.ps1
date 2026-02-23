# Export resource groups in parallel – one folder per RG.
# Use -AllSubscriptionRGs to export all RGs in the subscription (skips those that already have main.tf).
# Run from: c:\Users\ybationo\workspace\aztfexport\wss

param(
    [string]$SubscriptionId = "5918db9c-25c1-4564-9079-665362a0b0c2",
    [int]$MaxConcurrent = 3,
    [switch]$Force,  # Re-export even if folder already has main.tf
    [switch]$AllSubscriptionRGs,  # Use all RGs in the subscription (from Azure CLI); skips existing exports
    [string[]]$ResourceGroups = @()  # If set, use this list; still skips existing main.tf unless -Force
)

$WssRoot = $PSScriptRoot
$env:Path = [Environment]::GetEnvironmentVariable("Path", "User") + ";" + [Environment]::GetEnvironmentVariable("Path", "Machine")

# Resolve RG list: -AllSubscriptionRGs, or -ResourceGroups, or default WSS list
$WssRGs = if ($AllSubscriptionRGs) {
    Write-Host "Fetching all resource groups from subscription..." -ForegroundColor Gray
    $list = az group list --subscription $SubscriptionId --query "[].name" -o tsv 2>$null
    if (-not $list) { Write-Host "Error: Could not list RGs (az group list). Is Azure CLI logged in?" -ForegroundColor Red; exit 1 }
    ($list -split "`n" | ForEach-Object { $_.Trim() }) | Where-Object { $_ -ne "" }
} elseif ($ResourceGroups.Count -gt 0) {
    $ResourceGroups
} else {
    @(
        "CD-RG-WSS", "CP-RG-WSS", "CS-RG-WSS",
        "ED-RG-WSS", "EP-RG-WSS", "ES-RG-WSS",
        "CS-RG-WSS-ASR", "CP-RG-WSS-ASR"
    )
}

# Skip RGs that already have an export folder with main.tf (unless -Force)
$ToExport = if ($Force) { $WssRGs } else {
    $WssRGs | Where-Object {
        $dir = Join-Path $WssRoot $_
        $mainTf = Join-Path $dir "main.tf"
        -not (Test-Path $mainTf)
    }
}

if ($ToExport.Count -eq 0) {
    Write-Host "No RGs to export (all already have main.tf, or list empty)." -ForegroundColor Yellow
    Write-Host "Total in list: $($WssRGs.Count) RGs."
    exit 0
}

Write-Host "Exporting $($ToExport.Count) RGs concurrently (max $MaxConcurrent at a time): $($ToExport -join ', ')" -ForegroundColor Cyan
Write-Host "Output: $WssRoot\<RG-NAME>\ for each." -ForegroundColor Gray

$jobScript = {
    param($RG, $SubId, $WssRoot)
    $outDir = Join-Path $WssRoot $RG
    New-Item -ItemType Directory -Force -Path $outDir | Out-Null
    $logFile = Join-Path $outDir "export-log.txt"
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "User") + ";" + [Environment]::GetEnvironmentVariable("Path", "Machine")
    & aztfexport resource-group -s $SubId -o $outDir -n -f --plain-ui --parallelism 1 --hcl-only --continue $RG *> $logFile
    $code = $LASTEXITCODE
    [PSCustomObject]@{ RG = $RG; ExitCode = $code; Log = $logFile }
}

$jobs = @()
foreach ($rg in $ToExport) {
    while ((Get-Job -State Running).Count -ge $MaxConcurrent) {
        Start-Sleep -Seconds 2
    }
    $jobs += Start-Job -ScriptBlock $jobScript -ArgumentList $rg, $SubscriptionId, $WssRoot -Name "export-$rg"
    Write-Host "Started: $rg" -ForegroundColor Green
}

Write-Host "Waiting for all $($jobs.Count) jobs..." -ForegroundColor Cyan
$null = Wait-Job $jobs
$results = $jobs | ForEach-Object { Receive-Job -Job $_ }; $jobs | Remove-Job -Force

foreach ($r in $results) {
    if ($r) {
        $status = if ($r.ExitCode -eq 0) { "OK" } else { "FAILED" }
        $color = if ($r.ExitCode -eq 0) { "Green" } else { "Red" }
        Write-Host "  $($r.RG): $status (log: $($r.Log))" -ForegroundColor $color
    }
}

Write-Host "Done. Per-RG logs: $WssRoot\<RG-NAME>\export-log.txt" -ForegroundColor Cyan
Write-Host "Merge the generated Terraform later as needed." -ForegroundColor Gray
