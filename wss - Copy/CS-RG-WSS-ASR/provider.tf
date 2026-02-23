provider "azurerm" {
  features {
  }
  use_msi                         = false
  use_cli                         = true
  use_oidc                        = false
  resource_provider_registrations = "none"
  subscription_id                 = "5918db9c-25c1-4564-9079-665362a0b0c2"
  environment                     = "public"
}
