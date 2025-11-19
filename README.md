\# ☁️ Azure Cloud Architect Bicep Templates  

\### Enterprise-Grade Landing Zones • Modular Infrastructure • Secure-by-Default



This repository provides a complete, production-grade Azure \*\*App Landing Zone\*\* built using modular Bicep templates.  

It follows enterprise Cloud Adoption Framework (CAF) principles while staying fully reusable for any app, project, or business domain.



---



\## 🚀 Features



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



\## 📂 Repository Structure





