

---



\# 🧩 \*\*ARCHITECTURE.md (FULL FILE — copy/paste)\*\*



```markdown

\# 🏗 Azure App Landing Zone – Architecture Deep Dive



This document provides a full architectural breakdown of the landing zone deployed using `main.bicep`. It includes networking topology, security controls, data paths, observability, and governance.



---



\# 1. Networking Architecture



\### Hub VNet (`10.0.0.0/16`)



| Subnet | Purpose |

|--------|---------|

| `AzureFirewallSubnet` | Reserved for Azure Firewall or future security appliances |

| `shared-services` | DNS, monitoring agents, jumpbox, shared resources |



\### Spoke VNet (`10.10.0.0/16`)



| Subnet | Purpose |

|--------|---------|

| `app-subnet` | App Service environment (VNet integration) |

| `data-subnet` | Private endpoints for KV, SQL, Storage |



\### Peering



\- \*\*hub → spoke\*\* (useRemoteGateways = false)  

\- \*\*spoke → hub\*\*



Allows east–west communication while isolating app workloads.



---



\# 2. Security Architecture



\### 🔐 Key Vault (RBAC Mode)

\- `enableRbacAuthorization = true`

\- Purge protection + soft delete

\- Managed identity of App Service gets \*\*Key Vault Secrets User\*\* role

\- Private endpoint forces secret access through internal IP



\### Network Security Group (NSG)

Applied to `app-subnet`:



| Rule | Ports | Direction |

|------|-------|-----------|

| Allow-HTTP | 80 | Inbound |

| Allow-HTTPS | 443 | Inbound |



Outbound allowed by default.



\### Private Endpoints

Placed in `data-subnet`:



| Service | Group ID |

|---------|----------|

| Key Vault | `vault` |

| Storage | `blob` |

| SQL Server | `sqlServer` |



Prevents any public ingress/egress for secrets or data.



---



\# 3. Compute Layer – App Service



\### Web API App Service

\- Linux App Service Plan  

\- HTTPS only  

\- System-assigned managed identity  

\- VNet integration (in `app-subnet`)  

\- Diagnostic logs enabled



\### App Settings Injected



| Key | Value |

|-----|--------|

| `KEYVAULT\_URI` | Access secrets securely |

| `STORAGE\_BLOB\_URL` | Storage endpoint |

| `SQL\_SERVER\_ID` | SQL resource ID |

| `SQL\_DATABASE\_ID` | SQL DB ID |

| `APPLICATIONINSIGHTS\_CONNECTION\_STRING` | Telemetry |

| `APPINSIGHTS\_INSTRUMENTATIONKEY` | Telemetry Key |



---



\# 4. Data Layer



\### Storage Account

\- `StorageV2`

\- No public access  

\- TLS 1.2 enforced  

\- Blob endpoint exposed to app



\### SQL Server + Database

\- Public access disabled  

\- Private endpoint only  

\- Basic-tier DB (`appdb`)



---



\# 5. Observability



\### Log Analytics Workspace  

Central log sink for the entire environment.



\### Application Insights  

\- Connected to Log Analytics  

\- Supports distributed tracing  

\- Injected directly into App Service



\### Diagnostic Settings  

Enabled for:

\- App Service  

\- (Optional) Key Vault  

\- Additional resources over time



Telemetry:  

Logs, Metrics, Request traces, Console logs, and more.



---



\# 6. Governance



\### Budgets  

Optional, applied at the \*\*resource group scope\*\*:

\- Monthly spend limit  

\- 90% notification  

\- Alerts emailed to configured contacts  



\### Policy Assignment  

Optional:

\- Allowed Locations  

\- Require Tags  

\- HTTPS only  

\- Disallow public IPs  

\- Enforce Private Endpoints  



Any Azure Built-in or Custom Policy can be injected.



---



\# 7. Extensibility Model



This architecture is modular. Future additions fit naturally:



\- API Management (private)  

\- Azure Firewall with UDR routing  

\- Azure Container Apps  

\- Event Grid / Service Bus  

\- Private DNS Zones  

\- Multi-spoke scaling  

\- Multi-region DR pattern  



---



\# 8. Diagram (Conceptual)





