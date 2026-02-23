resource "azurerm_resource_group" "res-0" {
  location = "canadaeast"
  name     = "EP-RG-WSS"
  tags = {
    Application    = "WSS"
    ExpirationDate = "9.20.2026"
    SNOW-DEP       = "RITM7181805"
  }
}
resource "azurerm_availability_set" "res-1" {
  location                    = "canadaeast"
  name                        = "EPPD1-AVAIL-WSS01"
  platform_fault_domain_count = 2
  resource_group_name         = azurerm_resource_group.res-0.name
  tags = {
    Application       = "WSS"
    ExpirationDate    = "09.20.2026"
    MaintenanceWindow = "Not Applicable"
    Realm             = "Production"
    SNOW-DEP          = "RITM7181805"
  }
}
resource "azurerm_windows_virtual_machine" "res-2" {
  admin_password                                         = "ignored-as-imported"
  admin_username                                         = "cmhcadmin"
  bypass_platform_safety_checks_on_user_schedule_enabled = true
  license_type                                           = "Windows_Server"
  location                                               = "canadaeast"
  name                                                   = "EPPD1VMWSSAPP01"
  network_interface_ids                                  = [azurerm_network_interface.res-40.id]
  os_managed_disk_id                                     = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/EP-RG-WSS/providers/Microsoft.Compute/disks/EPPD1VMWSSAPP01st1"
  resource_group_name                                    = azurerm_resource_group.res-0.name
  size                                                   = "Standard_F32s_v2"
  tags = {
    Application       = "WSS"
    Category          = "CMHC"
    ExpirationDate    = "09.20.2026"
    MaintenanceWindow = "Window 6"
    Managed           = "True"
    OS                = "Server"
    Operational       = "True"
    Realm             = "Production"
    SNOW-DEP          = "RITM7181805"
  }
  boot_diagnostics {
    storage_account_uri = "https://ediaglogsilvsa01.blob.core.windows.net/"
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
resource "azurerm_virtual_machine_data_disk_attachment" "res-3" {
  caching            = "None"
  lun                = 0
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/EP-RG-WSS/providers/Microsoft.Compute/disks/EPPD1VMWSSAPP01st2"
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
  automatic_upgrade_enabled  = true
  name                       = "AzureNetworkWatcherExtension"
  publisher                  = "Microsoft.Azure.NetworkWatcher"
  settings                   = jsonencode({})
  type                       = "NetworkWatcherAgentWindows"
  type_handler_version       = "1.4"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-2.id
}
resource "azurerm_virtual_machine_extension" "res-6" {
  auto_upgrade_minor_version = true
  name                       = "BGInfo"
  publisher                  = "Microsoft.Compute"
  type                       = "bginfo"
  type_handler_version       = "2.1"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-2.id
}
resource "azurerm_virtual_machine_extension" "res-7" {
  auto_upgrade_minor_version = true
  name                       = "DomainJoin"
  publisher                  = "Microsoft.Compute"
  settings = jsonencode({
    Name    = "cmhc-schl.gc.ca"
    OUPath  = "OU=PRD,OU=Azure East,OU=Servers,OU=CMHC_CloudServices,DC=cmhc-schl,DC=gc,DC=ca"
    Options = "3"
    Restart = "true"
    User    = "CMHC-SCHL\\svc_cmhc_vcs_asr"
  })
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-2.id
}
resource "azurerm_virtual_machine_extension" "res-8" {
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
resource "azurerm_virtual_machine_extension" "res-9" {
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
  virtual_machine_id   = azurerm_windows_virtual_machine.res-2.id
}
resource "azurerm_virtual_machine_extension" "res-10" {
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  name                       = "MicrosoftDefenderForSQL"
  publisher                  = "Microsoft.Azure.AzureDefenderForSQL"
  type                       = "AdvancedThreatProtection.Windows"
  type_handler_version       = "2.0"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-2.id
}
resource "azurerm_virtual_machine_extension" "res-11" {
  auto_upgrade_minor_version = true
  name                       = "PSScript"
  publisher                  = "Microsoft.Compute"
  settings = jsonencode({
    commandToExecute = "powershell -ExecutionPolicy Unrestricted -File PSScriptEast.ps1"
    fileUris         = ["https://earmbronsa01.blob.core.windows.net/armtemplates/PSScriptEast.ps1?sv=2021-06-08&ss=bfqt&srt=sco&sp=rlx&se=2024-08-23T22:09:53Z&st=2022-08-23T14:09:53Z&spr=https&sig=HOf3ed%2B1JhkSPHfe%2B0x83t0GrRC5hRCCssOChkSlfiA%3D"]
  })
  type                 = "CustomScriptExtension"
  type_handler_version = "1.4"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-2.id
}
resource "azurerm_virtual_machine_extension" "res-12" {
  auto_upgrade_minor_version = true
  name                       = "enablevmAccess"
  publisher                  = "Microsoft.Compute"
  settings = jsonencode({
    userName = "cmhcadmin"
  })
  type                 = "VMAccessAgent"
  type_handler_version = "2.0"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-2.id
}
resource "azurerm_windows_virtual_machine" "res-13" {
  admin_password                                         = "ignored-as-imported"
  admin_username                                         = "cmhcadmin"
  availability_set_id                                    = azurerm_availability_set.res-1.id
  bypass_platform_safety_checks_on_user_schedule_enabled = true
  license_type                                           = "Windows_Server"
  location                                               = "canadaeast"
  name                                                   = "EPPD1VMWSSSQL01"
  network_interface_ids                                  = [azurerm_network_interface.res-41.id]
  os_managed_disk_id                                     = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/EP-RG-WSS/providers/Microsoft.Compute/disks/EPPD1VMWSSSQL01st1"
  resource_group_name                                    = azurerm_resource_group.res-0.name
  size                                                   = "Standard_F16s_v2"
  tags = {
    Application       = "WSS"
    Category          = "CMHC"
    ExpirationDate    = "09.20.2026"
    MaintenanceWindow = "Window 7"
    Managed           = "True"
    OS                = "Server"
    Operational       = "True"
    Realm             = "Production"
    SNOW-DEP          = "RITM7181805"
  }
  boot_diagnostics {
    storage_account_uri = "https://ediaglogsilvsa01.blob.core.windows.net/"
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
resource "azurerm_virtual_machine_data_disk_attachment" "res-14" {
  caching            = "None"
  lun                = 0
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/EP-RG-WSS/providers/Microsoft.Compute/disks/EPPD1VMWSSSQL01st2"
  virtual_machine_id = azurerm_windows_virtual_machine.res-13.id
}
resource "azurerm_virtual_machine_extension" "res-15" {
  auto_upgrade_minor_version = true
  name                       = "AzureMonitorWindowsAgent"
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.0"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-13.id
}
resource "azurerm_virtual_machine_extension" "res-16" {
  auto_upgrade_minor_version = true
  name                       = "BGInfo"
  publisher                  = "Microsoft.Compute"
  type                       = "bginfo"
  type_handler_version       = "2.1"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-13.id
}
resource "azurerm_virtual_machine_extension" "res-17" {
  auto_upgrade_minor_version = true
  name                       = "DomainJoin"
  publisher                  = "Microsoft.Compute"
  settings = jsonencode({
    Name    = "cmhc-schl.gc.ca"
    OUPath  = "OU=PRD,OU=Azure East,OU=Servers,OU=CMHC_CloudServices,DC=cmhc-schl,DC=gc,DC=ca"
    Options = "3"
    Restart = "true"
    User    = "CMHC-SCHL\\svc_cmhc_vcs_asr"
  })
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-13.id
}
resource "azurerm_virtual_machine_extension" "res-18" {
  auto_upgrade_minor_version = true
  name                       = "MDE.Windows"
  publisher                  = "Microsoft.Azure.AzureDefenderForServers"
  settings = jsonencode({
    autoUpdate        = true
    azureResourceId   = azurerm_windows_virtual_machine.res-13.id
    forceReOnboarding = false
    vNextEnabled      = true
  })
  type                 = "MDE.Windows"
  type_handler_version = "1.0"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-13.id
}
resource "azurerm_virtual_machine_extension" "res-19" {
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
  virtual_machine_id   = azurerm_windows_virtual_machine.res-13.id
}
resource "azurerm_virtual_machine_extension" "res-20" {
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  name                       = "MicrosoftDefenderForSQL"
  publisher                  = "Microsoft.Azure.AzureDefenderForSQL"
  type                       = "AdvancedThreatProtection.Windows"
  type_handler_version       = "2.0"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-13.id
}
resource "azurerm_virtual_machine_extension" "res-21" {
  auto_upgrade_minor_version = true
  name                       = "PSScript"
  publisher                  = "Microsoft.Compute"
  settings = jsonencode({
    commandToExecute = "powershell -ExecutionPolicy Unrestricted -File PSScriptEast.ps1"
    fileUris         = ["https://earmbronsa01.blob.core.windows.net/armtemplates/PSScriptEast.ps1?sv=2021-06-08&ss=bfqt&srt=sco&sp=rlx&se=2024-08-23T22:09:53Z&st=2022-08-23T14:09:53Z&spr=https&sig=HOf3ed%2B1JhkSPHfe%2B0x83t0GrRC5hRCCssOChkSlfiA%3D"]
  })
  type                 = "CustomScriptExtension"
  type_handler_version = "1.4"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-13.id
}
resource "azurerm_virtual_machine_extension" "res-22" {
  auto_upgrade_minor_version = true
  name                       = "enablevmAccess"
  publisher                  = "Microsoft.Compute"
  settings = jsonencode({
    userName = "cmhcadmin"
  })
  type                 = "VMAccessAgent"
  type_handler_version = "2.0"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-13.id
}
resource "azurerm_windows_virtual_machine" "res-23" {
  admin_password                                         = "ignored-as-imported"
  admin_username                                         = "cmhcadmin"
  availability_set_id                                    = azurerm_availability_set.res-1.id
  bypass_platform_safety_checks_on_user_schedule_enabled = true
  license_type                                           = "Windows_Server"
  location                                               = "canadaeast"
  name                                                   = "EPPD1VMWSSSQL02"
  network_interface_ids                                  = [azurerm_network_interface.res-42.id]
  os_managed_disk_id                                     = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/EP-RG-WSS/providers/Microsoft.Compute/disks/EPPD1VMWSSSQL02st1"
  resource_group_name                                    = azurerm_resource_group.res-0.name
  size                                                   = "Standard_F16s_v2"
  tags = {
    Application       = "WSS"
    Category          = "CMHC"
    ExpirationDate    = "09.20.2026"
    MaintenanceWindow = "Window 8"
    Managed           = "True"
    OS                = "Server"
    Operational       = "True"
    Realm             = "Production"
    SNOW-DEP          = "RITM7181805"
  }
  boot_diagnostics {
    storage_account_uri = "https://ediaglogsilvsa01.blob.core.windows.net/"
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
resource "azurerm_virtual_machine_data_disk_attachment" "res-24" {
  caching            = "None"
  lun                = 0
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/EP-RG-WSS/providers/Microsoft.Compute/disks/EPPD1VMWSSSQL02st2"
  virtual_machine_id = azurerm_windows_virtual_machine.res-23.id
}
resource "azurerm_virtual_machine_extension" "res-25" {
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  name                       = "AzureMonitorWindowsAgent"
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.1"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-23.id
}
resource "azurerm_virtual_machine_extension" "res-26" {
  auto_upgrade_minor_version = true
  name                       = "BGInfo"
  publisher                  = "Microsoft.Compute"
  type                       = "bginfo"
  type_handler_version       = "2.1"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-23.id
}
resource "azurerm_virtual_machine_extension" "res-27" {
  auto_upgrade_minor_version = true
  name                       = "DomainJoin"
  publisher                  = "Microsoft.Compute"
  settings = jsonencode({
    Name    = "cmhc-schl.gc.ca"
    OUPath  = "OU=PRD,OU=Azure East,OU=Servers,OU=CMHC_CloudServices,DC=cmhc-schl,DC=gc,DC=ca"
    Options = "3"
    Restart = "true"
    User    = "CMHC-SCHL\\svc_cmhc_vcs_asr"
  })
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-23.id
}
resource "azurerm_virtual_machine_extension" "res-28" {
  auto_upgrade_minor_version = true
  name                       = "MDE.Windows"
  publisher                  = "Microsoft.Azure.AzureDefenderForServers"
  settings = jsonencode({
    autoUpdate        = true
    azureResourceId   = azurerm_windows_virtual_machine.res-23.id
    forceReOnboarding = false
    vNextEnabled      = true
  })
  type                 = "MDE.Windows"
  type_handler_version = "1.0"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-23.id
}
resource "azurerm_virtual_machine_extension" "res-29" {
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
  virtual_machine_id   = azurerm_windows_virtual_machine.res-23.id
}
resource "azurerm_virtual_machine_extension" "res-30" {
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  name                       = "MicrosoftDefenderForSQL"
  publisher                  = "Microsoft.Azure.AzureDefenderForSQL"
  type                       = "AdvancedThreatProtection.Windows"
  type_handler_version       = "2.0"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-23.id
}
resource "azurerm_virtual_machine_extension" "res-31" {
  auto_upgrade_minor_version = true
  name                       = "PSScript"
  publisher                  = "Microsoft.Compute"
  settings = jsonencode({
    commandToExecute = "powershell -ExecutionPolicy Unrestricted -File PSScriptEast.ps1"
    fileUris         = ["https://earmbronsa01.blob.core.windows.net/armtemplates/PSScriptEast.ps1?sv=2021-06-08&ss=bfqt&srt=sco&sp=rlx&se=2024-08-23T22:09:53Z&st=2022-08-23T14:09:53Z&spr=https&sig=HOf3ed%2B1JhkSPHfe%2B0x83t0GrRC5hRCCssOChkSlfiA%3D"]
  })
  type                 = "CustomScriptExtension"
  type_handler_version = "1.4"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-23.id
}
resource "azurerm_virtual_machine_extension" "res-32" {
  auto_upgrade_minor_version = true
  name                       = "enablevmAccess"
  publisher                  = "Microsoft.Compute"
  settings = jsonencode({
    userName = "cmhcadmin"
  })
  type                 = "VMAccessAgent"
  type_handler_version = "2.0"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-23.id
}
resource "azurerm_virtual_machine_extension" "res-33" {
  auto_upgrade_minor_version = true
  name                       = "ChangeTracking-Windows"
  publisher                  = "Microsoft.Azure.ChangeTrackingAndInventory"
  type                       = "ChangeTracking-Windows"
  type_handler_version       = "2.0"
  virtual_machine_id         = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/EP-RG-WSS/providers/Microsoft.Compute/virtualMachines/eppd1vmwssapp01"
  depends_on = [
    azurerm_windows_virtual_machine.res-2,
  ]
}
resource "azurerm_virtual_machine_extension" "res-34" {
  auto_upgrade_minor_version = true
  name                       = "ChangeTracking-Windows"
  publisher                  = "Microsoft.Azure.ChangeTrackingAndInventory"
  type                       = "ChangeTracking-Windows"
  type_handler_version       = "2.0"
  virtual_machine_id         = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/EP-RG-WSS/providers/Microsoft.Compute/virtualMachines/eppd1vmwsssql01"
  depends_on = [
    azurerm_windows_virtual_machine.res-13,
  ]
}
resource "azurerm_virtual_machine_extension" "res-35" {
  auto_upgrade_minor_version = true
  name                       = "ChangeTracking-Windows"
  publisher                  = "Microsoft.Azure.ChangeTrackingAndInventory"
  type                       = "ChangeTracking-Windows"
  type_handler_version       = "2.0"
  virtual_machine_id         = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/EP-RG-WSS/providers/Microsoft.Compute/virtualMachines/eppd1vmwsssql02"
  depends_on = [
    azurerm_windows_virtual_machine.res-23,
  ]
}
resource "azurerm_lb" "res-36" {
  location            = "canadaeast"
  name                = "EP-LBI-WSS-01"
  resource_group_name = azurerm_resource_group.res-0.name
  tags = {
    Application    = "WSS"
    ExpirationDate = "9.20.2026"
    SNOW-DEP       = "RITM7181805"
  }
  frontend_ip_configuration {
    name      = "EP-FEIP-WSS-01"
    subnet_id = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/AzureCore-East/providers/Microsoft.Network/virtualNetworks/eastcmhc-vnet01/subnets/EPRDT-SUBNET02"
  }
}
resource "azurerm_lb_backend_address_pool" "res-37" {
  loadbalancer_id = azurerm_lb.res-36.id
  name            = "EP-LBI-WSS-Pool-01-IP"
}
resource "azurerm_lb_rule" "res-38" {
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.res-37.id]
  backend_port                   = 40002
  disable_outbound_snat          = true
  frontend_ip_configuration_name = "EP-FEIP-WSS-01"
  frontend_port                  = 40002
  loadbalancer_id                = azurerm_lb.res-36.id
  name                           = "SQLAlwaysOnEndPointListener"
  probe_id                       = azurerm_lb_probe.res-39.id
  protocol                       = "Tcp"
}
resource "azurerm_lb_probe" "res-39" {
  interval_in_seconds = 5
  loadbalancer_id     = azurerm_lb.res-36.id
  name                = "SQLAlwaysOnEndPointProbe"
  number_of_probes    = 1
  port                = 59999
}
resource "azurerm_network_interface" "res-40" {
  location            = "canadaeast"
  name                = "EPPD1VMWSSAPP01-Nic01"
  resource_group_name = azurerm_resource_group.res-0.name
  tags = {
    Application       = "WSS"
    ExpirationDate    = "09.20.2026"
    MaintenanceWindow = "Not Applicable"
    Realm             = "Production"
    SNOW-DEP          = "RITM7181805"
  }
  ip_configuration {
    name                          = "EPPD1VMWSSAPP01-NicConfig"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/AzureCore-East/providers/Microsoft.Network/virtualNetworks/eastcmhc-vnet01/subnets/EPRAP-SUBNET01"
  }
}
resource "azurerm_network_interface" "res-41" {
  location            = "canadaeast"
  name                = "EPPD1VMWSSSQL01-Nic01"
  resource_group_name = azurerm_resource_group.res-0.name
  tags = {
    Application       = "WSS"
    ExpirationDate    = "09.20.2026"
    MaintenanceWindow = "Not Applicable"
    Realm             = "Production"
    SNOW-DEP          = "RITM7181805"
  }
  ip_configuration {
    name                          = "EPPD1VMWSSSQL01-NicConfig"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/AzureCore-East/providers/Microsoft.Network/virtualNetworks/eastcmhc-vnet01/subnets/EPRDT-SUBNET02"
  }
}
resource "azurerm_network_interface" "res-42" {
  location            = "canadaeast"
  name                = "EPPD1VMWSSSQL02-Nic01"
  resource_group_name = azurerm_resource_group.res-0.name
  tags = {
    Application       = "WSS"
    ExpirationDate    = "09.20.2026"
    MaintenanceWindow = "Not Applicable"
    Realm             = "Production"
    SNOW-DEP          = "RITM7181805"
  }
  ip_configuration {
    name                          = "EPPD1VMWSSSQL02-NicConfig"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/AzureCore-East/providers/Microsoft.Network/virtualNetworks/eastcmhc-vnet01/subnets/EPRDT-SUBNET02"
  }
}
resource "azurerm_virtual_machine_extension" "res-43" {
  name      = "SiteRecovery-Windows"
  publisher = "Microsoft.Azure.RecoveryServices.SiteRecovery"
  settings = jsonencode({
    commandToExecute = "InstallAndConfigure"
    module           = "a2a"
    publicObject     = null
    taskId           = "6cbe4501-efb2-4f1b-b165-2b1d77d7b57e"
    timeStamp        = "2025-12-19T05:14:30.1102354Z"
  })
  type                 = "Windows"
  type_handler_version = "1.0"
  virtual_machine_id   = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ep-rg-wss/providers/Microsoft.Compute/virtualMachines/EPPD1VMWSSAPP01"
  depends_on = [
    azurerm_windows_virtual_machine.res-2,
  ]
}
resource "azurerm_virtual_machine_extension" "res-44" {
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  name                       = "SqlIaasExtension"
  publisher                  = "Microsoft.SqlServer.Management"
  settings = jsonencode({
    DeploymentTokenSettings = {
      DeploymentToken = 1178938583
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
  virtual_machine_id   = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ep-rg-wss/providers/Microsoft.Compute/virtualMachines/eppd1vmwsssql01"
  depends_on = [
    azurerm_windows_virtual_machine.res-13,
  ]
}
resource "azurerm_virtual_machine_extension" "res-45" {
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  name                       = "SqlIaasExtension"
  publisher                  = "Microsoft.SqlServer.Management"
  settings = jsonencode({
    DeploymentTokenSettings = {
      DeploymentToken = 939376959
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
  virtual_machine_id   = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ep-rg-wss/providers/Microsoft.Compute/virtualMachines/eppd1vmwsssql02"
  depends_on = [
    azurerm_windows_virtual_machine.res-23,
  ]
}
