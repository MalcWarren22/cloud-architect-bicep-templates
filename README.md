\# Cloud Architect Bicep Templates



This repository is a toolbox of reusable \*\*Azure Bicep templates\*\* for common enterprise scenarios:



\- Landing zones (network + app + security + monitoring)

\- App hosting (App Service, Functions, Container Apps, VMs)

\- Data services (Storage, SQL, Cosmos DB)

\- Security (Key Vault, private endpoints, RBAC)

\- Observability (Log Analytics, App Insights, diagnostics)

\- Governance (Policy, budgets)



You can:



\- Use `infra/main.bicep` + `infra/env/\*.parameters.json` to deploy a full \*\*app landing zone\*\*.

\- Use individual modules under `infra/modules/\*\*` for \*\*scenario-specific\*\* deployments.



---



\## Deploying the Standard Landing Zone



\### 1. Resource group



```bash

az group create -n rg-cloud-templates-dev -l eastus



