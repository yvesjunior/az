# WSS export output

All aztfexport output for WSS resource groups goes here: **`aztfexport/wss`** (this folder).

Subscription: `5918db9c-25c1-4564-9079-665362a0b0c2`

## WSS RGs

- CD-RG-WSS, CP-RG-WSS, CS-RG-WSS
- ED-RG-WSS, EP-RG-WSS, ES-RG-WSS
- CS-RG-WSS-ASR, CP-RG-WSS-ASR

## Export one RG

```powershell
cd c:\Users\ybationo\workspace\aztfexport\wss
.\export-rg.ps1 -ResourceGroupName "ED-RG-WSS"
```

Direct:

```powershell
cd c:\Users\ybationo\workspace\aztfexport\wss
aztfexport resource-group -s 5918db9c-25c1-4564-9079-665362a0b0c2 -o . -n --hcl-only --continue ED-RG-WSS
```

## If "Initializing" runs indefinitely

Init does: (1) find `terraform` on PATH, (2) `terraform init` in the output dir, (3) `terraform init` in one or more temp dirs (per `--parallelism`). Any of these can hang if:

- **Terraform not on PATH** – Install Terraform and add it to PATH.
- **Provider download** – First run downloads the azurerm provider (~100MB+); slow or flaky network can make it look stuck. Use `--parallelism 1` (default in `export-rg.ps1`).
- **Registry/network** – Firewall or proxy blocking registry.terraform.io.

**Reproduce and capture where it hangs:**

```powershell
cd c:\Users\ybationo\workspace\aztfexport\wss
.\init-debug.ps1
```

Then open `init-debug-log.txt` (and `terraform-init-debug.log` if created). If it hangs, stop with Ctrl+C and check the last lines of the log to see which step (1, 2, or 3) didn’t finish.
