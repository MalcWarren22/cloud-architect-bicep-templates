# ☁️ Azure Cloud Architect Bicep Templates  
### Enterprise-Grade Landing Zones • Modular Infrastructure • Secure-by-Default

This repository provides a complete, production-grade Azure **App Landing Zone** built entirely with **modular Bicep templates**.  
It is engineered to mirror enterprise Cloud Adoption Framework (CAF) principles while staying fully reusable for any app, project, or business domain.

---

## Features

### ✔ Modular Hub/Spoke Networking  
- Hub VNet (`10.0.0.0/16`)  
- Spoke (App) VNet (`10.10.0.0/16`)  
- App + Data subnets  
- NSGs with clean rule abstraction  
- VNet peering (hub ⇄ spoke)

### ✔ Secure-by-Default Architecture  
- Azure Key Vault with RBAC auth  
- Private Endpoints for:
  - Key Vault  
  - Storage (Blob)  
  - SQL Server  
- Public network access disabled for all data services  
- App Service VNet integration  
- System-assigned managed identity for secret access  

### ✔ Compute Layer (App Service Web API)  
- Linux App Service (configurable SKU)  
- Injected app settings:
  - `KEYVAULT_URI`
  - `STORAGE_BLOB_URL`
  - `SQL_SERVER_ID`
  - `SQL_DATABASE_ID`
  - Application Insights connection settings  
- Fully isolated inside the App subnet

### ✔ Data Layer (Private-Only)  
- Storage Account (no public access)  
- SQL Server + SQL Database (private-only)  
- Private endpoints in `data-subnet`  

### ✔ Observability Layer (Enterprise Logging)  
- Log Analytics Workspace  
- Application Insights  
- Diagnostic settings for:
  - App Service  
  - Key Vault (optional)  
  - SQL + Storage (extendable)

### ✔ Governance  
- Optional Monthly Budgets with 90% alert  
- Optional Policy Assignments at RG scope  
  (e.g., allowed locations, tag enforcement, private access policies)

### ✔ Fully Modular Directory Structure

## Module Catalog

This library is organized by concern. Each module is reusable and environment-agnostic.

### Networking

| Module Path                                      | Purpose                                        |
|-------------------------------------------------|------------------------------------------------|
| `infra/modules/networking/vnet.bicep`           | Creates a VNet with a configurable address space and subnets. |
| `infra/modules/networking/nsg.bicep`            | Generic NSG with rule array parameter for reusable security rules. |
| `infra/modules/networking/subnet-nsg-association.bicep` | Associates an NSG to a subnet. |
| `infra/modules/networking/vnet-peering.bicep`   | Bidirectional VNet peering between two VNets. |

### Security

| Module Path                                      | Purpose                                        |
|-------------------------------------------------|------------------------------------------------|
| `infra/modules/security/keyvault.bicep`         | RBAC-enabled Key Vault with soft delete + purge protection. |
| `infra/modules/security/private-endpoint.bicep` | Generic Private Endpoint for any Azure resource. |
| `infra/modules/security/rbac-role-assignments.bicep` | Creates one or more RBAC role assignments. |

### Compute

| Module Path                                      | Purpose                                        |
|-------------------------------------------------|------------------------------------------------|
| `infra/modules/compute/appservice-webapi.bicep` | Linux App Service plan + Web App configured for Web API workloads with VNet integration and managed identity. |

### Data

| Module Path                                      | Purpose                                        |
|-------------------------------------------------|------------------------------------------------|
| `infra/modules/data/storage-account.bicep`      | Storage Account (StorageV2) with secure defaults. |
| `infra/modules/data/sqlserver-db.bicep`         | Azure SQL Server + single database with basic configuration. |

### Observability

| Module Path                                      | Purpose                                        |
|-------------------------------------------------|------------------------------------------------|
| `infra/modules/observability/log-analytics.bicep` | Log Analytics workspace for centralized logging. |
| `infra/modules/observability/app-insights.bicep`  | Application Insights instance wired for use with Web/API workloads. |

### Governance

| Module Path                                      | Purpose                                        |
|-------------------------------------------------|------------------------------------------------|
| `infra/modules/governance/budget.bicep`         | Creates a cost budget with alert thresholds. |
| `infra/modules/governance/policy-assignment.bicep` | Assigns a built-in or custom Azure Policy at a given scope. |

