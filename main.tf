data "azurerm_client_config" "current" {}

locals {
  region_name = var.azure_regions_map[var.region_code]
  rg_name     = "rsg-${var.environment}-${var.region_code}-${var.app_ref}"
  app_prefix  = "${var.environment}-${var.region_code}-${var.app_ref}"

   # 👇 new local: resolve AI Foundry region (falls back to main region if not overridden)
  ai_foundry_region = var.ai_foundry_region_code != "" ? var.azure_regions_map[var.ai_foundry_region_code] : local.region_name
}

# --------------------------------------------------------------------
# Resource Group
# --------------------------------------------------------------------
resource "azurerm_resource_group" "rsg" {
  name     = local.rg_name
  location = local.region_name
}
# --------------------------------------------------------------------
# Storage Settings (Main Data Lake)
# --------------------------------------------------------------------

resource "azurerm_storage_account" "storage_hns" {
  count = var.storage_hns_settings.enable_storage_account ? 1 : 0

  name                = lower(substr("st${replace(local.app_prefix, "-", "")}${var.storage_hns_settings.suffix}", 0, 24))
  resource_group_name = azurerm_resource_group.rsg.name
  location            = local.region_name

  account_tier             = var.storage_hns_settings.account_tier
  account_kind             = var.storage_hns_settings.account_kind
  account_replication_type = var.storage_hns_settings.account_replication_type
  access_tier              = var.storage_hns_settings.access_tier
  is_hns_enabled           = var.storage_hns_settings.is_hns_enabled
  public_network_access_enabled = true   # ← MUST be true for creation

  timeouts {
    create = "60m"
  }

  tags = {
    environment = var.environment
    app_ref     = var.app_ref
    used_by     = "Data Platform"
  }
}

# Apply firewall rules after storage account is created so the deployment will be faster

resource "azurerm_storage_account_network_rules" "storage_hns_rules" {
  count = var.storage_hns_settings.enable_storage_account ? 1 : 0

  storage_account_id = azurerm_storage_account.storage_hns[0].id

  default_action             = var.storage_hns_settings.firewall_default_action
  bypass                     = var.storage_hns_settings.firewall_rules_bypass
  ip_rules                   = var.storage_hns_settings.firewall_ip_rules
  virtual_network_subnet_ids = []

  depends_on = [
    azurerm_storage_account.storage_hns
  ]
}



#############################################
# AI Storage Settings (Non-HNS Storage)
#############################################


resource "azurerm_storage_account" "storage_blob" {
  count = var.storage_blob_settings.enable_storage_account ? 1 : 0

  name                = lower(substr("st${replace(local.app_prefix, "-", "")}${var.storage_blob_settings.suffix}", 0, 24))
  resource_group_name = azurerm_resource_group.rsg.name
  location            = local.region_name

  account_tier             = var.storage_blob_settings.account_tier
  account_kind             = var.storage_blob_settings.account_kind
  account_replication_type = var.storage_blob_settings.account_replication_type
  access_tier              = var.storage_blob_settings.access_tier
  is_hns_enabled           = var.storage_blob_settings.is_hns_enabled
  public_network_access_enabled = true   # ← MUST be true

  timeouts {
    create = "60m"
  }


  tags = {
    environment = var.environment
    app_ref     = var.app_ref
    used_by     = "AI Foundry"
  }
}

# Apply firewall rules after storage account is created so the deployment will be faster

resource "azurerm_storage_account_network_rules" "storage_blob_rules" {
  count = var.storage_blob_settings.enable_storage_account ? 1 : 0

  storage_account_id = azurerm_storage_account.storage_blob[0].id

  default_action             = var.storage_blob_settings.firewall_default_action
  bypass                     = var.storage_blob_settings.firewall_rules_bypass
  ip_rules                   = var.storage_blob_settings.firewall_ip_rules
  virtual_network_subnet_ids = []

  depends_on = [
    azurerm_storage_account.storage_blob
  ]
}


# --------------------------------------------------------------------
# Key Vault
# --------------------------------------------------------------------


resource "azurerm_key_vault" "kv" {
  name                = "kv-${var.environment}-${var.region_code}-${var.app_ref}"
  location            = local.region_name
  resource_group_name = azurerm_resource_group.rsg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = var.keyvault_settings.sku_name
  soft_delete_retention_days = var.keyvault_settings.soft_delete_retention_days 

  network_acls {
  default_action = var.keyvault_settings.firewall_default_action
  bypass         = join(",", var.keyvault_settings.firewall_rules_bypass)
  ip_rules       = var.keyvault_settings.firewall_ip_rules
}

  tags = var.resource_tags
}


# --------------------------------------------------------------------
# Databricks Workspace
# --------------------------------------------------------------------
resource "azurerm_databricks_workspace" "dbw" {
  count               = var.databricks_settings.enable_databricks ? 1 : 0
  name                = "dbw-${var.environment}-${var.region_code}-${var.app_ref}"
  resource_group_name = azurerm_resource_group.rsg.name
  location            = azurerm_resource_group.rsg.location
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
  resource_group_name = azurerm_resource_group.rsg.name
  location            = local.region_name

  offer_type = var.cosmos_settings.offer_type
  kind       = var.cosmos_settings.account_kind

  consistency_policy {
    consistency_level = var.cosmos_settings.consistency_level
  }

  ip_range_filter = var.cosmos_settings.firewall_ip_rules



  geo_location {
    location          = local.region_name
    failover_priority = 0
  }

  tags = var.resource_tags
}


# --------------------------------------------------------------------
# Azure AI Search
# --------------------------------------------------------------------
resource "azurerm_search_service" "ai_search" {
  count = var.ai_search_settings.enable_ai_search ? 1 : 0

  name                = "srch-${var.environment}-${var.region_code}-${var.app_ref}"
  resource_group_name = azurerm_resource_group.rsg.name
  location            = local.region_name

  sku           = var.ai_search_settings.sku
  replica_count = var.ai_search_settings.replica_count
  partition_count = var.ai_search_settings.partition_count

  tags = var.resource_tags
}


# --------------------------------------------------------------------
# Azure AI Foundry 
# --------------------------------------------------------------------
resource "azurerm_ai_foundry" "ai_foundry" {
  count               = var.ai_foundry_settings.enable_ai_foundry ? 1 : 0
  name                = "aifoundry-${var.environment}-${var.region_code}-${var.app_ref}"
  resource_group_name = azurerm_resource_group.rsg.name
  location            = local.ai_foundry_region
  key_vault_id        = azurerm_key_vault.kv.id
  storage_account_id  = azurerm_storage_account.storage_blob[0].id   

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = var.environment
    app_ref     = var.app_ref
  }
}

# --------------------------------------------------------------------
# Azure AI Foundry Project
# --------------------------------------------------------------------
resource "azurerm_ai_foundry_project" "aif_workspace" {
  name               = "aiftestproject-${var.environment}-${var.region_code}-${var.app_ref}"
  location           = local.ai_foundry_region
  ai_services_hub_id = azurerm_ai_foundry.ai_foundry.id
}

