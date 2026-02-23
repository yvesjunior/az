resource "azurerm_resource_group" "res-0" {
  location = "canadaeast"
  name     = "ES-RG-WSS"
  tags = {
    Application    = "WSS"
    ExpirationDate = "09.20.2026"
    SNOW-DEP       = "RITM7181805"
  }
}
resource "azurerm_availability_set" "res-1" {
  location                    = "canadaeast"
  name                        = "ESUT1-AVAIL-WSS01"
  platform_fault_domain_count = 2
  resource_group_name         = azurerm_resource_group.res-0.name
  tags = {
    Application       = "WSS"
    ExpirationDate    = "09.20.2026"
    MaintenanceWindow = "Not Applicable"
    Realm             = "Staging"
    SNOW-DEP          = "RITM7181805"
  }
}
resource "azurerm_windows_virtual_machine" "res-2" {
  admin_password                                         = "ignored-as-imported"
  admin_username                                         = "cmhcadmin"
  bypass_platform_safety_checks_on_user_schedule_enabled = true
  license_type                                           = "Windows_Server"
  location                                               = "canadaeast"
  name                                                   = "ESOT1VMWSSAPP01"
  network_interface_ids                                  = [azurerm_network_interface.res-82.id]
  os_managed_disk_id                                     = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ES-RG-WSS/providers/Microsoft.Compute/disks/ESOT1VMWSSAPP01st1"
  resource_group_name                                    = azurerm_resource_group.res-0.name
  size                                                   = "Standard_E4s_v3"
  tags = {
    Application       = "WSS"
    Category          = "CMHC"
    ExpirationDate    = "09.20.2026"
    MaintenanceWindow = "Window 4"
    Managed           = "True"
    OS                = "Server"
    Operational       = "True"
    Realm             = "Staging"
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
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ES-RG-WSS/providers/Microsoft.Compute/disks/ESOT1VMWSSAPP01st2"
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
    OUPath  = "OU=STG,OU=Azure East,OU=Servers,OU=CMHC_CloudServices,DC=cmhc-schl,DC=gc,DC=ca"
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
resource "azurerm_virtual_machine_extension" "res-10" {
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
resource "azurerm_windows_virtual_machine" "res-11" {
  admin_password                                         = "ignored-as-imported"
  admin_username                                         = "cmhcadmin"
  bypass_platform_safety_checks_on_user_schedule_enabled = true
  license_type                                           = "Windows_Server"
  location                                               = "canadaeast"
  name                                                   = "ESUT1VMWSSAPP01"
  network_interface_ids                                  = [azurerm_network_interface.res-83.id]
  os_managed_disk_id                                     = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ES-RG-WSS/providers/Microsoft.Compute/disks/ESUT1VMWSSAPP01st1"
  resource_group_name                                    = azurerm_resource_group.res-0.name
  size                                                   = "Standard_D8s_v3"
  tags = {
    Application       = "WSS"
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
resource "azurerm_virtual_machine_data_disk_attachment" "res-12" {
  caching            = "None"
  lun                = 0
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ES-RG-WSS/providers/Microsoft.Compute/disks/ESUT1VMWSSAPP01st2"
  virtual_machine_id = azurerm_windows_virtual_machine.res-11.id
}
resource "azurerm_virtual_machine_extension" "res-13" {
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  name                       = "AzureMonitorWindowsAgent"
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.1"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-11.id
}
resource "azurerm_virtual_machine_extension" "res-14" {
  auto_upgrade_minor_version = true
  name                       = "AzureNetworkWatcherExtension"
  publisher                  = "Microsoft.Azure.NetworkWatcher"
  settings                   = jsonencode({})
  type                       = "NetworkWatcherAgentWindows"
  type_handler_version       = "1.4"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-11.id
}
resource "azurerm_virtual_machine_extension" "res-15" {
  auto_upgrade_minor_version = true
  name                       = "BGInfo"
  publisher                  = "Microsoft.Compute"
  type                       = "bginfo"
  type_handler_version       = "2.1"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-11.id
}
resource "azurerm_virtual_machine_extension" "res-16" {
  auto_upgrade_minor_version = true
  name                       = "DomainJoin"
  publisher                  = "Microsoft.Compute"
  settings = jsonencode({
    Name    = "cmhc-schl.gc.ca"
    OUPath  = "OU=STG,OU=Azure East,OU=Servers,OU=CMHC_CloudServices,DC=cmhc-schl,DC=gc,DC=ca"
    Options = "3"
    Restart = "true"
    User    = "CMHC-SCHL\\svc_cmhc_vcs_asr"
  })
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-11.id
}
resource "azurerm_virtual_machine_extension" "res-17" {
  auto_upgrade_minor_version = true
  name                       = "MDE.Windows"
  publisher                  = "Microsoft.Azure.AzureDefenderForServers"
  settings = jsonencode({
    autoUpdate        = true
    azureResourceId   = azurerm_windows_virtual_machine.res-11.id
    forceReOnboarding = false
    vNextEnabled      = true
  })
  type                 = "MDE.Windows"
  type_handler_version = "1.0"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-11.id
}
resource "azurerm_virtual_machine_extension" "res-18" {
  auto_upgrade_minor_version = true
  name                       = "Microsoft.Powershell.DSC"
  publisher                  = "Microsoft.Powershell"
  settings = jsonencode({
    configurationArguments = {
      ActionAfterReboot              = "continueConfiguration"
      AllowModuleOverwrite           = false
      ConfigurationMode              = "applyAndMonitor"
      ConfigurationModeFrequencyMins = 15
      NodeConfigurationName          = "Azure_DSC_Med_STG.localhost"
      RebootNodeIfNeeded             = false
      RefreshFrequencyMins           = 30
      RegistrationUrl                = "https://f5fd3c2a-4a79-4fb7-9fbe-7adf9571d713.agentsvc.cc.azure-automation.net/accounts/f5fd3c2a-4a79-4fb7-9fbe-7adf9571d713"
    }
  })
  tags = {
    AutomationAccountARMID = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/Automation-General-CS/providers/Microsoft.Automation/automationAccounts/cs-general-01"
  }
  type                 = "DSC"
  type_handler_version = "2.76"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-11.id
}
resource "azurerm_virtual_machine_extension" "res-19" {
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  name                       = "MicrosoftDefenderForSQL"
  publisher                  = "Microsoft.Azure.AzureDefenderForSQL"
  type                       = "AdvancedThreatProtection.Windows"
  type_handler_version       = "2.0"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-11.id
}
resource "azurerm_virtual_machine_extension" "res-20" {
  auto_upgrade_minor_version = true
  name                       = "enablevmAccess"
  publisher                  = "Microsoft.Compute"
  settings = jsonencode({
    userName = "cmhcadmin"
  })
  type                 = "VMAccessAgent"
  type_handler_version = "2.0"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-11.id
}
resource "azurerm_windows_virtual_machine" "res-21" {
  admin_password                                         = "ignored-as-imported"
  admin_username                                         = "cmhcadmin"
  bypass_platform_safety_checks_on_user_schedule_enabled = true
  license_type                                           = "Windows_Server"
  location                                               = "canadaeast"
  name                                                   = "ESUT1VMWSSAPP02"
  network_interface_ids                                  = [azurerm_network_interface.res-84.id]
  os_managed_disk_id                                     = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ES-RG-WSS/providers/Microsoft.Compute/disks/ESUT1VMWSSAPP02st1"
  resource_group_name                                    = azurerm_resource_group.res-0.name
  size                                                   = "Standard_D8s_v3"
  tags = {
    Application       = "WSS"
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
resource "azurerm_virtual_machine_data_disk_attachment" "res-22" {
  caching            = "None"
  lun                = 0
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ES-RG-WSS/providers/Microsoft.Compute/disks/ESUT1VMWSSAPP02st2"
  virtual_machine_id = azurerm_windows_virtual_machine.res-21.id
}
resource "azurerm_virtual_machine_extension" "res-23" {
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  name                       = "AzureMonitorWindowsAgent"
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.0"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-21.id
}
resource "azurerm_virtual_machine_extension" "res-24" {
  auto_upgrade_minor_version = true
  name                       = "BGInfo"
  publisher                  = "Microsoft.Compute"
  type                       = "bginfo"
  type_handler_version       = "2.1"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-21.id
}
resource "azurerm_virtual_machine_extension" "res-25" {
  auto_upgrade_minor_version = true
  name                       = "DomainJoin"
  publisher                  = "Microsoft.Compute"
  settings = jsonencode({
    Name    = "cmhc-schl.gc.ca"
    OUPath  = "OU=STG,OU=Azure East,OU=Servers,OU=CMHC_CloudServices,DC=cmhc-schl,DC=gc,DC=ca"
    Options = "3"
    Restart = "true"
    User    = "CMHC-SCHL\\svc_cmhc_vcs_asr"
  })
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-21.id
}
resource "azurerm_virtual_machine_extension" "res-26" {
  auto_upgrade_minor_version = true
  name                       = "MDE.Windows"
  publisher                  = "Microsoft.Azure.AzureDefenderForServers"
  settings = jsonencode({
    autoUpdate        = true
    azureResourceId   = azurerm_windows_virtual_machine.res-21.id
    forceReOnboarding = false
    vNextEnabled      = true
  })
  type                 = "MDE.Windows"
  type_handler_version = "1.0"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-21.id
}
resource "azurerm_virtual_machine_extension" "res-27" {
  auto_upgrade_minor_version = true
  name                       = "Microsoft.Powershell.DSC"
  publisher                  = "Microsoft.Powershell"
  settings = jsonencode({
    configurationArguments = {
      ActionAfterReboot              = "continueConfiguration"
      AllowModuleOverwrite           = false
      ConfigurationMode              = "applyAndAutoCorrect"
      ConfigurationModeFrequencyMins = 15
      NodeConfigurationName          = "Azure_DSC_Med_STG.localhost"
      RebootNodeIfNeeded             = false
      RefreshFrequencyMins           = 30
      RegistrationUrl                = "https://f5fd3c2a-4a79-4fb7-9fbe-7adf9571d713.agentsvc.cc.azure-automation.net/accounts/f5fd3c2a-4a79-4fb7-9fbe-7adf9571d713"
    }
  })
  tags = {
    AutomationAccountARMID = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/Automation-General-CS/providers/Microsoft.Automation/automationAccounts/cs-general-01"
  }
  type                 = "DSC"
  type_handler_version = "2.76"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-21.id
}
resource "azurerm_virtual_machine_extension" "res-28" {
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  name                       = "MicrosoftDefenderForSQL"
  publisher                  = "Microsoft.Azure.AzureDefenderForSQL"
  type                       = "AdvancedThreatProtection.Windows"
  type_handler_version       = "2.0"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-21.id
}
resource "azurerm_virtual_machine_extension" "res-29" {
  auto_upgrade_minor_version = true
  name                       = "enablevmAccess"
  publisher                  = "Microsoft.Compute"
  settings = jsonencode({
    userName = "cmhcadmin"
  })
  type                 = "VMAccessAgent"
  type_handler_version = "2.0"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-21.id
}
resource "azurerm_windows_virtual_machine" "res-30" {
  admin_password                                         = "ignored-as-imported"
  admin_username                                         = "cmhcadmin"
  bypass_platform_safety_checks_on_user_schedule_enabled = true
  license_type                                           = "Windows_Server"
  location                                               = "canadaeast"
  name                                                   = "ESUT1VMWSSAPP03"
  network_interface_ids                                  = [azurerm_network_interface.res-85.id]
  os_managed_disk_id                                     = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ES-RG-WSS/providers/Microsoft.Compute/disks/ESUT1VMWSSAPP03st1"
  resource_group_name                                    = azurerm_resource_group.res-0.name
  size                                                   = "Standard_D8s_v3"
  tags = {
    Application       = "WSS"
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
resource "azurerm_virtual_machine_data_disk_attachment" "res-31" {
  caching            = "None"
  lun                = 0
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ES-RG-WSS/providers/Microsoft.Compute/disks/ESUT1VMWSSAPP03st2"
  virtual_machine_id = azurerm_windows_virtual_machine.res-30.id
}
resource "azurerm_virtual_machine_extension" "res-32" {
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  name                       = "AzureMonitorWindowsAgent"
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.0"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-30.id
}
resource "azurerm_virtual_machine_extension" "res-33" {
  auto_upgrade_minor_version = true
  name                       = "BGInfo"
  publisher                  = "Microsoft.Compute"
  type                       = "bginfo"
  type_handler_version       = "2.1"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-30.id
}
resource "azurerm_virtual_machine_extension" "res-34" {
  auto_upgrade_minor_version = true
  name                       = "DomainJoin"
  publisher                  = "Microsoft.Compute"
  settings = jsonencode({
    Name    = "cmhc-schl.gc.ca"
    OUPath  = "OU=STG,OU=Azure East,OU=Servers,OU=CMHC_CloudServices,DC=cmhc-schl,DC=gc,DC=ca"
    Options = "3"
    Restart = "true"
    User    = "CMHC-SCHL\\svc_cmhc_vcs_asr"
  })
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-30.id
}
resource "azurerm_virtual_machine_extension" "res-35" {
  auto_upgrade_minor_version = true
  name                       = "MDE.Windows"
  publisher                  = "Microsoft.Azure.AzureDefenderForServers"
  settings = jsonencode({
    autoUpdate        = true
    azureResourceId   = azurerm_windows_virtual_machine.res-30.id
    forceReOnboarding = false
    vNextEnabled      = true
  })
  type                 = "MDE.Windows"
  type_handler_version = "1.0"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-30.id
}
resource "azurerm_virtual_machine_extension" "res-36" {
  auto_upgrade_minor_version = true
  name                       = "Microsoft.Powershell.DSC"
  publisher                  = "Microsoft.Powershell"
  settings = jsonencode({
    configurationArguments = {
      ActionAfterReboot              = "continueConfiguration"
      AllowModuleOverwrite           = false
      ConfigurationMode              = "applyAndAutoCorrect"
      ConfigurationModeFrequencyMins = 15
      NodeConfigurationName          = "Azure_DSC_Med_STG.localhost"
      RebootNodeIfNeeded             = false
      RefreshFrequencyMins           = 30
      RegistrationUrl                = "https://f5fd3c2a-4a79-4fb7-9fbe-7adf9571d713.agentsvc.cc.azure-automation.net/accounts/f5fd3c2a-4a79-4fb7-9fbe-7adf9571d713"
    }
  })
  tags = {
    AutomationAccountARMID = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/Automation-General-CS/providers/Microsoft.Automation/automationAccounts/cs-general-01"
  }
  type                 = "DSC"
  type_handler_version = "2.76"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-30.id
}
resource "azurerm_virtual_machine_extension" "res-37" {
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  name                       = "MicrosoftDefenderForSQL"
  publisher                  = "Microsoft.Azure.AzureDefenderForSQL"
  type                       = "AdvancedThreatProtection.Windows"
  type_handler_version       = "2.0"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-30.id
}
resource "azurerm_virtual_machine_extension" "res-38" {
  auto_upgrade_minor_version = true
  name                       = "enablevmAccess"
  publisher                  = "Microsoft.Compute"
  settings = jsonencode({
    userName = "cmhcadmin"
  })
  type                 = "VMAccessAgent"
  type_handler_version = "2.0"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-30.id
}
resource "azurerm_windows_virtual_machine" "res-39" {
  admin_password                                         = "ignored-as-imported"
  admin_username                                         = "cmhcadmin"
  availability_set_id                                    = azurerm_availability_set.res-1.id
  bypass_platform_safety_checks_on_user_schedule_enabled = true
  license_type                                           = "Windows_Server"
  location                                               = "canadaeast"
  name                                                   = "ESUT1VMWSSSQL01"
  network_interface_ids                                  = [azurerm_network_interface.res-86.id]
  os_managed_disk_id                                     = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ES-RG-WSS/providers/Microsoft.Compute/disks/ESUT1VMWSSSQL01st1"
  resource_group_name                                    = azurerm_resource_group.res-0.name
  size                                                   = "Standard_E4s_v3"
  tags = {
    Application       = "WSS"
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
resource "azurerm_virtual_machine_data_disk_attachment" "res-40" {
  caching            = "ReadWrite"
  lun                = 0
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ES-RG-WSS/providers/Microsoft.Compute/disks/ESUT1VMWSSSQL01-disk01"
  virtual_machine_id = azurerm_windows_virtual_machine.res-39.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-41" {
  caching            = "ReadWrite"
  lun                = 1
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ES-RG-WSS/providers/Microsoft.Compute/disks/ESUT1VMWSSSQL01-disk02"
  virtual_machine_id = azurerm_windows_virtual_machine.res-39.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-42" {
  caching            = "ReadWrite"
  lun                = 2
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ES-RG-WSS/providers/Microsoft.Compute/disks/ESUT1VMWSSSQL01-disk03"
  virtual_machine_id = azurerm_windows_virtual_machine.res-39.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-43" {
  caching            = "ReadWrite"
  lun                = 3
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ES-RG-WSS/providers/Microsoft.Compute/disks/ESUT1VMWSSSQL01-disk04"
  virtual_machine_id = azurerm_windows_virtual_machine.res-39.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-44" {
  caching            = "ReadWrite"
  lun                = 4
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ES-RG-WSS/providers/Microsoft.Compute/disks/ESUT1VMWSSSQL01-disk05"
  virtual_machine_id = azurerm_windows_virtual_machine.res-39.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-45" {
  caching            = "ReadWrite"
  lun                = 5
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ES-RG-WSS/providers/Microsoft.Compute/disks/ESUT1VMWSSSQL01-disk06"
  virtual_machine_id = azurerm_windows_virtual_machine.res-39.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-46" {
  caching            = "ReadWrite"
  lun                = 6
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ES-RG-WSS/providers/Microsoft.Compute/disks/ESUT1VMWSSSQL01-disk07"
  virtual_machine_id = azurerm_windows_virtual_machine.res-39.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-47" {
  caching            = "ReadWrite"
  lun                = 7
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ES-RG-WSS/providers/Microsoft.Compute/disks/ESUT1VMWSSSQL01-disk08"
  virtual_machine_id = azurerm_windows_virtual_machine.res-39.id
}
resource "azurerm_virtual_machine_extension" "res-48" {
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  name                       = "AzureMonitorWindowsAgent"
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.0"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-39.id
}
resource "azurerm_virtual_machine_extension" "res-49" {
  auto_upgrade_minor_version = true
  name                       = "BGInfo"
  publisher                  = "Microsoft.Compute"
  type                       = "bginfo"
  type_handler_version       = "2.1"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-39.id
}
resource "azurerm_virtual_machine_extension" "res-50" {
  auto_upgrade_minor_version = true
  name                       = "DomainJoin"
  publisher                  = "Microsoft.Compute"
  settings = jsonencode({
    Name    = "cmhc-schl.gc.ca"
    OUPath  = "OU=STG,OU=Azure East,OU=Servers,OU=CMHC_CloudServices,DC=cmhc-schl,DC=gc,DC=ca"
    Options = "3"
    Restart = "true"
    User    = "CMHC-SCHL\\svc_cmhc_vcs_asr"
  })
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-39.id
}
resource "azurerm_virtual_machine_extension" "res-51" {
  auto_upgrade_minor_version = true
  name                       = "MDE.Windows"
  publisher                  = "Microsoft.Azure.AzureDefenderForServers"
  settings = jsonencode({
    autoUpdate        = true
    azureResourceId   = azurerm_windows_virtual_machine.res-39.id
    forceReOnboarding = false
    vNextEnabled      = true
  })
  type                 = "MDE.Windows"
  type_handler_version = "1.0"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-39.id
}
resource "azurerm_virtual_machine_extension" "res-52" {
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
  virtual_machine_id   = azurerm_windows_virtual_machine.res-39.id
}
resource "azurerm_virtual_machine_extension" "res-53" {
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  name                       = "MicrosoftDefenderForSQL"
  publisher                  = "Microsoft.Azure.AzureDefenderForSQL"
  type                       = "AdvancedThreatProtection.Windows"
  type_handler_version       = "2.0"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-39.id
}
resource "azurerm_windows_virtual_machine" "res-54" {
  admin_password                                         = "ignored-as-imported"
  admin_username                                         = "cmhcadmin"
  availability_set_id                                    = azurerm_availability_set.res-1.id
  bypass_platform_safety_checks_on_user_schedule_enabled = true
  license_type                                           = "Windows_Server"
  location                                               = "canadaeast"
  name                                                   = "ESUT1VMWSSSQL02"
  network_interface_ids                                  = [azurerm_network_interface.res-87.id]
  os_managed_disk_id                                     = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ES-RG-WSS/providers/Microsoft.Compute/disks/ESUT1VMWSSSQL02st1"
  resource_group_name                                    = azurerm_resource_group.res-0.name
  size                                                   = "Standard_E4s_v3"
  tags = {
    Application       = "WSS"
    Category          = "CMHC"
    ExpirationDate    = "09.20.2026"
    MaintenanceWindow = "Window 4"
    Managed           = "True"
    OS                = "Server"
    Operational       = "True"
    Realm             = "Staging"
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
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    offer     = "WindowsServer"
    publisher = "MicrosoftWindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-55" {
  caching            = "ReadWrite"
  lun                = 0
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ES-RG-WSS/providers/Microsoft.Compute/disks/ESUT1VMWSSSQL02-disk01"
  virtual_machine_id = azurerm_windows_virtual_machine.res-54.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-56" {
  caching            = "ReadWrite"
  lun                = 1
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ES-RG-WSS/providers/Microsoft.Compute/disks/ESUT1VMWSSSQL02-disk02"
  virtual_machine_id = azurerm_windows_virtual_machine.res-54.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-57" {
  caching            = "ReadWrite"
  lun                = 2
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ES-RG-WSS/providers/Microsoft.Compute/disks/ESUT1VMWSSSQL02-disk03"
  virtual_machine_id = azurerm_windows_virtual_machine.res-54.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-58" {
  caching            = "ReadWrite"
  lun                = 3
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ES-RG-WSS/providers/Microsoft.Compute/disks/ESUT1VMWSSSQL02-disk04"
  virtual_machine_id = azurerm_windows_virtual_machine.res-54.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-59" {
  caching            = "ReadWrite"
  lun                = 4
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ES-RG-WSS/providers/Microsoft.Compute/disks/ESUT1VMWSSSQL02-disk05"
  virtual_machine_id = azurerm_windows_virtual_machine.res-54.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-60" {
  caching            = "ReadWrite"
  lun                = 5
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ES-RG-WSS/providers/Microsoft.Compute/disks/ESUT1VMWSSSQL02-disk06"
  virtual_machine_id = azurerm_windows_virtual_machine.res-54.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-61" {
  caching            = "ReadWrite"
  lun                = 6
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ES-RG-WSS/providers/Microsoft.Compute/disks/ESUT1VMWSSSQL02-disk07"
  virtual_machine_id = azurerm_windows_virtual_machine.res-54.id
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-62" {
  caching            = "ReadWrite"
  lun                = 7
  managed_disk_id    = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ES-RG-WSS/providers/Microsoft.Compute/disks/ESUT1VMWSSSQL02-disk08"
  virtual_machine_id = azurerm_windows_virtual_machine.res-54.id
}
resource "azurerm_virtual_machine_extension" "res-63" {
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  name                       = "AzureMonitorWindowsAgent"
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.0"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-54.id
}
resource "azurerm_virtual_machine_extension" "res-64" {
  auto_upgrade_minor_version = true
  name                       = "BGInfo"
  publisher                  = "Microsoft.Compute"
  type                       = "bginfo"
  type_handler_version       = "2.1"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-54.id
}
resource "azurerm_virtual_machine_extension" "res-65" {
  auto_upgrade_minor_version = true
  name                       = "DomainJoin"
  publisher                  = "Microsoft.Compute"
  settings = jsonencode({
    Name    = "cmhc-schl.gc.ca"
    OUPath  = "OU=STG,OU=Azure East,OU=Servers,OU=CMHC_CloudServices,DC=cmhc-schl,DC=gc,DC=ca"
    Options = "3"
    Restart = "true"
    User    = "CMHC-SCHL\\svc_cmhc_vcs_asr"
  })
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-54.id
}
resource "azurerm_virtual_machine_extension" "res-66" {
  auto_upgrade_minor_version = true
  name                       = "MDE.Windows"
  publisher                  = "Microsoft.Azure.AzureDefenderForServers"
  settings = jsonencode({
    autoUpdate        = true
    azureResourceId   = azurerm_windows_virtual_machine.res-54.id
    forceReOnboarding = false
    vNextEnabled      = true
  })
  type                 = "MDE.Windows"
  type_handler_version = "1.0"
  virtual_machine_id   = azurerm_windows_virtual_machine.res-54.id
}
resource "azurerm_virtual_machine_extension" "res-67" {
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
  virtual_machine_id   = azurerm_windows_virtual_machine.res-54.id
}
resource "azurerm_virtual_machine_extension" "res-68" {
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  name                       = "MicrosoftDefenderForSQL"
  publisher                  = "Microsoft.Azure.AzureDefenderForSQL"
  type                       = "AdvancedThreatProtection.Windows"
  type_handler_version       = "2.0"
  virtual_machine_id         = azurerm_windows_virtual_machine.res-54.id
}
resource "azurerm_virtual_machine_extension" "res-69" {
  auto_upgrade_minor_version = true
  name                       = "ChangeTracking-Windows"
  publisher                  = "Microsoft.Azure.ChangeTrackingAndInventory"
  type                       = "ChangeTracking-Windows"
  type_handler_version       = "2.0"
  virtual_machine_id         = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ES-RG-WSS/providers/Microsoft.Compute/virtualMachines/esot1vmwssapp01"
  depends_on = [
    azurerm_windows_virtual_machine.res-2,
  ]
}
resource "azurerm_virtual_machine_extension" "res-70" {
  auto_upgrade_minor_version = true
  name                       = "ChangeTracking-Windows"
  publisher                  = "Microsoft.Azure.ChangeTrackingAndInventory"
  type                       = "ChangeTracking-Windows"
  type_handler_version       = "2.0"
  virtual_machine_id         = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ES-RG-WSS/providers/Microsoft.Compute/virtualMachines/esut1vmwssapp01"
  depends_on = [
    azurerm_windows_virtual_machine.res-11,
  ]
}
resource "azurerm_virtual_machine_extension" "res-71" {
  auto_upgrade_minor_version = true
  name                       = "ChangeTracking-Windows"
  publisher                  = "Microsoft.Azure.ChangeTrackingAndInventory"
  type                       = "ChangeTracking-Windows"
  type_handler_version       = "2.0"
  virtual_machine_id         = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ES-RG-WSS/providers/Microsoft.Compute/virtualMachines/esut1vmwssapp02"
  depends_on = [
    azurerm_windows_virtual_machine.res-21,
  ]
}
resource "azurerm_virtual_machine_extension" "res-72" {
  auto_upgrade_minor_version = true
  name                       = "ChangeTracking-Windows"
  publisher                  = "Microsoft.Azure.ChangeTrackingAndInventory"
  type                       = "ChangeTracking-Windows"
  type_handler_version       = "2.0"
  virtual_machine_id         = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ES-RG-WSS/providers/Microsoft.Compute/virtualMachines/esut1vmwssapp03"
  depends_on = [
    azurerm_windows_virtual_machine.res-30,
  ]
}
resource "azurerm_virtual_machine_extension" "res-73" {
  auto_upgrade_minor_version = true
  name                       = "ChangeTracking-Windows"
  publisher                  = "Microsoft.Azure.ChangeTrackingAndInventory"
  type                       = "ChangeTracking-Windows"
  type_handler_version       = "2.0"
  virtual_machine_id         = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ES-RG-WSS/providers/Microsoft.Compute/virtualMachines/esut1vmwsssql01"
  depends_on = [
    azurerm_windows_virtual_machine.res-39,
  ]
}
resource "azurerm_virtual_machine_extension" "res-74" {
  auto_upgrade_minor_version = true
  name                       = "ChangeTracking-Windows"
  publisher                  = "Microsoft.Azure.ChangeTrackingAndInventory"
  type                       = "ChangeTracking-Windows"
  type_handler_version       = "2.0"
  virtual_machine_id         = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/ES-RG-WSS/providers/Microsoft.Compute/virtualMachines/esut1vmwsssql02"
  depends_on = [
    azurerm_windows_virtual_machine.res-54,
  ]
}
resource "azurerm_lb" "res-75" {
  location            = "canadaeast"
  name                = "ES-LBI-WSS-01"
  resource_group_name = azurerm_resource_group.res-0.name
  tags = {
    Application    = "WSS"
    ExpirationDate = "09.20.2026"
    SNOW-DEP       = "RITM7181805"
  }
  frontend_ip_configuration {
    name      = "ES-FEIP-WSS-01"
    subnet_id = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/AzureCore-East/providers/Microsoft.Network/virtualNetworks/eastcmhc-vnet01/subnets/ESRDT-SUBNET02"
  }
  frontend_ip_configuration {
    name      = "ES-LBI-WSS-02"
    subnet_id = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/AzureCore-East/providers/Microsoft.Network/virtualNetworks/eastcmhc-vnet01/subnets/ESRDT-SUBNET02"
  }
}
resource "azurerm_lb_backend_address_pool" "res-76" {
  loadbalancer_id = azurerm_lb.res-75.id
  name            = "ES-LBI-WSS-Pool-01-IP"
}
resource "azurerm_lb_backend_address_pool" "res-77" {
  loadbalancer_id = azurerm_lb.res-75.id
  name            = "ES-LBI-WSS-Pool-02-IP"
}
resource "azurerm_lb_rule" "res-78" {
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.res-76.id]
  backend_port                   = 40002
  disable_outbound_snat          = true
  frontend_ip_configuration_name = "ES-FEIP-WSS-01"
  frontend_port                  = 40002
  loadbalancer_id                = azurerm_lb.res-75.id
  name                           = "SQLAlwaysOnEndPointListener"
  probe_id                       = azurerm_lb_probe.res-81.id
  protocol                       = "Tcp"
}
resource "azurerm_lb_rule" "res-79" {
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.res-77.id]
  backend_port                   = 40003
  disable_outbound_snat          = true
  frontend_ip_configuration_name = "ES-LBI-WSS-02"
  frontend_port                  = 40003
  loadbalancer_id                = azurerm_lb.res-75.id
  name                           = "SQLAlwaysOnEndPointListener_WSS_EIT"
  probe_id                       = azurerm_lb_probe.res-80.id
  protocol                       = "Tcp"
}
resource "azurerm_lb_probe" "res-80" {
  interval_in_seconds = 5
  loadbalancer_id     = azurerm_lb.res-75.id
  name                = "SQLAlwaysOnEndPointProbe_WSS_EIT"
  number_of_probes    = 1
  port                = 59998
}
resource "azurerm_lb_probe" "res-81" {
  interval_in_seconds = 5
  loadbalancer_id     = azurerm_lb.res-75.id
  name                = "SQLAlwaysOnEndPointprobe"
  number_of_probes    = 1
  port                = 59999
}
resource "azurerm_network_interface" "res-82" {
  location            = "canadaeast"
  name                = "ESOT1VMWSSAPP01-Nic01"
  resource_group_name = azurerm_resource_group.res-0.name
  tags = {
    Application       = "WSS"
    ExpirationDate    = "09.20.2026"
    MaintenanceWindow = "Not Applicable"
    Realm             = "Staging"
    SNOW-DEP          = "RITM7181805"
  }
  ip_configuration {
    name                          = "ESOT1VMWSSAPP01-NicConfig"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/AzureCore-East/providers/Microsoft.Network/virtualNetworks/eastcmhc-vnet01/subnets/ESRAP-SUBNET01"
  }
}
resource "azurerm_network_interface" "res-83" {
  location            = "canadaeast"
  name                = "ESUT1VMWSSAPP01-Nic01"
  resource_group_name = azurerm_resource_group.res-0.name
  tags = {
    Application       = "WSS"
    ExpirationDate    = "09.20.2026"
    MaintenanceWindow = "Not Applicable"
    Realm             = "Staging"
    SNOW-DEP          = "RITM7181805"
  }
  ip_configuration {
    name                          = "ESUT1VMWSSAPP01-NicConfig"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/AzureCore-East/providers/Microsoft.Network/virtualNetworks/eastcmhc-vnet01/subnets/ESRAP-SUBNET01"
  }
}
resource "azurerm_network_interface" "res-84" {
  location            = "canadaeast"
  name                = "ESUT1VMWSSAPP02-Nic01"
  resource_group_name = azurerm_resource_group.res-0.name
  tags = {
    Application       = "WSS"
    ExpirationDate    = "09.20.2026"
    MaintenanceWindow = "Not Applicable"
    Realm             = "Staging"
    SNOW-DEP          = "RITM7181805"
  }
  ip_configuration {
    name                          = "ESUT1VMWSSAPP02-NicConfig"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/AzureCore-East/providers/Microsoft.Network/virtualNetworks/eastcmhc-vnet01/subnets/ESRAP-SUBNET01"
  }
}
resource "azurerm_network_interface" "res-85" {
  location            = "canadaeast"
  name                = "ESUT1VMWSSAPP03-Nic01"
  resource_group_name = azurerm_resource_group.res-0.name
  tags = {
    Application       = "WSS"
    ExpirationDate    = "09.20.2026"
    MaintenanceWindow = "Not Applicable"
    Realm             = "Staging"
    SNOW-DEP          = "RITM7181805"
  }
  ip_configuration {
    name                          = "ESUT1VMWSSAPP03-NicConfig"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/AzureCore-East/providers/Microsoft.Network/virtualNetworks/eastcmhc-vnet01/subnets/ESRAP-SUBNET01"
  }
}
resource "azurerm_network_interface" "res-86" {
  location            = "canadaeast"
  name                = "ESUT1VMWSSSQL01-Nic01"
  resource_group_name = azurerm_resource_group.res-0.name
  tags = {
    Application       = "WSS"
    ExpirationDate    = "09.20.2026"
    MaintenanceWindow = "Not Applicable"
    Realm             = "Staging"
    SNOW-DEP          = "RITM7181805"
  }
  ip_configuration {
    name                          = "ESUT1VMWSSSQL01-NicConfig"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/AzureCore-East/providers/Microsoft.Network/virtualNetworks/eastcmhc-vnet01/subnets/ESRDT-SUBNET02"
  }
}
resource "azurerm_network_interface" "res-87" {
  location            = "canadaeast"
  name                = "ESUT1VMWSSSQL02-Nic01"
  resource_group_name = azurerm_resource_group.res-0.name
  tags = {
    Application       = "WSS"
    ExpirationDate    = "09.20.2026"
    MaintenanceWindow = "Not Applicable"
    Realm             = "Staging"
    SNOW-DEP          = "RITM7181805"
  }
  ip_configuration {
    name                          = "ESUT1VMWSSSQL02-NicConfig"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/AzureCore-East/providers/Microsoft.Network/virtualNetworks/eastcmhc-vnet01/subnets/ESRDT-SUBNET02"
  }
}
resource "azurerm_virtual_machine_extension" "res-88" {
  name      = "SiteRecovery-Windows"
  publisher = "Microsoft.Azure.RecoveryServices.SiteRecovery"
  settings = jsonencode({
    commandToExecute = "InstallAndConfigure"
    module           = "a2a"
    publicObject     = null
    taskId           = "323603d8-19cd-486c-9545-0b122e5ac281"
    timeStamp        = "2025-12-19T05:14:18.2215444Z"
  })
  type                 = "Windows"
  type_handler_version = "1.0"
  virtual_machine_id   = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/es-rg-wss/providers/Microsoft.Compute/virtualMachines/ESUT1VMWSSAPP01"
  depends_on = [
    azurerm_windows_virtual_machine.res-11,
  ]
}
resource "azurerm_virtual_machine_extension" "res-89" {
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  name                       = "SqlIaasExtension"
  publisher                  = "Microsoft.SqlServer.Management"
  settings = jsonencode({
    DeploymentTokenSettings = {
      DeploymentToken = 1771804363
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
  virtual_machine_id   = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/es-rg-wss/providers/Microsoft.Compute/virtualMachines/esut1vmwsssql01"
  depends_on = [
    azurerm_windows_virtual_machine.res-39,
  ]
}
resource "azurerm_virtual_machine_extension" "res-90" {
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  name                       = "SqlIaasExtension"
  publisher                  = "Microsoft.SqlServer.Management"
  settings = jsonencode({
    DeploymentTokenSettings = {
      DeploymentToken = 1591615798
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
  virtual_machine_id   = "/subscriptions/5918db9c-25c1-4564-9079-665362a0b0c2/resourceGroups/es-rg-wss/providers/Microsoft.Compute/virtualMachines/esut1vmwsssql02"
  depends_on = [
    azurerm_windows_virtual_machine.res-54,
  ]
}
