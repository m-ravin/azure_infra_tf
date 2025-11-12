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
- **Storage Account**: For data storage with configurable settings
- **Key Vault**: For secure secret management
- **Databricks Workspace**: For big data and analytics
- **Azure Cosmos DB**: For globally distributed database
- **Azure AI Search**: For cognitive search capabilities

The infrastructure is environment-aware (dev, qa, prod) and supports multi-region deployments with flexible configuration through Terraform variables.

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
| `main.tf` | Contains all resource definitions (Storage, KeyVault, Databricks, Cosmos DB, AI Search) |
| `variables.tf` | Declares all input variables with descriptions and types |
| `provider.tf` | Configures Azure provider and required Terraform/provider versions |
| `terraform.tfvars` | Sets actual values for variables (environment-specific) |

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
region_code = "az1"              # Region code (az1, az2, az3)
ai_foundry_region_code = "az3"   # AI Foundry specific region (optional override)
```

Additional configuration options are available in `terraform.tfvars` for:
- Databricks workspace settings
- Storage account settings
- Key Vault access policies
- Cosmos DB consistency and replication
- AI Search SKU and capacity

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

### Step 10: Save Terraform Outputs

Terraform might generate useful outputs. View them with:

```powershell
terraform output
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