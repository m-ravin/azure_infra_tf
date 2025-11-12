###############################
# Global / Core Configuration #
###############################

variable "environment" {
  description = "Deployment environment (e.g., dev, qa, prod)"
  type        = string
}

variable "app_ref" {
  description = "Short application reference (used in resource naming)"
  type        = string
}

variable "region_code" {
  description = "Logical region code (e.g., az1, az2, az3)"
  type        = string
}

variable "ai_foundry_region_code" {
  description = "Logical region code for Azure Foundry (e.g., az1, az2, az3)"
  type        = string
}

variable "azure_region_map" {
  description = "Mapping between logical region codes and Azure region names"
  type = map(string)
  default = {
    az1 = "Central India"
    az2 = "South India"
    az3 = "East US"
  }
}

######################
# Databricks Config  #
######################

variable "databricks_settings" {
  description = "Settings for the Databricks workspace"
  type = object({
    workspace_name_ref            = string
    workspace_tier                = string
    public_subnet_ref             = string
    private_subnet_ref            = string
    enable_databricks             = bool
    reuse_nsg                     = bool
    public_network_access_enabled = bool
  })
}

######################
# Storage Config     #
######################

variable "storage_settings" {
  description = "Azure Storage Account configuration"
  type = object({
    suffix                       = string
    account_tier                 = string
    account_kind                 = string
    account_replication_type     = string
    access_tier                  = string
    is_hns_enabled               = bool
    enable_storage_account       = bool
    public_network_access_enabled= bool
  })
}

######################
# Blob Storage Config     #
######################

variable "ai_storage_settings" {
  description = "Configuration for the non-HNS storage account used by Azure AI Foundry"
  type = object({
    enable_storage_account       = bool
    suffix                       = string
    account_tier                 = string
    account_kind                 = string
    account_replication_type     = string
    access_tier                  = string
    is_hns_enabled               = bool
    public_network_access_enabled = bool
  })
  default = {
    enable_storage_account        = true
    suffix                        = "aif"
    account_tier                  = "Standard"
    account_kind                  = "StorageV2"
    account_replication_type      = "LRS"
    access_tier                   = "Hot"
    is_hns_enabled                = false         # 👈 Flat Blob storage
    public_network_access_enabled = true
  }
}

# 👇 Removed deprecated `allow_blob_public_access` (no longer supported after 3.70)
# 👇 Removed container_type here; if needed, manage it directly in main.tf

######################
# Key Vault Config   #
######################

variable "keyvault_settings" {
  description = "Azure Key Vault configuration (RBAC / BYOK access)"
  type = object({
    kva_user                 = string
    byok_access_object_id    = string
    secret_permissions       = list(string)
    key_permissions          = list(string)
    certificate_permissions  = list(string)
  })
}

######################
# CosmosDB Config    #
######################

variable "cosmos_settings" {
  description = "Azure CosmosDB configuration"
  type = object({
    enable_cosmos             = bool
    consistency_level         = string
    account_kind              = string
    offer_type                = string
    enable_analytical_storage = bool
  })
  default = {
    enable_cosmos             = true
    consistency_level         = "Session"
    account_kind              = "GlobalDocumentDB"
    offer_type                = "Standard"
    enable_analytical_storage = false
  }
}

###############################
# AI Search & Foundry Config  #
###############################

variable "ai_search_settings" {
  description = "Azure AI Search configuration"
  type = object({
    enable_ai_search = bool
    sku              = string
    replica_count    = number
    partition_count  = number
  })
  default = {
    enable_ai_search = true
    sku              = "basic"
    replica_count    = 1
    partition_count  = 1
  }
}

variable "ai_foundry_settings" {
  description = "Azure AI Foundry configuration"
  type = object({
    enable_ai_foundry = bool
    kind              = string
    sku_name          = string
  })
  default = {
    enable_ai_foundry = true
    kind              = "CognitiveServices"  
    sku_name          = "S0"
  }
}

