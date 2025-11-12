environment = "dev"
app_ref     = "dp"
region_code = "az1"
ai_foundry_region_code = "az3"


databricks_settings = {
  workspace_name_ref            = "dpsbx"
  workspace_tier                = "premium"
  public_subnet_ref             = "38-app"
  private_subnet_ref            = "39-app"
  enable_databricks             = true
  reuse_nsg                     = false
  public_network_access_enabled = true
}

storage_settings = {
  suffix                       = "001"
  account_tier                 = "Standard"
  account_kind                 = "StorageV2"
  account_replication_type     = "LRS"
  access_tier                  = "Cool"
  is_hns_enabled               = true
  storage_container_type       = "private"
  enable_storage_account       = true
  public_network_access_enabled= false
  allow_blob_public_access     = false
}

keyvault_settings = {
  kva_user                = "srv-dp-akvadmin@corp.onmicrosoft.com"
  byok_access_object_id   = "56d901b8-789a-441f-938d-c1a1338822c1"
  secret_permissions      = ["Get","List","Set"]
  key_permissions         = ["Get","List"]
  certificate_permissions = ["Get","List"]
}

cosmos_settings = {
  enable_cosmos             = true
  consistency_level         = "Session"
  account_kind              = "GlobalDocumentDB"
  offer_type                = "Standard"
  enable_analytical_storage = false
}

ai_search_settings = {
  enable_ai_search = true
  sku              = "basic"
  replica_count    = 1
  partition_count  = 1
}

ai_foundry_settings = {
  enable_ai_foundry = true
  kind              = "OpenAI"
  sku_name          = "S0"
}
