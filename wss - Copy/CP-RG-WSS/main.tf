resource "azurerm_resource_group" "res-0" {
  location = "canadacentral"
  name     = "CP-RG-WSS"
  tags = {
    Application    = "WSS"
    ExpirationDate = "09.20.2026"
    SNOW-DEP       = "RITM7181805"
  }
}
resource "azurerm_windows_virtual_machine" "res-1" {
  admin_password                                         = "ignored-as-imported"
  admin_username                                         = "cmhcadmin"
  bypass_platform_safety_checks_on_user_schedule_enabled = true
  license_type                                           = "Windows_Server"
  location                                               = "canadacentral"
  name                                                   = "CPPD1VMWSSSQL01"
  network_interface_ids                                  = [azurerm_network_interface.res-14.id]
  os_managed_disk_id                                     = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/CP-RG-WSS/providers/Microsoft.Compute/disks/CPPD1VMWSSSQL01st1"
  resource_group_name                                    = azurerm_resource_group.res-0.name
  size                                                   = "Standard_F16s_v2"
  tags = {
    Application       = "WSS"
    Category          = "CMHC"
    ExpirationDate    = "09.20.2026"
    MaintenanceWindow = "Window 9"
    Managed           = "True"
    OS                = "Server"
    Operational       = "True"
    Realm             = "Production"
    SNOW-DEP          = "RITM7181805"
  }
  boot_diagnostics {
    storage_account_uri = "https://cdiaglogsilvsa01.blob.core.windows.net/"
  }
  identity {
    type = "SystemAssigned"
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  source_image_reference {
    offer     = "WindowsServer"
    publisher = "MicrosoftWindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-2" {
  caching            = "ReadWrite"
  lun                = 0
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/CP-RG-WSS/providers/Microsoft.Compute/disks/CPPD1VMWSSSQL01-disk01"
  virtual_machine_id = azurerm_windows_virtual_machine.res-1.id
}
resource "azurerm_virtual_machine_extension" "res-3" {
  auto_upgrade_minor_version = true
  name                       = "BGInfo"
  publisher                  = "Microsoft.Compute"
  type                       = "bginfo"
  type_handler_version       = "2.1"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-1.id
}
resource "azurerm_virtual_machine_extension" "res-4" {
  auto_upgrade_minor_version = true
  name                       = "DomainJoin"
  publisher                  = "Microsoft.Compute"
  settings = jsonencode({
    Name    = "cmhc-schl.gc.ca"
    OUPath  = "OU=PRD,OU=Azure Central,OU=Servers,OU=CMHC_CloudServices,DC=cmhc-schl,DC=gc,DC=ca"
    Options = "3"
    Restart = "true"
    User    = "CMHC-SCHL\\svc_cmhc_vcs_asr"
  })
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-1.id
}
resource "azurerm_virtual_machine_extension" "res-5" {
  auto_upgrade_minor_version = true
  name                       = "MDE.Windows"
  publisher                  = "Microsoft.Azure.AzureDefenderForServers"
  settings = jsonencode({
    autoUpdate        = true
    azureResourceId   = azurerm_windows_virtual_machine.res-1.id
    forceReOnboarding = false
    vNextEnabled      = true
  })
  type                 = "MDE.Windows"
  type_handler_version = "1.0"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-1.id
}
resource "azurerm_virtual_machine_extension" "res-6" {
  auto_upgrade_minor_version = true
  name                       = "Microsoft.Powershell.DSC"
  publisher                  = "Microsoft.Powershell"
  settings = jsonencode({
    ConfigurationFunction = "UpdateLCMforAAPull.ps1\\ConfigureLCMforAAPull"
    ModulesUrl            = "https://earmbronsa01.blob.core.windows.net/armtemplates/UpdateLCMforAAPull.zip?sv=2021-06-08&ss=bfqt&srt=sco&sp=rlx&se=2024-08-23T22:09:53Z&st=2022-08-23T14:09:53Z&spr=https&sig=HOf3ed%2B1JhkSPHfe%2B0x83t0GrRC5hRCCssOChkSlfiA%3D"
    Properties = [{
      Name     = "RegistrationKey"
      TypeName = "System.Management.Automation.PSCredential"
      Value = {
        Password = "PrivateSettingsRef:registrationKeyPrivate"
        UserName = "PLACEHOLDER_DONOTUSE"
      }
      }, {
      Name     = "RegistrationUrl"
      TypeName = "System.String"
      Value    = "https://11d8e9dd-6190-4159-bbe0-d63aa6225005.agentsvc.cc.azure-automation.net/accounts/11d8e9dd-6190-4159-bbe0-d63aa6225005"
      }, {
      Name     = "NodeConfigurationName"
      TypeName = "System.String"
      Value    = "Azure_DSC_Med_PRD.localhost"
      }, {
      Name     = "ConfigurationMode"
      TypeName = "System.String"
      Value    = "ApplyandAutoCorrect"
      }, {
      Name     = "ConfigurationModeFrequencyMins"
      TypeName = "System.Int32"
      Value    = 15
      }, {
      Name     = "RefreshFrequencyMins"
      TypeName = "System.Int32"
      Value    = 30
      }, {
      Name     = "RebootNodeIfNeeded"
      TypeName = "System.Boolean"
      Value    = true
      }, {
      Name     = "ActionAfterReboot"
      TypeName = "System.String"
      Value    = "ContinueConfiguration"
      }, {
      Name     = "AllowModuleOverwrite"
      TypeName = "System.Boolean"
      Value    = false
    }]
    SasToken = ""
  })
  type                 = "DSC"
  type_handler_version = "2.19"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-1.id
}
resource "azurerm_virtual_machine_extension" "res-7" {
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  name                       = "MicrosoftDefenderForSQL"
  publisher                  = "Microsoft.Azure.AzureDefenderForSQL"
  type                       = "AdvancedThreatProtection.Windows"
  type_handler_version       = "2.0"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-1.id
}
resource "azurerm_virtual_machine_extension" "res-8" {
  auto_upgrade_minor_version = true
  name                       = "PSScript"
  publisher                  = "Microsoft.Compute"
  settings = jsonencode({
    commandToExecute = "powershell -ExecutionPolicy Unrestricted -File PSScriptCentral.ps1"
    fileUris         = ["https://earmbronsa01.blob.core.windows.net/armtemplates/PSScriptCentral.ps1?sv=2021-06-08&ss=bfqt&srt=sco&sp=rlx&se=2024-08-23T22:09:53Z&st=2022-08-23T14:09:53Z&spr=https&sig=HOf3ed%2B1JhkSPHfe%2B0x83t0GrRC5hRCCssOChkSlfiA%3D"]
  })
  type                 = "CustomScriptExtension"
  type_handler_version = "1.4"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-1.id
}
resource "azurerm_virtual_machine_extension" "res-9" {
  auto_upgrade_minor_version = true
  name                       = "ChangeTracking-Windows"
  publisher                  = "Microsoft.Azure.ChangeTrackingAndInventory"
  type                       = "ChangeTracking-Windows"
  type_handler_version       = "2.0"
  virtual_machine_id         = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/CP-RG-WSS/providers/Microsoft.Compute/virtualMachines/cppd1vmwsssql01"
  depends_on = [
    azurerm_windows_virtual_machine.res-1,
  ]
}
resource "azurerm_lb" "res-10" {
  location            = "canadacentral"
  name                = "CP-LBI-WSS-01"
  resource_group_name = azurerm_resource_group.res-0.name
  tags = {
    Application    = "WSS"
    ExpirationDate = "12.31.2027"
    SNOW-DEP       = "RITM7179605"
  }
  frontend_ip_configuration {
    name      = "CP-FEIP-WSS-01"
    subnet_id = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/azurecore-cent/providers/Microsoft.Network/virtualNetworks/centcmhc-vnet01/subnets/CPRDT-SUBNET02"
  }
}
resource "azurerm_lb_backend_address_pool" "res-11" {
  loadbalancer_id = azurerm_lb.res-10.id
  name            = "CP-LBI-WSS-Pool-01-IP"
}
resource "azurerm_lb_rule" "res-12" {
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.res-11.id]
  backend_port                   = 41002
  disable_outbound_snat          = true
  frontend_ip_configuration_name = "CP-FEIP-WSS-01"
  frontend_port                  = 41002
  loadbalancer_id                = azurerm_lb.res-10.id
  name                           = "SQLAlwaysOnEndPointListener"
  probe_id                       = azurerm_lb_probe.res-13.id
  protocol                       = "Tcp"
}
resource "azurerm_lb_probe" "res-13" {
  interval_in_seconds = 5
  loadbalancer_id     = azurerm_lb.res-10.id
  name                = "SQLAlwaysOnEndPointProbe"
  number_of_probes    = 1
  port                = 59999
}
resource "azurerm_network_interface" "res-14" {
  location            = "canadacentral"
  name                = "CPPD1VMWSSSQL01-Nic01"
  resource_group_name = azurerm_resource_group.res-0.name
  tags = {
    Application       = "WSS"
    ExpirationDate    = "09.20.2026"
    MaintenanceWindow = "Not Applicable"
    Realm             = "Production"
    SNOW-DEP          = "RITM7181805"
  }
  ip_configuration {
    name                          = "CPPD1VMWSSSQL01-NicConfig"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/AzureCore-Cent/providers/Microsoft.Network/virtualNetworks/centcmhc-vnet01/subnets/CPRDT-SUBNET02"
  }
}
resource "azurerm_virtual_machine_extension" "res-15" {
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  name                       = "AzureMonitorWindowsAgent"
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.1"
  virtual_machine_id         = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/CP-RG-WSS/providers/Microsoft.Compute/virtualMachines/cppd1vmwsssql01"
  depends_on = [
    azurerm_windows_virtual_machine.res-1,
  ]
}
resource "azurerm_virtual_machine_extension" "res-16" {
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  name                       = "SqlIaasExtension"
  publisher                  = "Microsoft.SqlServer.Management"
  settings = jsonencode({
    DeploymentTokenSettings = {
      DeploymentToken = 1978049877
    }
    RegistrationSettings = {
      ProvisionExtensionWithNoSQLServer = true
      RegistrationSource                = "TPIDRegistration"
    }
    SqlManagement = {
      IsEnabled = false
    }
  })
  type                 = "SqlIaaSAgent"
  type_handler_version = "2.0"
  virtual_machine_id   = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/cp-rg-wss/providers/Microsoft.Compute/virtualMachines/cppd1vmwsssql01"
  depends_on = [
    azurerm_windows_virtual_machine.res-1,
  ]
}
