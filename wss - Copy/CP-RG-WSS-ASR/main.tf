resource "azurerm_resource_group" "res-0" {
  location = "canadacentral"
  name     = "CP-RG-WSS-ASR"
  tags = {
    Application    = "WSS"
    ExpirationDate = "09.20.2026"
    SNOW-DEP       = "RITM7204824"
  }
}
resource "azurerm_managed_disk" "res-1" {
  create_option        = "Empty"
  hyper_v_generation   = "V1"
  location             = "canadacentral"
  name                 = "EPPD1VMWSSAPP01st1-ASRReplica"
  resource_group_name  = azurerm_resource_group.res-0.name
  storage_account_type = "Premium_LRS"
  tags = {
    ASR-ReplicaDisk = "a6cb059e-5369-5c7c-ace8-d6ce927e565f"
  }
}
resource "azurerm_managed_disk" "res-2" {
  create_option        = "Empty"
  location             = "canadacentral"
  name                 = "EPPD1VMWSSAPP01st2-ASRReplica"
  resource_group_name  = azurerm_resource_group.res-0.name
  storage_account_type = "Premium_LRS"
  tags = {
    ASR-ReplicaDisk = "a6cb059e-5369-5c7c-ace8-d6ce927e565f"
  }
}
