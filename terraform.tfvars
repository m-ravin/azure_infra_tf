environment     = "dev"
region_code     = "az1"
app_ref     = "dp"
ai_foundry_region_code = "az1"

resource_tags = {
  environment = "dev"
  owner       = "data-platform"
}

databricks_settings = {
  workspace_name_ref            = "dpsbx"
  workspace_tier                = "standard"
  public_subnet_ref             = ""
  private_subnet_ref            = ""
  enable_databricks             = false
  reuse_nsg                     = false
  public_network_access_enabled = true
  databricks_admin              = [] #Add the admins email address here for initial config
}



storage_hns_settings  = {
  suffix                       = "001"
  account_tier                 = "Standard"
  account_kind                 = "StorageV2"
  account_replication_type     = "LRS"
  access_tier                  = "Cool"
  is_hns_enabled               = true
  storage_byok                 = false
  firewall_ip_rules            = ["122.172.82.40"]
  firewall_default_action      = "Deny"
  firewall_rules_bypass        = ["AzureServices"]
  static_website               = false
  storage_container_type       = "private"
  enable_storage_account       = true     #Change this to false to decom storage account
  public_network_access_enabled= false
  allow_blob_public_access     = false
  last_access_time_enabled     = true
}

storage_blob_settings = {
  enable_storage_account        = true
  suffix                        = "aif"
  account_tier                  = "Standard"
  account_kind                  = "StorageV2"
  account_replication_type      = "LRS"
  access_tier                   = "Cool"
  is_hns_enabled                = false
  storage_byok                 = false
  firewall_ip_rules            = ["122.172.82.40"]
  firewall_default_action      = "Deny"
  firewall_rules_bypass        = ["AzureServices"]
  static_website               = false
  storage_container_type       = "private"
  enable_storage_account       = true     #Change this to false to decom storage account
  public_network_access_enabled= false
  allow_blob_public_access     = false
  last_access_time_enabled     = true
}

keyvault_settings = {
  suffix                  = ""
  sku_name                = "standard"
  soft_delete             = true
  soft_delete_retention_days = 7
  enable_service_principal = true #Allows HCF SPN to perform data plan. It is mandatory to do the deployment via DevOps
  firewall_ip_rules       = ["122.172.82.40"]
  firewall_default_action      = "Deny"
  firewall_rules_bypass        = ["AzureServices"]
}

  # kva_user                = "srv-dp-akvadmin@corp.onmicrosoft.com"
  # byok_access_object_id   = "56d901b8-789a-441f-938d-c1a1338822c1"
  # secret_permissions      = ["Get","List","Set"]
  # key_permissions         = ["Get","List"]
  # certificate_permissions = ["Get","List"]

cosmos_settings = {
  enable_cosmos             = true
  consistency_level         = "Session"
  account_kind              = "GlobalDocumentDB"
  offer_type                = "Standard"
  enable_analytical_storage = false
  firewall_ip_rules         = ["122.172.82.40"]
}

ai_search_settings = {
  enable_ai_search = true
  sku              = "free"
  replica_count    = 1
  partition_count  = 1
}

ai_foundry_settings = {
  enable_ai_foundry = true
  kind              = "OpenAI"
  sku_name          = "S0"
}


