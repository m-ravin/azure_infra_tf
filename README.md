# Azure Infrastructure as Code with Terraform

This repository contains Terraform configurations to deploy and manage Azure infrastructure resources in a scalable and repeatable manner. The project uses Terraform to provision resources such as resource groups, storage accounts, key vaults, Databricks workspaces, Azure Cosmos DB, and Azure AI Search services.

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Prerequisites](#prerequisites)
3. [Project Structure](#project-structure)
4. [Configuration](#configuration)
5. [Step-by-Step Setup Guide](#step-by-step-setup-guide)
6. [Usage](#usage)
7. [Cleanup](#cleanup)
8. [Troubleshooting](#troubleshooting)

---

## 📖 Project Overview

This Terraform project deploys the following Azure resources:

- **Resource Group**: Central container for all resources
- **Storage Account**: Primary storage with Hierarchical Namespace (HNS) for data lake capabilities
- **AI Storage Account**: Dedicated blob storage (non-HNS) for Azure AI Foundry models and data
- **Key Vault**: For secure secret and key management
- **Databricks Workspace**: For big data processing and analytics
- **Azure Cosmos DB**: For globally distributed NoSQL database with optional analytical storage
- **Azure AI Search**: For cognitive search and semantic indexing capabilities
- **Azure AI Foundry**: For building, deploying, and managing AI applications with integrated access to storage and key vault

The infrastructure is environment-aware (dev, qa, prod) and supports multi-region deployments. The AI Foundry service can be deployed to a different region than the primary infrastructure, allowing you to leverage region-specific AI capabilities.

### Key Features

- **Multi-Region Support**: Deploy main infrastructure and AI services to different Azure regions
- **Flexible Enablement**: Each major service can be independently enabled or disabled via configuration
- **Integrated Security**: AI Foundry integrated with Key Vault and Storage Account for secure credential management
- **Scalable Storage**: Two separate storage accounts for different workload patterns (HNS for data lakes, Blob for AI models)

---

## 📦 Prerequisites

Before you begin, ensure you have the following installed and configured:

### Required Software

- **Terraform**: Version >= 1.3.0
  - [Download Terraform](https://www.terraform.io/downloads.html)
  - Verify installation: `terraform --version`

- **Azure CLI**: Latest version
  - [Install Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
  - Verify installation: `az --version`

- **Git** (optional, for version control)
  - [Install Git](https://git-scm.com/downloads)

### Azure Account Requirements

- An active Azure subscription
- Appropriate permissions in your Azure subscription (Contributor or Owner role recommended)
- Azure Service Principal credentials for CI/CD pipelines (optional)

### Optional Tools

- **VS Code** with Terraform extension for better editing experience
- **Terraform CLI Autocomplete** for enhanced command-line experience

---

## 📁 Project Structure

```
azure_infra_tf/
├── main.tf                 # Primary Terraform configuration (resources)
├── variables.tf            # Variable definitions and descriptions
├── provider.tf             # Azure provider configuration
├── terraform.tfvars        # Environment-specific variable values
├── README.md               # This file
├── .terraform/             # Terraform working directory (auto-generated)
├── terraform.tfstate       # Current state file (local backend)
├── terraform.tfstate.backup # Backup of previous state
└── tfplan                  # Saved plan file
```

### File Descriptions

| File | Purpose |
|------|---------|
| `main.tf` | Contains all resource definitions (Storage, AI Storage, KeyVault, Databricks, Cosmos DB, AI Search, AI Foundry) |
| `variables.tf` | Declares all input variables with descriptions and types for all services |
| `provider.tf` | Configures Azure provider and required Terraform/provider versions |
| `terraform.tfvars` | Sets actual values for variables (environment-specific configuration) |

---

## ⚙️ Configuration

### Environment Variables

Before deploying, you must set the following Azure authentication environment variables. These authenticate Terraform with your Azure subscription.

#### For Interactive Azure Login (Recommended for Development)

```powershell
# Windows PowerShell
az login
az account set --subscription "<SUBSCRIPTION_ID>"
```

#### For Service Principal Authentication (CI/CD)

Set these environment variables in your shell:

```powershell
# Windows PowerShell
$env:ARM_CLIENT_ID="<APPID_VALUE>"
$env:ARM_CLIENT_SECRET="<PASSWORD_VALUE>"
$env:ARM_SUBSCRIPTION_ID="<SUBSCRIPTION_ID>"
$env:ARM_TENANT_ID="<TENANT_VALUE>"
```

```bash
# Linux/macOS Bash
export ARM_CLIENT_ID="<APPID_VALUE>"
export ARM_CLIENT_SECRET="<PASSWORD_VALUE>"
export ARM_SUBSCRIPTION_ID="<SUBSCRIPTION_ID>"
export ARM_TENANT_ID="<TENANT_VALUE>"
```

### Customizing Variables

Edit `terraform.tfvars` to customize your deployment:

```hcl
environment = "dev"              # Deployment environment (dev, qa, prod)
app_ref     = "dp"               # Short app reference for naming
region_code = "az1"              # Region code for primary resources (az1, az2, az3)
ai_foundry_region_code = "az3"   # Region code for AI Foundry (optional, defaults to region_code if empty)
```

Additional configuration options are available in `terraform.tfvars` for:
- Databricks workspace settings (tier, network configuration)
- Storage account settings (tier, replication, HNS enablement)
- AI Storage account settings (non-HNS blob storage for AI Foundry)
- Key Vault access policies and RBAC
- Cosmos DB consistency, replication, and analytical storage
- AI Search SKU and capacity
- AI Foundry service settings (enable/disable, SKU)

---

## 🚀 Step-by-Step Setup Guide

### Step 1: Prerequisites Verification

Verify that all required tools are installed:

```powershell
# Check Terraform version
terraform --version

# Check Azure CLI version
az --version

# Check Terraform working directory (if upgrading)
terraform -version
```

### Step 2: Azure Authentication

#### Option A: Interactive Login (Development)

```powershell
# Login to Azure
az login

# Verify and set active subscription
az account show

# If you have multiple subscriptions, set the correct one
az account set --subscription "<SUBSCRIPTION_ID>"
```

#### Option B: Service Principal Login (CI/CD)

Create a service principal and set environment variables as described in the [Configuration](#configuration) section.

### Step 3: Clone or Navigate to Repository

```powershell
# Navigate to the project directory
cd c:\Users\ravin\Desktop\Code\azure_infra_tf
```

### Step 4: Initialize Terraform

Initialize the Terraform working directory. This downloads providers and sets up the backend.

```powershell
terraform init -upgrade
```

**What this does:**
- Downloads the Azure provider plugin
- Creates `.terraform/` directory
- Initializes state management

### Step 5: Validate Configuration

Validate that your Terraform configuration is syntactically correct:

```powershell
terraform validate
```

**Expected output:**
```
Success! The configuration is valid.
```

### Step 6: Review Resource Configuration

Review your `terraform.tfvars` file and ensure all values are appropriate for your environment:

```powershell
# View current variable values
cat terraform.tfvars
```

Key variables to verify:
- `environment`: Should match your deployment environment
- `app_ref`: Unique application identifier
- `region_code`: Must exist in `azure_region_map` in `variables.tf`
- Resource-specific settings (storage, Databricks, Key Vault, etc.)

### Step 7: Plan Terraform Deployment

Generate and review the execution plan before applying changes:

```powershell
terraform plan -out=tfplan
```

**What this does:**
- Compares current state to desired state
- Shows all resources that will be created/modified/destroyed
- Saves the plan to `tfplan` file

**Review the output carefully** for:
- Expected resources to be created
- No unexpected deletions
- Correct resource naming conventions (based on environment, region, app_ref)

### Step 8: Apply Terraform Configuration

Apply the plan to create actual Azure resources:

```powershell
terraform apply tfplan
```

**Important:** This step will:
- Create actual resources in your Azure subscription
- You will be charged for any billable resources
- Incur costs according to Azure pricing

Monitor the output for any errors. The process typically takes 5-15 minutes depending on resource complexity.

### Step 9: Verify Deployment in Azure

Confirm that resources were successfully created in Azure:

```powershell
# List all resources in your resource group
az resource list --resource-group rsg-dev-az1-dp

# Verify specific resource group exists
az group show --name rsg-dev-az1-dp

# View resource group tags and location
az group show --name rsg-dev-az1-dp --query "{name:name, location:location, tags:tags}"
```

### Step 9: Verify Deployment in Azure

Confirm that resources were successfully created in Azure:

```powershell
# List all resources in your resource group
az resource list --resource-group rsg-dev-az1-dp

# Verify specific resource group exists
az group show --name rsg-dev-az1-dp

# View resource group tags and location
az group show --name rsg-dev-az1-dp --query "{name:name, location:location, tags:tags}"

# Verify AI Foundry was created
az cognitiveservices account list --resource-group rsg-dev-az1-dp

# Check AI Foundry region and configuration
az cognitiveservices account show --resource-group rsg-dev-az1-dp --name aifoundry-dev-az1-dp
```

### Step 10: Save Terraform Outputs

Terraform might generate useful outputs. View them with:

```powershell
terraform output
```

---

## 🤖 Azure AI Foundry Configuration

### Overview

Azure AI Foundry (powered by Azure Cognitive Services) is integrated into this Terraform configuration with seamless integration to your storage and key vault resources.

### Architecture

The AI Foundry setup includes:

- **AI Foundry Service**: The primary cognitive services hub
- **Dedicated AI Storage Account**: Non-HNS blob storage specifically for AI models and data
- **Key Vault Integration**: Secure key and secret management
- **Regional Flexibility**: Deploy AI Foundry to a region optimized for AI services
- **System-Assigned Identity**: Managed identity for secure authentication

### Configuration

#### Enable/Disable AI Foundry

In `terraform.tfvars`:

```hcl
ai_foundry_settings = {
  enable_ai_foundry = true        # Set to false to disable
  kind              = "CognitiveServices"
  sku_name          = "S0"        # Standard tier
}
```

#### AI Foundry Storage Account

A separate storage account is created specifically for AI Foundry:

```hcl
ai_storage_settings = {
  enable_storage_account        = true
  suffix                        = "aif"  # Appended to storage account name
  account_tier                  = "Standard"
  account_kind                  = "StorageV2"
  account_replication_type      = "LRS"   # Locally redundant
  access_tier                   = "Hot"   # Hot tier for frequent access
  is_hns_enabled                = false   # Flat blob storage, not hierarchical
  public_network_access_enabled = true
}
```

**Key Points:**
- **Non-HNS Storage**: Uses flat blob structure, optimized for AI model storage
- **Hot Tier**: Configured for frequent access to AI models and training data
- **Separate from Primary Storage**: Primary storage has HNS enabled (data lake), while AI storage is flat blob storage

#### Multi-Region AI Foundry

Deploy AI Foundry to a different region to access region-specific AI capabilities:

```hcl
region_code            = "az1"    # Primary infrastructure region (Central India)
ai_foundry_region_code = "az1"    # AI Foundry region (East US)
```

**Behavior:**
- If `ai_foundry_region_code` is empty, AI Foundry uses the primary region
- If specified, AI Foundry is deployed to the configured region
- All other resources remain in the primary region
- This allows you to leverage region-specific AI model availability

### Accessing AI Foundry

After deployment, access your AI Foundry service:

```powershell
# Get AI Foundry resource details
$rgName = "rsg-dev-az1-dp"
$aifName = "aifoundry-dev-az1-dp"

az cognitiveservices account show `
  --resource-group $rgName `
  --name $aifName `
  --query "{name:name, location:location, kind:kind, sku:sku.name}"

# Get AI Foundry API keys
az cognitiveservices account keys list `
  --resource-group $rgName `
  --name $aifName

# Get AI Foundry endpoint
az cognitiveservices account show `
  --resource-group $rgName `
  --name $aifName `
  --query "properties.endpoint"
```

### AI Foundry with Models

#### Connect to AI Models

```powershell
# Set environment variables for programmatic access
$rgName = "rsg-dev-az1-dp"
$aifName = "aifoundry-dev-az1-dp"

# Get endpoint and key
$endpoint = az cognitiveservices account show `
  --resource-group $rgName `
  --name $aifName `
  --query "properties.endpoint" -o tsv

$key = az cognitiveservices account keys list `
  --resource-group $rgName `
  --name $aifName `
  --query "key1" -o tsv

Write-Host "AI Foundry Endpoint: $endpoint"
Write-Host "AI Foundry Key: $key"
```

#### Using with Python

```python
from azure.ai.projects import AIProjectClient
from azure.identity import DefaultAzureCredential

# Initialize client with AI Foundry credentials
client = AIProjectClient.from_connection_string(
    connection_string="<your-ai-foundry-connection-string>"
)

# Create and manage AI projects and agents
project = client.projects.create(name="my-project")
```

### Storage Account Integration

The AI Foundry service is automatically linked to:

1. **AI Storage Account**: For model storage and training data
2. **Key Vault**: For secure credential management

```powershell
# Access AI storage account
$storageRg = "rsg-dev-az1-dp"
$storageName = "stdevaz1dpaif"  # Pattern: st{env}{region}{app_ref}{suffix}

# Get storage account details
az storage account show --resource-group $storageRg --name $storageName

# List containers
az storage container list --account-name $storageName
```

### Key Vault Integration

AI Foundry uses Key Vault for:
- API key storage
- Secret management
- Access control

```powershell
# View Key Vault configuration
az keyvault show --name "kv-dev-az1-dp"

# List secrets (if you have access)
az keyvault secret list --vault-name "kv-dev-az1-dp"
```

### Monitoring and Management

```powershell
# Monitor AI Foundry usage
az monitor metrics list `
  --resource "/subscriptions/<subscription-id>/resourceGroups/rsg-dev-az1-dp/providers/Microsoft.CognitiveServices/accounts/aifoundry-dev-az1-dp" `
  --metric "UsedTokens"

# Check deployment cost (requires Azure Cost Management)
az cost management export create `
  --resource-group rsg-dev-az1-dp `
  --scope "/subscriptions/<subscription-id>/resourceGroups/rsg-dev-az1-dp"
```

### AI Foundry Disable/Cleanup

To disable AI Foundry without affecting other resources:

```hcl
# In terraform.tfvars, set:
ai_foundry_settings = {
  enable_ai_foundry = false   # Disables AI Foundry creation
  ...
}

# Or disable AI storage:
ai_storage_settings = {
  enable_storage_account = false
  ...
}
```

Then apply changes:

```powershell
terraform plan -out=tfplan
terraform apply tfplan
```

---

## 💡 Usage

### Managing State

Terraform tracks infrastructure state in `terraform.tfstate`. **Important considerations:**

```powershell
# View current state
terraform show

# Backup current state
Copy-Item terraform.tfstate terraform.tfstate.backup

# Refresh state from Azure
terraform refresh
```

### Updating Infrastructure

To modify existing resources:

```powershell
# 1. Edit terraform.tfvars or main.tf
# 2. Validate changes
terraform validate

# 3. Plan changes
terraform plan -out=tfplan

# 4. Review the plan carefully
# 5. Apply changes
terraform apply tfplan
```

### Adding New Resources

To add new Azure resources:

1. Add resource definition to `main.tf`
2. Add any required variables to `variables.tf`
3. Add variable values to `terraform.tfvars`
4. Run `terraform plan` to verify
5. Run `terraform apply tfplan` to create

### Targeting Specific Resources

To apply changes to only specific resources:

```powershell
# Plan for specific resource
terraform plan -target=azurerm_resource_group.rg

# Apply only to specific resource
terraform apply -target=azurerm_storage_account.storage
```

---

## 🧹 Cleanup

### Destroying All Resources

To remove all Azure resources created by this Terraform configuration:

```powershell
# ⚠️ WARNING: This will delete all resources
terraform plan -destroy

# Review the destruction plan carefully before proceeding

# Destroy all resources
terraform destroy
```

### Removing Local Terraform Files

After destroying resources, clean up local Terraform files:

```powershell
# Remove Terraform working directory
Remove-Item -Recurse -Force .terraform

# Remove local state files (backup first!)
Remove-Item terraform.tfstate
Remove-Item terraform.tfstate.backup
Remove-Item tfplan
```

---

## 🔧 Troubleshooting

### Common Issues and Solutions

#### 1. Authentication Errors

**Error:** `Error: Unable to list provider account roles: Unauthorised`

**Solution:**
```powershell
# Clear cached credentials
az logout
az login

# Verify subscription
az account show
```

#### 2. Provider Version Issues

**Error:** `Error: Unsupported provider version`

**Solution:**
```powershell
# Upgrade Terraform
terraform init -upgrade

# Remove and reinitialize
Remove-Item -Recurse -Force .terraform
terraform init
```

#### 3. Resource Group Naming Conflicts

**Error:** `Error: A resource with the ID [...] already exists`

**Solution:**
Change `environment`, `region_code`, or `app_ref` in `terraform.tfvars` to ensure unique naming.

#### 4. State File Lock Issues

**Error:** `Error: Error acquiring the state lock`

**Solution:**
```powershell
# Force unlock (use with caution)
terraform force-unlock <LOCK_ID>
```

#### 5. Permission Errors

**Error:** `Error: Insufficient permissions`

**Solution:**
- Verify your Azure account has appropriate roles in the subscription
- Contact your Azure subscription owner to grant necessary permissions

### Useful Debugging Commands

```powershell
# Enable debug logging
$env:TF_LOG="DEBUG"
terraform plan

# Disable debug logging
Remove-Item env:TF_LOG

# Validate Azure connectivity
az account show

# List available subscriptions
az account list

# Check installed provider versions
terraform version

# Inspect state file (formatted)
terraform show
```

---

## 📚 Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs/)
- [Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure CLI Documentation](https://docs.microsoft.com/cli/azure/)
- [Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/)

---

## 📝 Notes

- **State Management**: By default, Terraform stores state locally. For production, consider using Azure Storage backend.
- **Cost Estimation**: Run `terraform plan` to understand resource costs before deployment.
- **Version Control**: Add `terraform.tfstate*` to `.gitignore` to prevent committing sensitive state files.
- **Regional Availability**: Verify that all resources are available in your chosen Azure region.

---

## 📄 License

This project is provided as-is for infrastructure deployment purposes.

---

**Last Updated:** November 2025