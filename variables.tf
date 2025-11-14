###############################################################################
# Common Environment Variables
###############################################################################

variable "environment" {
  description = "Deployment environment (e.g., dev, qa, prod)"
  type        = string
}

variable "app_ref" {
  description = "Short application reference (used for naming)"
  type        = string
}

variable "region_code" {
  description = "Region code used for resource deployments"
  type        = string
}

variable "ai_foundry_region_code" {
  description = "Region code used for AI Foundry deployment"
  type        = string
}

variable "azure_regions_map" {
  description = "Mapping between logical region codes and Azure region names"
  type = map(string)
  default = {
    az1 = "Central India"
    az2 = "South India"
    az3 = "East US"
  }
}

variable "resource_tags" {
  description = "Resource tags"
  type        = map(string)
}

###############################################################################
# Databricks Workspace Settings
###############################################################################

variable "databricks_settings" {
  description = "Databricks workspace configuration"
  type = object({
    workspace_name_ref            = string
    workspace_tier                = string
    public_subnet_ref             = string
    private_subnet_ref            = string
    enable_databricks             = bool
    reuse_nsg                     = bool
    databricks_admin              = list(any)
    public_network_access_enabled = bool
  })
}

###############################################################################
# Storage Account Settings 
###############################################################################

variable "storage_hns_settings" {
  description = "HNS-enabled storage account configuration"
  type = object({
    enable_storage_account        = bool
    suffix                        = string
    account_tier                  = string
    account_kind                  = string
    account_replication_type      = string
    access_tier                   = string
    is_hns_enabled                = bool
    storage_byok                 = bool
    firewall_ip_rules            = list(string)
    firewall_default_action       = string
    firewall_rules_bypass         = list(string)
    static_website                = bool
    storage_container_type        = string
    public_network_access_enabled = bool
    allow_blob_public_access      = bool
    last_access_time_enabled      = bool
  })
}

variable "storage_blob_settings" {
  description = "Blob storage account configuration"
  type = object({
    enable_storage_account        = bool
    suffix                        = string
    account_tier                  = string
    account_kind                  = string
    account_replication_type      = string
    access_tier                   = string
    is_hns_enabled                = bool
    storage_byok                 = bool
    firewall_ip_rules            = list(string)
    firewall_default_action       = string
    firewall_rules_bypass         = list(string)
    static_website                = bool
    storage_container_type        = string
    public_network_access_enabled = bool
    allow_blob_public_access      = bool
    last_access_time_enabled      = bool
  })
}

###############################################################################
# Key Vault Settings
###############################################################################

variable "keyvault_settings" {
  description = "Key Vault configuration including firewall settings"
  type = object({
    suffix                     = string
    sku_name                   = string
    soft_delete                = bool
    soft_delete_retention_days = number
    enable_service_principal   = bool
    firewall_ip_rules          = list(string)
    firewall_default_action    = string
    firewall_rules_bypass      = list(string)
  })
}

###############################################################################
# CosmosDB Settings
###############################################################################

variable "cosmos_settings" {
  description = "Azure CosmosDB configuration"
  type = object({
    enable_cosmos             = bool
    consistency_level         = string
    account_kind              = string
    offer_type                = string
    enable_analytical_storage = bool
    firewall_ip_rules         = list(string)
  })
}

###############################################################################
# AI Search & AI Foundry Settings
###############################################################################

variable "ai_search_settings" {
  description = "Azure AI Search settings"
  type = object({
    enable_ai_search = bool
    sku              = string
    replica_count    = number
    partition_count  = number
  })
}

variable "ai_foundry_settings" {
  description = "Azure AI Foundry settings"
  type = object({
    enable_ai_foundry = bool
    kind              = string
    sku_name          = string
  })
}
