resource "azurerm_resource_group" "res-0" {
  location = "canadaeast"
  name     = "ED-RG-WSS"
  tags = {
    Application    = "WSS"
    ExpirationDate = "08.17.2027"
    SNOW-DEP       = "RITM7179605"
  }
}
resource "azurerm_availability_set" "res-1" {
  location                    = "canadaeast"
  name                        = "EDDV1-AVAIL-WSS01"
  platform_fault_domain_count = 2
  resource_group_name         = azurerm_resource_group.res-0.name
  tags = {
    Application       = "WSS"
    ExpirationDate    = "08.17.2027"
    MaintenanceWindow = "Not Applicable"
    Realm             = "Development"
    SNOW-DEP          = "RITM7179605"
  }
}
resource "azurerm_windows_virtual_machine" "res-2" {
  admin_password                                         = "ignored-as-imported"
  admin_username                                         = "cmhcadmin"
  bypass_platform_safety_checks_on_user_schedule_enabled = true
  license_type                                           = "Windows_Server"
  location                                               = "canadaeast"
  name                                                   = "EDDV1VMWSSAPP01"
  network_interface_ids                                  = [azurerm_network_interface.res-50.id]
  os_managed_disk_id                                     = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ED-RG-WSS/providers/Microsoft.Compute/disks/EDDV1VMWSSAPP01st1"
  resource_group_name                                    = azurerm_resource_group.res-0.name
  size                                                   = "Standard_E4s_v3"
  tags = {
    Application                = "WSS"
    Category                   = "CMHC"
    Excludemdeautoprovisioning = "true"
    ExpirationDate             = "08.17.2027"
    MaintenanceWindow          = "Window 1"
    Managed                    = "True"
    OS                         = "Server"
    Operational                = "True"
    Realm                      = "Development"
    SNOW-DEP                   = "RITM7179605"
  }
  boot_diagnostics {
    storage_account_uri = "https://ediaglogsilvsa01.blob.core.windows.net/"
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
resource "azurerm_virtual_machine_data_disk_attachment" "res-3" {
  caching            = "None"
  lun                = 0
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ED-RG-WSS/providers/Microsoft.Compute/disks/EDDV1VMWSSAPP01-disk-01"
  virtual_machine_id = azurerm_windows_virtual_machine.res-2.id
}
resource "azurerm_virtual_machine_extension" "res-4" {
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  name                       = "AzureMonitorWindowsAgent"
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.0"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-2.id
}
resource "azurerm_virtual_machine_extension" "res-5" {
  auto_upgrade_minor_version = true
  name                       = "BGInfo"
  publisher                  = "Microsoft.Compute"
  type                       = "bginfo"
  type_handler_version       = "2.1"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-2.id
}
resource "azurerm_virtual_machine_extension" "res-6" {
  auto_upgrade_minor_version = true
  name                       = "DomainJoin"
  publisher                  = "Microsoft.Compute"
  settings = jsonencode({
    Name    = "cmhc-schl.gc.ca"
    OUPath  = "OU=DEV,OU=Azure East,OU=Servers,OU=CMHC_CloudServices,DC=cmhc-schl,DC=gc,DC=ca"
    Options = "3"
    Restart = "true"
    User    = "CMHC-SCHL\\svc_cmhc_vcs_asr"
  })
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-2.id
}
resource "azurerm_virtual_machine_extension" "res-7" {
  auto_upgrade_minor_version = true
  name                       = "MDE.Windows"
  publisher                  = "Microsoft.Azure.AzureDefenderForServers"
  settings = jsonencode({
    autoUpdate        = true
    azureResourceId   = azurerm_windows_virtual_machine.res-2.id
    forceReOnboarding = false
    vNextEnabled      = true
  })
  type                 = "MDE.Windows"
  type_handler_version = "1.0"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-2.id
}
resource "azurerm_virtual_machine_extension" "res-8" {
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
      Value    = "https://fdb38a2e-fc00-4456-a7b2-b6d318fafead.agentsvc.cc.azure-automation.net/accounts/fdb38a2e-fc00-4456-a7b2-b6d318fafead"
      }, {
      Name     = "NodeConfigurationName"
      TypeName = "System.String"
      Value    = "Azure_DSC_Med_DEV.localhost"
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
  virtual_machine_id   = azurerm_windows_virtual_machine.res-2.id
}
resource "azurerm_virtual_machine_extension" "res-9" {
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  name                       = "MicrosoftDefenderForSQL"
  publisher                  = "Microsoft.Azure.AzureDefenderForSQL"
  type                       = "AdvancedThreatProtection.Windows"
  type_handler_version       = "2.0"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-2.id
}
resource "azurerm_windows_virtual_machine" "res-10" {
  admin_password                                         = "ignored-as-imported"
  admin_username                                         = "cmhcadmin"
  availability_set_id                                    = azurerm_availability_set.res-1.id
  bypass_platform_safety_checks_on_user_schedule_enabled = true
  license_type                                           = "Windows_Server"
  location                                               = "canadaeast"
  name                                                   = "EDDV1VMWSSSQL01"
  network_interface_ids                                  = [azurerm_network_interface.res-51.id]
  os_managed_disk_id                                     = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ED-RG-WSS/providers/Microsoft.Compute/disks/EDDV1VMWSSSQL01st1"
  resource_group_name                                    = azurerm_resource_group.res-0.name
  size                                                   = "Standard_D12_v2"
  tags = {
    Application       = "WSS"
    Category          = "CMHC"
    ExpirationDate    = "08.17.2027"
    MaintenanceWindow = "Window 1"
    Managed           = "True"
    OS                = "Server"
    Operational       = "True"
    Realm             = "Development"
    SNOW-DEP          = "RITM7179605"
  }
  boot_diagnostics {
    storage_account_uri = "https://ediaglogsilvsa01.blob.core.windows.net/"
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
resource "azurerm_virtual_machine_data_disk_attachment" "res-11" {
  caching            = "None"
  lun                = 0
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ED-RG-WSS/providers/Microsoft.Compute/disks/EDDV1VMWSSSQL01-disk-01"
  virtual_machine_id = azurerm_windows_virtual_machine.res-10.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-12" {
  caching            = "None"
  lun                = 1
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ED-RG-WSS/providers/Microsoft.Compute/disks/EDDV1VMWSSSQL01-disk-02"
  virtual_machine_id = azurerm_windows_virtual_machine.res-10.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-13" {
  caching            = "None"
  lun                = 2
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ED-RG-WSS/providers/Microsoft.Compute/disks/EDDV1VMWSSSQL01-disk-03"
  virtual_machine_id = azurerm_windows_virtual_machine.res-10.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-14" {
  caching            = "None"
  lun                = 3
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ED-RG-WSS/providers/Microsoft.Compute/disks/EDDV1VMWSSSQL01-disk-04"
  virtual_machine_id = azurerm_windows_virtual_machine.res-10.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-15" {
  caching            = "None"
  lun                = 4
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ED-RG-WSS/providers/Microsoft.Compute/disks/EDDV1VMWSSSQL01-disk-05"
  virtual_machine_id = azurerm_windows_virtual_machine.res-10.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-16" {
  caching            = "None"
  lun                = 5
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ED-RG-WSS/providers/Microsoft.Compute/disks/EDDV1VMWSSSQL01-disk-06"
  virtual_machine_id = azurerm_windows_virtual_machine.res-10.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-17" {
  caching            = "None"
  lun                = 6
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ED-RG-WSS/providers/Microsoft.Compute/disks/EDDV1VMWSSSQL01-disk-07"
  virtual_machine_id = azurerm_windows_virtual_machine.res-10.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-18" {
  caching            = "None"
  lun                = 7
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ED-RG-WSS/providers/Microsoft.Compute/disks/EDDV1VMWSSSQL01-disk-08"
  virtual_machine_id = azurerm_windows_virtual_machine.res-10.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-19" {
  caching            = "None"
  lun                = 8
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ED-RG-WSS/providers/Microsoft.Compute/disks/EDDV1VMWSSSQL01-disk-09"
  virtual_machine_id = azurerm_windows_virtual_machine.res-10.id
}
resource "azurerm_virtual_machine_extension" "res-20" {
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  name                       = "AzureMonitorWindowsAgent"
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.0"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-10.id
}
resource "azurerm_virtual_machine_extension" "res-21" {
  auto_upgrade_minor_version = true
  name                       = "AzureNetworkWatcherExtension"
  publisher                  = "Microsoft.Azure.NetworkWatcher"
  settings                   = jsonencode({})
  type                       = "NetworkWatcherAgentWindows"
  type_handler_version       = "1.4"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-10.id
}
resource "azurerm_virtual_machine_extension" "res-22" {
  auto_upgrade_minor_version = true
  name                       = "BGInfo"
  publisher                  = "Microsoft.Compute"
  type                       = "bginfo"
  type_handler_version       = "2.1"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-10.id
}
resource "azurerm_virtual_machine_extension" "res-23" {
  auto_upgrade_minor_version = true
  name                       = "DomainJoin"
  publisher                  = "Microsoft.Compute"
  settings = jsonencode({
    Name    = "cmhc-schl.gc.ca"
    OUPath  = "OU=DEV,OU=Azure East,OU=Servers,OU=CMHC_CloudServices,DC=cmhc-schl,DC=gc,DC=ca"
    Options = "3"
    Restart = "true"
    User    = "CMHC-SCHL\\svc_cmhc_vcs_asr"
  })
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-10.id
}
resource "azurerm_virtual_machine_extension" "res-24" {
  auto_upgrade_minor_version = true
  name                       = "MDE.Windows"
  publisher                  = "Microsoft.Azure.AzureDefenderForServers"
  settings = jsonencode({
    autoUpdate        = true
    azureResourceId   = azurerm_windows_virtual_machine.res-10.id
    forceReOnboarding = false
    vNextEnabled      = true
  })
  type                 = "MDE.Windows"
  type_handler_version = "1.0"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-10.id
}
resource "azurerm_virtual_machine_extension" "res-25" {
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
      Value    = "https://fdb38a2e-fc00-4456-a7b2-b6d318fafead.agentsvc.cc.azure-automation.net/accounts/fdb38a2e-fc00-4456-a7b2-b6d318fafead"
      }, {
      Name     = "NodeConfigurationName"
      TypeName = "System.String"
      Value    = "Azure_DSC_Med_DEV.localhost"
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
  virtual_machine_id   = azurerm_windows_virtual_machine.res-10.id
}
resource "azurerm_virtual_machine_extension" "res-26" {
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  name                       = "MicrosoftDefenderForSQL"
  publisher                  = "Microsoft.Azure.AzureDefenderForSQL"
  type                       = "AdvancedThreatProtection.Windows"
  type_handler_version       = "2.0"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-10.id
}
resource "azurerm_windows_virtual_machine" "res-27" {
  admin_password                                         = "ignored-as-imported"
  admin_username                                         = "cmhcadmin"
  availability_set_id                                    = azurerm_availability_set.res-1.id
  bypass_platform_safety_checks_on_user_schedule_enabled = true
  license_type                                           = "Windows_Server"
  location                                               = "canadaeast"
  name                                                   = "EDDV1VMWSSSQL02"
  network_interface_ids                                  = [azurerm_network_interface.res-52.id]
  os_managed_disk_id                                     = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ED-RG-WSS/providers/Microsoft.Compute/disks/EDDV1VMWSSSQL02st1"
  resource_group_name                                    = azurerm_resource_group.res-0.name
  size                                                   = "Standard_D12_v2"
  tags = {
    Application       = "WSS"
    Category          = "CMHC"
    ExpirationDate    = "08.17.2027"
    MaintenanceWindow = "Window 1"
    Managed           = "True"
    OS                = "Server"
    Operational       = "True"
    Realm             = "Development"
    SNOW-DEP          = "RITM7179605"
  }
  boot_diagnostics {
    storage_account_uri = "https://ediaglogsilvsa01.blob.core.windows.net/"
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
resource "azurerm_virtual_machine_data_disk_attachment" "res-28" {
  caching            = "None"
  lun                = 0
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ED-RG-WSS/providers/Microsoft.Compute/disks/EDDV1VMWSSSQL02-disk-01"
  virtual_machine_id = azurerm_windows_virtual_machine.res-27.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-29" {
  caching            = "None"
  lun                = 1
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ED-RG-WSS/providers/Microsoft.Compute/disks/EDDV1VMWSSSQL02-disk-02"
  virtual_machine_id = azurerm_windows_virtual_machine.res-27.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-30" {
  caching            = "None"
  lun                = 2
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ED-RG-WSS/providers/Microsoft.Compute/disks/EDDV1VMWSSSQL02-disk-03"
  virtual_machine_id = azurerm_windows_virtual_machine.res-27.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-31" {
  caching            = "None"
  lun                = 3
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ED-RG-WSS/providers/Microsoft.Compute/disks/EDDV1VMWSSSQL02-disk-04"
  virtual_machine_id = azurerm_windows_virtual_machine.res-27.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-32" {
  caching            = "None"
  lun                = 4
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ED-RG-WSS/providers/Microsoft.Compute/disks/EDDV1VMWSSSQL02-disk-05"
  virtual_machine_id = azurerm_windows_virtual_machine.res-27.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-33" {
  caching            = "None"
  lun                = 5
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ED-RG-WSS/providers/Microsoft.Compute/disks/EDDV1VMWSSSQL02-disk-06"
  virtual_machine_id = azurerm_windows_virtual_machine.res-27.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-34" {
  caching            = "None"
  lun                = 6
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ED-RG-WSS/providers/Microsoft.Compute/disks/EDDV1VMWSSSQL02-disk-07"
  virtual_machine_id = azurerm_windows_virtual_machine.res-27.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-35" {
  caching            = "None"
  lun                = 7
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ED-RG-WSS/providers/Microsoft.Compute/disks/EDDV1VMWSSSQL02-disk-08"
  virtual_machine_id = azurerm_windows_virtual_machine.res-27.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-36" {
  caching            = "None"
  lun                = 8
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ED-RG-WSS/providers/Microsoft.Compute/disks/EDDV1VMWSSSQL02-disk-09"
  virtual_machine_id = azurerm_windows_virtual_machine.res-27.id
}
resource "azurerm_virtual_machine_extension" "res-37" {
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  name                       = "AzureMonitorWindowsAgent"
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.0"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-27.id
}
resource "azurerm_virtual_machine_extension" "res-38" {
  auto_upgrade_minor_version = true
  name                       = "BGInfo"
  publisher                  = "Microsoft.Compute"
  type                       = "bginfo"
  type_handler_version       = "2.1"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-27.id
}
resource "azurerm_virtual_machine_extension" "res-39" {
  auto_upgrade_minor_version = true
  name                       = "DomainJoin"
  publisher                  = "Microsoft.Compute"
  settings = jsonencode({
    Name    = "cmhc-schl.gc.ca"
    OUPath  = "OU=DEV,OU=Azure East,OU=Servers,OU=CMHC_CloudServices,DC=cmhc-schl,DC=gc,DC=ca"
    Options = "3"
    Restart = "true"
    User    = "CMHC-SCHL\\svc_cmhc_vcs_asr"
  })
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-27.id
}
resource "azurerm_virtual_machine_extension" "res-40" {
  auto_upgrade_minor_version = true
  name                       = "MDE.Windows"
  publisher                  = "Microsoft.Azure.AzureDefenderForServers"
  settings = jsonencode({
    autoUpdate        = true
    azureResourceId   = azurerm_windows_virtual_machine.res-27.id
    forceReOnboarding = false
    vNextEnabled      = true
  })
  type                 = "MDE.Windows"
  type_handler_version = "1.0"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-27.id
}
resource "azurerm_virtual_machine_extension" "res-41" {
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
      Value    = "https://fdb38a2e-fc00-4456-a7b2-b6d318fafead.agentsvc.cc.azure-automation.net/accounts/fdb38a2e-fc00-4456-a7b2-b6d318fafead"
      }, {
      Name     = "NodeConfigurationName"
      TypeName = "System.String"
      Value    = "Azure_DSC_Med_DEV.localhost"
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
  virtual_machine_id   = azurerm_windows_virtual_machine.res-27.id
}
resource "azurerm_virtual_machine_extension" "res-42" {
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  name                       = "MicrosoftDefenderForSQL"
  publisher                  = "Microsoft.Azure.AzureDefenderForSQL"
  type                       = "AdvancedThreatProtection.Windows"
  type_handler_version       = "2.0"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-27.id
}
resource "azurerm_virtual_machine_extension" "res-43" {
  auto_upgrade_minor_version = true
  name                       = "ChangeTracking-Windows"
  publisher                  = "Microsoft.Azure.ChangeTrackingAndInventory"
  type                       = "ChangeTracking-Windows"
  type_handler_version       = "2.0"
  virtual_machine_id         = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ED-RG-WSS/providers/Microsoft.Compute/virtualMachines/eddv1vmwssapp01"
  depends_on = [
    azurerm_windows_virtual_machine.res-2,
  ]
}
resource "azurerm_virtual_machine_extension" "res-44" {
  auto_upgrade_minor_version = true
  name                       = "ChangeTracking-Windows"
  publisher                  = "Microsoft.Azure.ChangeTrackingAndInventory"
  type                       = "ChangeTracking-Windows"
  type_handler_version       = "2.0"
  virtual_machine_id         = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ED-RG-WSS/providers/Microsoft.Compute/virtualMachines/eddv1vmwsssql01"
  depends_on = [
    azurerm_windows_virtual_machine.res-10,
  ]
}
resource "azurerm_virtual_machine_extension" "res-45" {
  auto_upgrade_minor_version = true
  name                       = "ChangeTracking-Windows"
  publisher                  = "Microsoft.Azure.ChangeTrackingAndInventory"
  type                       = "ChangeTracking-Windows"
  type_handler_version       = "2.0"
  virtual_machine_id         = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ED-RG-WSS/providers/Microsoft.Compute/virtualMachines/eddv1vmwsssql02"
  depends_on = [
    azurerm_windows_virtual_machine.res-27,
  ]
}
resource "azurerm_lb" "res-46" {
  location            = "canadaeast"
  name                = "ED-LBI-WSS-01"
  resource_group_name = azurerm_resource_group.res-0.name
  tags = {
    Application    = "WSS"
    ExpirationDate = "08.17.2027"
    SNOW-DEP       = "RITM7179605"
  }
  frontend_ip_configuration {
    name      = "ED-FEIP-WSS-01"
    subnet_id = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/AzureCore-East/providers/Microsoft.Network/virtualNetworks/eastcmhc-vnet01/subnets/EDRDT-SUBNET01"
  }
}
resource "azurerm_lb_backend_address_pool" "res-47" {
  loadbalancer_id = azurerm_lb.res-46.id
  name            = "ED-LBI-WSS-Pool-IP"
}
resource "azurerm_lb_rule" "res-48" {
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.res-47.id]
  backend_port                   = 40002
  disable_outbound_snat          = true
  frontend_ip_configuration_name = "ED-FEIP-WSS-01"
  frontend_port                  = 40002
  loadbalancer_id                = azurerm_lb.res-46.id
  name                           = "SQLAlwaysOnEndPointListener"
  probe_id                       = azurerm_lb_probe.res-49.id
  protocol                       = "Tcp"
}
resource "azurerm_lb_probe" "res-49" {
  interval_in_seconds = 5
  loadbalancer_id     = azurerm_lb.res-46.id
  name                = "SQLAlwaysOnEndPointProbe"
  number_of_probes    = 1
  port                = 59999
}
resource "azurerm_network_interface" "res-50" {
  location            = "canadaeast"
  name                = "EDDV1VMWSSAPP01-Nic01"
  resource_group_name = azurerm_resource_group.res-0.name
  tags = {
    Application       = "WSS"
    ExpirationDate    = "08.17.2027"
    MaintenanceWindow = "Not Applicable"
    Realm             = "Development"
    SNOW-DEP          = "RITM7179605"
  }
  ip_configuration {
    name                          = "EDDV1VMWSSAPP01-NicConfig"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/AzureCore-East/providers/Microsoft.Network/virtualNetworks/eastcmhc-vnet01/subnets/EDRAP-SUBNET01"
  }
}
resource "azurerm_network_interface" "res-51" {
  location            = "canadaeast"
  name                = "EDDV1VMWSSSQL01-Nic01"
  resource_group_name = azurerm_resource_group.res-0.name
  tags = {
    Application       = "WSS"
    ExpirationDate    = "08.17.2027"
    MaintenanceWindow = "Not Applicable"
    Realm             = "Development"
    SNOW-DEP          = "RITM7179605"
  }
  ip_configuration {
    name                          = "EDDV1VMWSSSQL01-NicConfig"
    private_ip_address_allocation = "Static"
    subnet_id                     = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/AzureCore-East/providers/Microsoft.Network/virtualNetworks/eastcmhc-vnet01/subnets/EDRDT-SUBNET01"
  }
}
resource "azurerm_network_interface" "res-52" {
  location            = "canadaeast"
  name                = "EDDV1VMWSSSQL02-Nic01"
  resource_group_name = azurerm_resource_group.res-0.name
  tags = {
    Application       = "WSS"
    ExpirationDate    = "08.17.2027"
    MaintenanceWindow = "Not Applicable"
    Realm             = "Development"
    SNOW-DEP          = "RITM7179605"
  }
  ip_configuration {
    name                          = "EDDV1VMWSSSQL02-NicConfig"
    private_ip_address_allocation = "Static"
    subnet_id                     = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/AzureCore-East/providers/Microsoft.Network/virtualNetworks/eastcmhc-vnet01/subnets/EDRDT-SUBNET01"
  }
}
resource "azurerm_virtual_machine_extension" "res-53" {
  name      = "AzureBackupWindowsWorkload"
  publisher = "Microsoft.Azure.RecoveryServices.WorkloadBackup"
  settings = jsonencode({
    commandStartTimeUTCTicks = "639046162275733054"
    locale                   = "en-us"
    objectStr                = "eyJXb3JrbG9hZFR5cGVzTGlzdCI6WyJTUUwiXSwiY29udGFpbmVyUHJvcGVydGllcyI6eyJDb250YWluZXJJRCI6Ilwvc3Vic2NyaXB0aW9uc1wvNTkxOGRiOWMtMjVjMS00NTY0LTkwNzktNjY1MzYyYTBiMGMyXC9yZXNvdXJjZUdyb3Vwc1wvRUQtUkctV1NTXC9wcm92aWRlcnNcL01pY3Jvc29mdC5Db21wdXRlXC92aXJ0dWFsTWFjaGluZXNcL0VERFYxVk1XU1NTUUwwMSIsIklkTWdtdENvbnRhaW5lcklkIjozMDUxMjM0LCJQcm92aWRlclR5cGUiOiJBenVyZVdvcmtsb2FkIiwiUmVzb3VyY2VJZCI6IjU1MTM3MTg1Mjc3OTY5OTU1NTYiLCJTdWJzY3JpcHRpb25JZCI6IjU5MThkYjljLTI1YzEtNDU2NC05MDc5LTY2NTM2MmEwYjBjMiIsIlVuaXF1ZUNvbnRhaW5lck5hbWUiOiJjb21wdXRlO0VELVJHLVdTUztFRERWMVZNV1NTU1FMMDEiLCJWYXVsdFByaXZhdGVFbmRwb2ludFN0YXRlIjoiTm9uZSJ9LCJyZWdpc3RyYXRpb25UeXBlIjoiUmVnaXN0cmF0aW9uIiwic3RhbXBMaXN0IjpbeyJTZXJ2aWNlTmFtZSI6NSwiU2VydmljZVN0YW1wVXJsIjoiaHR0cHM6XC9cL3BvZDAxLXdiY20xLmNuZS5iYWNrdXAud2luZG93c2F6dXJlLmNvbSJ9LHsiU2VydmljZU5hbWUiOjMsIlNlcnZpY2VTdGFtcFVybCI6Imh0dHBzOlwvXC9wb2QwMS1tb24xLmNuZS5iYWNrdXAud2luZG93c2F6dXJlLmNvbSJ9LHsiU2VydmljZU5hbWUiOjYsIlNlcnZpY2VTdGFtcFVybCI6Imh0dHBzOlwvXC9wb2QwMS1wcm90MS5jbmUuYmFja3VwLndpbmRvd3NhenVyZS5jb20ifSx7IlNlcnZpY2VOYW1lIjoxLCJTZXJ2aWNlU3RhbXBVcmwiOiJodHRwczpcL1wvcG9kMDEtaWQxLmNuZS5iYWNrdXAud2luZG93c2F6dXJlLmNvbSJ9LHsiU2VydmljZU5hbWUiOjQsIlNlcnZpY2VTdGFtcFVybCI6Imh0dHBzOlwvXC9wb2QwMS1lY3MxLmNuZS5iYWNrdXAud2luZG93c2F6dXJlLmNvbSJ9LHsiU2VydmljZU5hbWUiOjIsIlNlcnZpY2VTdGFtcFVybCI6Imh0dHBzOlwvXC9wb2QwMS1tYW5hZzEuY25lLmJhY2t1cC53aW5kb3dzYXp1cmUuY29tIn0seyJTZXJ2aWNlTmFtZSI6NywiU2VydmljZVN0YW1wVXJsIjoiaHR0cHM6XC9cL3BvZDAxLWZhYjEuY25lLmJhY2t1cC53aW5kb3dzYXp1cmUuY29tIn0seyJTZXJ2aWNlTmFtZSI6OCwiU2VydmljZVN0YW1wVXJsIjoiaHR0cHM6XC9cL3BvZDAxLXRlbDEuY25lLmJhY2t1cC53aW5kb3dzYXp1cmUuY29tIn1dfQ=="
    taskId                   = "cfc67e75-ce17-49a2-b831-9bcfce82620f"
    triggerForceUpgrade      = false
    vmType                   = "microsoft.compute/virtualmachines"
  })
  type                 = "AzureBackupWindowsWorkload"
  type_handler_version = "1.1"
  virtual_machine_id   = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ed-rg-wss/providers/Microsoft.Compute/virtualMachines/eddv1vmwsssql01"
  depends_on = [
    azurerm_windows_virtual_machine.res-10,
  ]
}
resource "azurerm_virtual_machine_extension" "res-54" {
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  name                       = "SqlIaasExtension"
  publisher                  = "Microsoft.SqlServer.Management"
  settings = jsonencode({
    DeploymentTokenSettings = {
      DeploymentToken = 1960475819
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
  virtual_machine_id   = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ed-rg-wss/providers/Microsoft.Compute/virtualMachines/eddv1vmwsssql01"
  depends_on = [
    azurerm_windows_virtual_machine.res-10,
  ]
}
resource "azurerm_virtual_machine_extension" "res-55" {
  name      = "AzureBackupWindowsWorkload"
  publisher = "Microsoft.Azure.RecoveryServices.WorkloadBackup"
  settings = jsonencode({
    commandStartTimeUTCTicks = "639046169919342637"
    locale                   = "en-us"
    objectStr                = "eyJXb3JrbG9hZFR5cGVzTGlzdCI6WyJTUUwiXSwiY29udGFpbmVyUHJvcGVydGllcyI6eyJDb250YWluZXJJRCI6Ilwvc3Vic2NyaXB0aW9uc1wvNTkxOGRiOWMtMjVjMS00NTY0LTkwNzktNjY1MzYyYTBiMGMyXC9yZXNvdXJjZUdyb3Vwc1wvRUQtUkctV1NTXC9wcm92aWRlcnNcL01pY3Jvc29mdC5Db21wdXRlXC92aXJ0dWFsTWFjaGluZXNcL0VERFYxVk1XU1NTUUwwMiIsIklkTWdtdENvbnRhaW5lcklkIjozMDUxNDM4LCJQcm92aWRlclR5cGUiOiJBenVyZVdvcmtsb2FkIiwiUmVzb3VyY2VJZCI6IjU1MTM3MTg1Mjc3OTY5OTU1NTYiLCJTdWJzY3JpcHRpb25JZCI6IjU5MThkYjljLTI1YzEtNDU2NC05MDc5LTY2NTM2MmEwYjBjMiIsIlVuaXF1ZUNvbnRhaW5lck5hbWUiOiJjb21wdXRlO0VELVJHLVdTUztFRERWMVZNV1NTU1FMMDIiLCJWYXVsdFByaXZhdGVFbmRwb2ludFN0YXRlIjoiTm9uZSJ9LCJyZWdpc3RyYXRpb25UeXBlIjoiUmVnaXN0cmF0aW9uIiwic3RhbXBMaXN0IjpbeyJTZXJ2aWNlTmFtZSI6NSwiU2VydmljZVN0YW1wVXJsIjoiaHR0cHM6XC9cL3BvZDAxLXdiY20xLmNuZS5iYWNrdXAud2luZG93c2F6dXJlLmNvbSJ9LHsiU2VydmljZU5hbWUiOjMsIlNlcnZpY2VTdGFtcFVybCI6Imh0dHBzOlwvXC9wb2QwMS1tb24xLmNuZS5iYWNrdXAud2luZG93c2F6dXJlLmNvbSJ9LHsiU2VydmljZU5hbWUiOjYsIlNlcnZpY2VTdGFtcFVybCI6Imh0dHBzOlwvXC9wb2QwMS1wcm90MS5jbmUuYmFja3VwLndpbmRvd3NhenVyZS5jb20ifSx7IlNlcnZpY2VOYW1lIjoxLCJTZXJ2aWNlU3RhbXBVcmwiOiJodHRwczpcL1wvcG9kMDEtaWQxLmNuZS5iYWNrdXAud2luZG93c2F6dXJlLmNvbSJ9LHsiU2VydmljZU5hbWUiOjQsIlNlcnZpY2VTdGFtcFVybCI6Imh0dHBzOlwvXC9wb2QwMS1lY3MxLmNuZS5iYWNrdXAud2luZG93c2F6dXJlLmNvbSJ9LHsiU2VydmljZU5hbWUiOjIsIlNlcnZpY2VTdGFtcFVybCI6Imh0dHBzOlwvXC9wb2QwMS1tYW5hZzEuY25lLmJhY2t1cC53aW5kb3dzYXp1cmUuY29tIn0seyJTZXJ2aWNlTmFtZSI6NywiU2VydmljZVN0YW1wVXJsIjoiaHR0cHM6XC9cL3BvZDAxLWZhYjEuY25lLmJhY2t1cC53aW5kb3dzYXp1cmUuY29tIn0seyJTZXJ2aWNlTmFtZSI6OCwiU2VydmljZVN0YW1wVXJsIjoiaHR0cHM6XC9cL3BvZDAxLXRlbDEuY25lLmJhY2t1cC53aW5kb3dzYXp1cmUuY29tIn1dfQ=="
    taskId                   = "97040edc-f633-4f4a-9797-ff0ca48edb97"
    triggerForceUpgrade      = false
    vmType                   = "microsoft.compute/virtualmachines"
  })
  type                 = "AzureBackupWindowsWorkload"
  type_handler_version = "1.1"
  virtual_machine_id   = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ed-rg-wss/providers/Microsoft.Compute/virtualMachines/eddv1vmwsssql02"
  depends_on = [
    azurerm_windows_virtual_machine.res-27,
  ]
}
resource "azurerm_virtual_machine_extension" "res-56" {
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  name                       = "SqlIaasExtension"
  publisher                  = "Microsoft.SqlServer.Management"
  settings = jsonencode({
    DeploymentTokenSettings = {
      DeploymentToken = 1257203002
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
  virtual_machine_id   = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ed-rg-wss/providers/Microsoft.Compute/virtualMachines/eddv1vmwsssql02"
  depends_on = [
    azurerm_windows_virtual_machine.res-27,
  ]
}
