# Cloud Architect Bicep Templates

A production-grade library of reusable Azure Bicep modules for enterprise cloud architectures.

## 📂 Structure

- **infra/main.bicep** — landing zone entrypoint
- **infra/env/** — dev/test/prod parameter files
- **infra/modules/** — reusable modules
  - networking
  - security
  - compute
  - data
  - observability
  - governance
- **scenarios/** — webapp, containerapp, VM landing zones
- **pipelines/** — GitHub Actions deployment workflow

## 🚀 Purpose

This repository provides modular, parameter-driven infrastructure components for:
- App hosting (App Service, Container Apps, Functions, VMs)
- Networking (hub-spoke, NSG, Bastion, Private DNS)
- Security (Key Vault, private endpoints, RBAC)
- Data services (Storage, SQL, Cosmos DB)
- Observability (Log Analytics, App Insights)
- Governance (Policy, budgets)

Designed for Cloud Engineers and Cloud Architects building standardized landing zones.
