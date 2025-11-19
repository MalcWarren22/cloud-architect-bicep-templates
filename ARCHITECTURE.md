# Azure App Landing Zone – Architecture Deep Dive

This document provides a full architectural breakdown of the landing zone deployed using `main.bicep`. It includes networking topology, security controls, compute design, data architecture, observability, governance, and extensibility patterns.

---

# 1. Networking Architecture

## Hub VNet (`10.0.0.0/16`)

| Subnet               | Purpose                                                        |
|----------------------|----------------------------------------------------------------|
| `AzureFirewallSubnet`| Reserved for Azure Firewall or future security appliances       |
| `shared-services`    | DNS, monitoring agents, jumpbox, shared services               |

## Spoke VNet (`10.10.0.0/16`)

| Subnet        | Purpose                                                |
|---------------|--------------------------------------------------------|
| `app-subnet`  | App Service environment (VNet integration)             |
| `data-subnet` | Private endpoints for KV, SQL, Storage                 |

### VNet Peering
- Hub → Spoke  
- Spoke → Hub  
- Supports east–west internal traffic  
- No transitive routing (CAF standard)

---

# 2. Security Architecture

## Azure Key Vault (RBAC Mode)
- RBAC-only secret access (no Access Policies)
- Private endpoint in `data-subnet`
- Soft delete & purge protection enabled

### Managed Identity Permissions
App Service’s system-assigned identity is granted:
- **Key Vault Secrets User** (`4633458b-17de-408a-b874-0445c86b69e6`)

## Network Security Groups (NSG)
Applied to `app-subnet`.

| Rule              | Action     |
|------------------|------------|
| Allow HTTP 80    | Inbound    |
| Allow HTTPS 443  | Inbound    |

## Private Endpoints
All in `data-subnet`:

| Resource     | Group ID   |
|--------------|------------|
| Key Vault    | `vault`    |
| Storage      | `blob`     |
| SQL Server   | `sqlServer`|

All corresponding resources have **public access disabled**.

---

# 3. Compute Architecture

## App Service (Web API)
- Linux App Service Plan (`B1` default)
- HTTPS only
- VNet integration into `app-subnet`
- System-assigned managed identity

### App Settings Injected at Deployment
- `ASPNETCORE_ENVIRONMENT`
- `KEYVAULT_URI`
- `STORAGE_BLOB_URL`
- `SQL_SERVER_ID`
- `SQL_DATABASE_ID`
- `APPLICATIONINSIGHTS_CONNECTION_STRING`
- `APPINSIGHTS_INSTRUMENTATIONKEY`

This enables a fully private, secure application stack.

---

# 4. Data Architecture

## Storage Account
- `StorageV2`
- TLS 1.2 enforced
- Private-only (no public access)
- Private endpoint for blob operations

## SQL Server + Database
- Public network disabled
- Private endpoint only
- Default database: `appdb`
- Admin credentials replaceable with Key Vault later

---

# 5. Observability

## Log Analytics Workspace
Centralized log sink for:
- App Service diagnostics
- Key Vault diagnostic logs
- SQL and Storage (future extensions)
- NSG flow logs (future feature)

## Application Insights
- Connected to Log Analytics
- Full telemetry trace: requests, dependencies, exceptions, logs

## Diagnostic Settings Enabled For
- App Service: HTTP logs, console logs, App Logs, AllMetrics
- Key Vault: AuditEvent logs

---

# 6. Governance Layer

## Budgets
Optional, configured per environment:
- `monthlyBudgetAmount`
- Alerts at 90%
- Notifications to `budgetContactEmail`

## Policy Assignments
Optional:
- Allowed Locations
- HTTPS enforcement
- Require private access for data services
- Tag governance

---

# 7. Extensibility

The architecture is modular and easily extended:

