resource "azurerm_resource_group" "res-0" {
  location = "canadacentral"
  name     = "CS-RG-WSS-ASR"
  tags = {
    Application    = "WSS"
    ExpirationDate = "09.20.2026"
    SNOW-DEP       = "RITM7204824"
  }
}
resource "azurerm_managed_disk" "res-1" {
  create_option        = "Copy"
  hyper_v_generation   = "V1"
  location             = "canadacentral"
  name                 = "ESUT1VMWSSAPP01st1-ASRReplica"
  os_type              = "Windows"
  resource_group_name  = azurerm_resource_group.res-0.name
  source_resource_id   = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/cs-rg-wss-asr/providers/Microsoft.Compute/disks/ESUT1VMWSSAPP01st1"
  storage_account_type = "Standard_LRS"
  tags = {
    ASR-ReplicaDisk = "4008be2a-9cf1-5780-942d-2315bf6d01b0"
    DataSourceId    = "1395289287"
  }
}
resource "azurerm_managed_disk" "res-2" {
  create_option        = "Copy"
  location             = "canadacentral"
  name                 = "ESUT1VMWSSAPP01st2-ASRReplica"
  resource_group_name  = azurerm_resource_group.res-0.name
  source_resource_id   = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/cs-rg-wss-asr/providers/Microsoft.Compute/disks/ESUT1VMWSSAPP01st2"
  storage_account_type = "Standard_LRS"
  tags = {
    ASR-ReplicaDisk = "4008be2a-9cf1-5780-942d-2315bf6d01b0"
    DataSourceId    = "1395289287"
  }
}
