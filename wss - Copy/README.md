# Export – one folder per RG

Each resource group is exported to **`wss\<RG-NAME>\`**. Existing exports (folders that already have `main.tf`) are skipped unless you use `-Force`.

Subscription: `5918db9c-25c1-4564-9079-665362a0b0c2`

## Export all RGs in the subscription (skip existing)

Use **all resource groups** in the subscription; skips any RG that already has an export in `wss\<RG-NAME>\main.tf` (e.g. your WSS ones).

```powershell
cd c:\Users\ybationo\workspace\aztfexport\wss
.\export-wss-all.ps1 -AllSubscriptionRGs
```

Requires Azure CLI logged in (`az login`). Uses up to 3 concurrent exports by default; use `-MaxConcurrent 4` (or higher) to speed up.

## Export default WSS RGs only (skip previously generated)

```powershell
cd c:\Users\ybationo\workspace\aztfexport\wss
.\export-wss-all.ps1
```

- Exports each RG to `wss\<RG-NAME>\` (folder per RG).  
- **Skips any RG that already has `main.tf`** in its folder (no re-run of existing exports).  
- Runs up to **3** exports at a time (`-MaxConcurrent 3`).  
- Per-RG log: `wss\<RG-NAME>\export-log.txt`.

If all RGs in the list already have exports, the script reports "No RGs to export" and exits.

**Other options:**

```powershell
.\export-wss-all.ps1 -MaxConcurrent 4              # Run 4 at a time
.\export-wss-all.ps1 -Force                        # Re-export all (overwrite existing)
.\export-wss-all.ps1 -ResourceGroups @("RG1","RG2") # Only these RGs (still skips if main.tf exists)
```

## Export one RG (single run)

```powershell
cd c:\Users\ybationo\workspace\aztfexport\wss
.\ED-RG-WSS\export-rg.ps1 -ResourceGroupName "EP-RG-WSS"
```

To write into a **new** folder for that RG, run aztfexport directly:

```powershell
$rg = "EP-RG-WSS"
New-Item -ItemType Directory -Force -Path ".\$rg" | Out-Null
aztfexport resource-group -s 5918db9c-25c1-4564-9079-665362a0b0c2 -o ".\$rg" -n -f --plain-ui --parallelism 1 --hcl-only --continue $rg
```

## Merging later

Each `wss\<RG-NAME>\` has its own `main.tf`, `provider.tf`, `terraform.tf`. To merge:

- Use a root module that calls each RG as a submodule, or  
- Manually combine `main.tf` (and adjust resource names / references) into one codebase.
