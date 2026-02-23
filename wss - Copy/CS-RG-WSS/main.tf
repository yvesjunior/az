resource "azurerm_resource_group" "res-0" {
  location = "canadacentral"
  name     = "CS-RG-WSS"
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
  name                                                   = "CSUT1VMWSSSQL01"
  network_interface_ids                                  = [azurerm_network_interface.res-25.id]
  os_managed_disk_id                                     = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/CS-RG-WSS/providers/Microsoft.Compute/disks/CSUT1VMWSSSQL01st1"
  resource_group_name                                    = azurerm_resource_group.res-0.name
  size                                                   = "Standard_E4s_v3"
  tags = {
    Application       = ""
    Category          = "CMHC"
    ExpirationDate    = "09.20.2026"
    MaintenanceWindow = "Window 3"
    Managed           = "True"
    OS                = "Server"
    Operational       = "True"
    Realm             = "Staging"
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
    storage_account_type = "Standard_LRS"
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
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/CS-RG-WSS/providers/Microsoft.Compute/disks/CSUT1VMWSSSQL01-disk01"
  virtual_machine_id = azurerm_windows_virtual_machine.res-1.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-3" {
  caching            = "ReadWrite"
  lun                = 1
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/CS-RG-WSS/providers/Microsoft.Compute/disks/CSUT1VMWSSSQL01-disk02"
  virtual_machine_id = azurerm_windows_virtual_machine.res-1.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-4" {
  caching            = "ReadWrite"
  lun                = 2
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/CS-RG-WSS/providers/Microsoft.Compute/disks/CSUT1VMWSSSQL01-disk03"
  virtual_machine_id = azurerm_windows_virtual_machine.res-1.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-5" {
  caching            = "ReadWrite"
  lun                = 3
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/CS-RG-WSS/providers/Microsoft.Compute/disks/CSUT1VMWSSSQL01-disk04"
  virtual_machine_id = azurerm_windows_virtual_machine.res-1.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-6" {
  caching            = "ReadWrite"
  lun                = 4
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/CS-RG-WSS/providers/Microsoft.Compute/disks/CSUT1VMWSSSQL01-disk05"
  virtual_machine_id = azurerm_windows_virtual_machine.res-1.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-7" {
  caching            = "ReadWrite"
  lun                = 5
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/CS-RG-WSS/providers/Microsoft.Compute/disks/CSUT1VMWSSSQL01-disk06"
  virtual_machine_id = azurerm_windows_virtual_machine.res-1.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-8" {
  caching            = "ReadWrite"
  lun                = 6
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/CS-RG-WSS/providers/Microsoft.Compute/disks/CSUT1VMWSSSQL01-disk07"
  virtual_machine_id = azurerm_windows_virtual_machine.res-1.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-9" {
  caching            = "ReadWrite"
  lun                = 7
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/CS-RG-WSS/providers/Microsoft.Compute/disks/CSUT1VMWSSSQL01-disk08"
  virtual_machine_id = azurerm_windows_virtual_machine.res-1.id
}
resource "azurerm_virtual_machine_extension" "res-10" {
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  name                       = "AzureMonitorWindowsAgent"
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.0"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-1.id
}
resource "azurerm_virtual_machine_extension" "res-11" {
  auto_upgrade_minor_version = true
  name                       = "AzureNetworkWatcherExtension"
  publisher                  = "Microsoft.Azure.NetworkWatcher"
  settings                   = jsonencode({})
  type                       = "NetworkWatcherAgentWindows"
  type_handler_version       = "1.4"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-1.id
}
resource "azurerm_virtual_machine_extension" "res-12" {
  auto_upgrade_minor_version = true
  name                       = "BGInfo"
  publisher                  = "Microsoft.Compute"
  type                       = "bginfo"
  type_handler_version       = "2.1"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-1.id
}
resource "azurerm_virtual_machine_extension" "res-13" {
  auto_upgrade_minor_version = true
  name                       = "DomainJoin"
  publisher                  = "Microsoft.Compute"
  settings = jsonencode({
    Name    = "cmhc-schl.gc.ca"
    OUPath  = "OU=STG,OU=Azure Central,OU=Servers,OU=CMHC_CloudServices,DC=cmhc-schl,DC=gc,DC=ca"
    Options = "3"
    Restart = "true"
    User    = "CMHC-SCHL\\svc_cmhc_vcs_asr"
  })
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-1.id
}
resource "azurerm_virtual_machine_extension" "res-14" {
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
resource "azurerm_virtual_machine_extension" "res-15" {
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
      Value    = "https://f5fd3c2a-4a79-4fb7-9fbe-7adf9571d713.agentsvc.cc.azure-automation.net/accounts/f5fd3c2a-4a79-4fb7-9fbe-7adf9571d713"
      }, {
      Name     = "NodeConfigurationName"
      TypeName = "System.String"
      Value    = "Azure_DSC_Med_STG.localhost"
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
resource "azurerm_virtual_machine_extension" "res-16" {
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  name                       = "MicrosoftDefenderForSQL"
  publisher                  = "Microsoft.Azure.AzureDefenderForSQL"
  type                       = "AdvancedThreatProtection.Windows"
  type_handler_version       = "2.0"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-1.id
}
resource "azurerm_virtual_machine_extension" "res-17" {
  auto_upgrade_minor_version = true
  name                       = "ChangeTracking-Windows"
  publisher                  = "Microsoft.Azure.ChangeTrackingAndInventory"
  type                       = "ChangeTracking-Windows"
  type_handler_version       = "2.0"
  virtual_machine_id         = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/CS-RG-WSS/providers/Microsoft.Compute/virtualMachines/csut1vmwsssql01"
  depends_on = [
    azurerm_windows_virtual_machine.res-1,
  ]
}
resource "azurerm_lb" "res-18" {
  location            = "canadacentral"
  name                = "CS-LBI-WSS-01"
  resource_group_name = azurerm_resource_group.res-0.name
  tags = {
    Application    = "WSS"
    ExpirationDate = "12.31.2027"
    SNOW-DEP       = "RITM7179605"
  }
  frontend_ip_configuration {
    name      = "CS-FEIP-WSS-01"
    subnet_id = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/azurecore-cent/providers/Microsoft.Network/virtualNetworks/centcmhc-vnet01/subnets/CSRDT-SUBNET02"
  }
  frontend_ip_configuration {
    name      = "CS-FEIP-WSS-02"
    subnet_id = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/azurecore-cent/providers/Microsoft.Network/virtualNetworks/centcmhc-vnet01/subnets/CSRDT-SUBNET02"
    zones     = ["1", "2", "3"]
  }
}
resource "azurerm_lb_backend_address_pool" "res-19" {
  loadbalancer_id = azurerm_lb.res-18.id
  name            = "CS-LBI-WSS-01-IP"
}
resource "azurerm_lb_backend_address_pool" "res-20" {
  loadbalancer_id = azurerm_lb.res-18.id
  name            = "CS-LBI-WSS-02-IP"
}
resource "azurerm_lb_rule" "res-21" {
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.res-19.id]
  backend_port                   = 40002
  disable_outbound_snat          = true
  frontend_ip_configuration_name = "CS-FEIP-WSS-01"
  frontend_port                  = 40002
  loadbalancer_id                = azurerm_lb.res-18.id
  name                           = "SQLAlwaysOnEndPointListener"
  probe_id                       = azurerm_lb_probe.res-23.id
  protocol                       = "Tcp"
}
resource "azurerm_lb_rule" "res-22" {
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.res-20.id]
  backend_port                   = 40003
  disable_outbound_snat          = true
  frontend_ip_configuration_name = "CS-FEIP-WSS-02"
  frontend_port                  = 40003
  loadbalancer_id                = azurerm_lb.res-18.id
  name                           = "SQLAlwaysOnEndPointListener_WSS_EIT"
  probe_id                       = azurerm_lb_probe.res-24.id
  protocol                       = "Tcp"
}
resource "azurerm_lb_probe" "res-23" {
  interval_in_seconds = 5
  loadbalancer_id     = azurerm_lb.res-18.id
  name                = "SQLAlwaysOnEndPointProbe"
  number_of_probes    = 1
  port                = 59999
}
resource "azurerm_lb_probe" "res-24" {
  interval_in_seconds = 5
  loadbalancer_id     = azurerm_lb.res-18.id
  name                = "SQLAlwaysOnEndPointProbe_WSS_EIT"
  number_of_probes    = 1
  port                = 59998
}
resource "azurerm_network_interface" "res-25" {
  location            = "canadacentral"
  name                = "CSUT1VMWSSSQL01-Nic01"
  resource_group_name = azurerm_resource_group.res-0.name
  tags = {
    Application       = ""
    ExpirationDate    = "09.20.2026"
    MaintenanceWindow = "Not Applicable"
    Realm             = "Staging"
    SNOW-DEP          = "RITM7181805"
  }
  ip_configuration {
    name                          = "CSUT1VMWSSSQL01-NicConfig"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/azurecore-cent/providers/Microsoft.Network/virtualNetworks/centcmhc-vnet01/subnets/CSRDT-SUBNET02"
  }
}
resource "azurerm_virtual_machine_extension" "res-26" {
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  name                       = "SqlIaasExtension"
  publisher                  = "Microsoft.SqlServer.Management"
  settings = jsonencode({
    DeploymentTokenSettings = {
      DeploymentToken = 2105379435
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
  virtual_machine_id   = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/cs-rg-wss/providers/Microsoft.Compute/virtualMachines/csut1vmwsssql01"
  depends_on = [
    azurerm_windows_virtual_machine.res-1,
  ]
}
