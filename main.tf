data "azurerm_client_config" "current" {}

locals {
  region_name = var.azure_region_map[var.region_code]
  rg_name     = "rsg-${var.environment}-${var.region_code}-${var.app_ref}"
  app_prefix  = "${var.environment}-${var.region_code}-${var.app_ref}"

   # 👇 new local: resolve AI Foundry region (falls back to main region if not overridden)
  ai_foundry_region = var.ai_foundry_region_code != "" ? var.azure_region_map[var.ai_foundry_region_code] : local.region_name
}

# --------------------------------------------------------------------
# Resource Group
# --------------------------------------------------------------------
resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = local.region_name
}
# --------------------------------------------------------------------
# Storage Account
# --------------------------------------------------------------------

resource "azurerm_storage_account" "storage" {
  count                    = var.storage_settings.enable_storage_account ? 1 : 0
  name                     = lower(substr("st${var.environment}${var.region_code}${var.app_ref}${var.storage_settings.suffix}", 0, 24))
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = var.storage_settings.account_tier
  account_kind             = var.storage_settings.account_kind
  account_replication_type = var.storage_settings.account_replication_type
  is_hns_enabled           = var.storage_settings.is_hns_enabled
  access_tier              = var.storage_settings.access_tier

  # ✅ correct for AzureRM v4.x
  # public_network_access_enabled = var.storage_settings.public_network_access_enabled

  #network_rules {
  #  default_action = var.storage_settings.public_network_access_enabled ? "Allow" : "Deny"
  #}

  tags = {
    environment = var.environment
    app_ref     = var.app_ref
  }
}

# --------------------------------------------------------------------
# Key Vault
# --------------------------------------------------------------------


resource "azurerm_key_vault" "kv" {
  name                        = "kv-${var.environment}-${var.region_code}-${var.app_ref}"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  network_acls {
    default_action             = "Allow"
    bypass                     = "AzureServices"
  }
}


# --------------------------------------------------------------------
# Databricks Workspace
# --------------------------------------------------------------------
resource "azurerm_databricks_workspace" "dbw" {
  count               = var.databricks_settings.enable_databricks ? 1 : 0
  name                = "dbw-${var.environment}-${var.region_code}-${var.app_ref}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = var.databricks_settings.workspace_tier

  custom_parameters {
    no_public_ip = var.databricks_settings.public_network_access_enabled ? false : true
  }

  tags = {
    environment = var.environment
    app_ref     = var.app_ref
  }
}

# --------------------------------------------------------------------
# Cosmos DB
# --------------------------------------------------------------------
resource "azurerm_cosmosdb_account" "cosmos" {
  count               = var.cosmos_settings.enable_cosmos ? 1 : 0
  name                = "cosmos-${var.environment}-${var.region_code}-${var.app_ref}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  offer_type          = var.cosmos_settings.offer_type
  kind                = var.cosmos_settings.account_kind

  consistency_policy {
    consistency_level = var.cosmos_settings.consistency_level
  }

  # ✅ Newer schema uses "analytical_storage" block (3.80+)
  dynamic "analytical_storage" {
    for_each = var.cosmos_settings.enable_analytical_storage ? [1] : []
    content {
      schema_type = "WellDefined"
    }
  }

  geo_location {
    location          = azurerm_resource_group.rg.location
    failover_priority = 0
  }
}

# --------------------------------------------------------------------
# Azure AI Search
# --------------------------------------------------------------------
resource "azurerm_search_service" "ai_search" {
  count               = var.ai_search_settings.enable_ai_search ? 1 : 0
  name                = "srch-${var.environment}-${var.region_code}-${var.app_ref}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = var.ai_search_settings.sku
  replica_count       = var.ai_search_settings.replica_count
  partition_count     = var.ai_search_settings.partition_count
}

# --------------------------------------------------------------------
# Azure AI Foundry (Cognitive Services)
# --------------------------------------------------------------------
resource "azurerm_ai_foundry" "ai_foundry" {
  count               = var.ai_foundry_settings.enable_ai_foundry ? 1 : 0
  name                = "aifoundry-${var.environment}-${var.region_code}-${var.app_ref}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = local.ai_foundry_region

  # You can leave these commented until AI Foundry supports SKU via provider
  # sku_name            = var.ai_foundry_settings.sku_name
  # kind                = "CognitiveServices"

  #custom_subdomain_name = "aif-${var.environment}-${var.region_code}-${var.app_ref}"

  # 👇 Link to existing resources
  key_vault_id       = azurerm_key_vault.kv.id
  storage_account_id = azurerm_storage_account.storage[0].id

  tags = {
    environment = var.environment
    app_ref     = var.app_ref
  }

  identity {
    type = "SystemAssigned"
  }
}



