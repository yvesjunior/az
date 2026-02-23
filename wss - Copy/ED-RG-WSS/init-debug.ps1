# Run this to see where "Initializing" hangs.
# Step 1: find Terraform. Step 2: terraform init in wss. Step 3: terraform init in a temp dir (like aztfexport does).
# All output goes to init-debug-log.txt. Use Ctrl+C if it hangs, then check the last lines of the log.

$LogFile = Join-Path $PSScriptRoot "init-debug-log.txt"
$OutDir = $PSScriptRoot
$env:Path = [Environment]::GetEnvironmentVariable("Path", "User") + ";" + [Environment]::GetEnvironmentVariable("Path", "Machine")

"=== $(Get-Date -Format 'o') init-debug ===" | Out-File $LogFile -Encoding utf8

# 1) Terraform version (proves it's on PATH)
"--- 1) terraform version ---" | Out-File $LogFile -Append -Encoding utf8
try {
    terraform version 2>&1 | Out-File $LogFile -Append -Encoding utf8
} catch {
    "Error: $_" | Out-File $LogFile -Append -Encoding utf8
}

# 2) terraform init in wss (same as aztfexport output dir)
"--- 2) terraform init in wss (TF_LOG=DEBUG) ---" | Out-File $LogFile -Append -Encoding utf8
$env:TF_LOG = "DEBUG"
$env:TF_LOG_PATH = Join-Path $OutDir "terraform-init-debug.log"
Push-Location $OutDir
try {
    terraform init -input=false 2>&1 | Out-File $LogFile -Append -Encoding utf8
    "Exit code: $LASTEXITCODE" | Out-File $LogFile -Append -Encoding utf8
} finally {
    Pop-Location
    Remove-Item env:TF_LOG -ErrorAction SilentlyContinue
    Remove-Item env:TF_LOG_PATH -ErrorAction SilentlyContinue
}

# 3) terraform init in a temp dir (simulates aztfexport import dir - often the slow/hanging one)
"--- 3) terraform init in temp dir (like aztfexport import dir) ---" | Out-File $LogFile -Append -Encoding utf8
$tempDir = Join-Path $env:TEMP "aztfexport-init-debug-$(Get-Random)"
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
@'
provider "azurerm" {
  features {}
  subscription_id = "5918db9c-25c1-4564-9079-665362a0b0c2"
  use_cli         = true
}
'@ | Out-File (Join-Path $tempDir "provider.tf") -Encoding utf8
@'
terraform {
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "4.58.0" }
  }
}
'@ | Out-File (Join-Path $tempDir "terraform.tf") -Encoding utf8
Push-Location $tempDir
try {
    terraform init -input=false 2>&1 | Out-File $LogFile -Append -Encoding utf8
    "Exit code: $LASTEXITCODE" | Out-File $LogFile -Append -Encoding utf8
} finally {
    Pop-Location
    Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
}

"=== Done $(Get-Date -Format 'o') ===" | Out-File $LogFile -Append -Encoding utf8
Write-Host "Log written to: $LogFile"
Get-Content $LogFile -Tail 30
