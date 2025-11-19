\# ☁️ Azure Cloud Architect Bicep Templates  

\### Enterprise-Grade Landing Zones • Modular Infrastructure • Secure-by-Default



This repository provides a complete, production-grade Azure \*\*App Landing Zone\*\* built using modular Bicep templates.  

It follows enterprise Cloud Adoption Framework (CAF) principles while staying fully reusable for any app, project, or business domain.



---



\## Features



\### ✔ Modular Hub/Spoke Networking  

\- Hub VNet (`10.0.0.0/16`)  

\- Spoke (App) VNet (`10.10.0.0/16`)  

\- App + Data subnets  

\- NSGs with clean rule abstraction  

\- Hub ⇄ Spoke peering  



\### ✔ Secure-by-Default Architecture  

\- Azure Key Vault (RBAC mode)  

\- Private Endpoints for KV, Storage, SQL  

\- App Service VNet integration  

\- Public network disabled for all data resources  

\- Managed Identity access to Key Vault  



\### ✔ Compute Layer  

\- Linux App Service Web API  

\- Injected app settings: KV, Storage, SQL, App Insights  

\- Secure VNet integration in the `app-subnet`  

\- HTTPS only  



\### ✔ Data Layer  

\- Storage Account (private-only)  

\- SQL Server + SQL Database (private-only)  

\- Private endpoints in `data-subnet`  



\### ✔ Observability  

\- Log Analytics Workspace  

\- Application Insights  

\- Diagnostics for App Service, Key Vault, and more  



\### ✔ Governance  

\- Optional cost budgets  

\- Optional policy assignments (any built-in or custom policy)  



---



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




