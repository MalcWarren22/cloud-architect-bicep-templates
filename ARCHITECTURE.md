# ☁️ Azure Cloud Architect Bicep Templates  
### Enterprise-Grade Landing Zones • Modular Infrastructure • Secure-by-Default

This repository provides a complete, production-grade Azure **App Landing Zone** built entirely with **modular Bicep templates**.  
It is engineered to mirror enterprise Cloud Adoption Framework (CAF) principles while staying fully reusable for any app, project, or business domain.

---

## 🚀 Features

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

