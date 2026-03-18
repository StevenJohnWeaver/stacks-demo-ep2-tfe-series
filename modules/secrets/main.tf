# modules/secrets/main.tf
# Ep2: Zero Static Secrets — Vault dynamic credentials demonstration.
#
# This component authenticates to HCP Vault using the OIDC identity token
# issued by HCP Terraform (the same JWT already used for AWS in Ep1).
# It reads a KV secret and surfaces it as a Stack output fact —
# proving that no static secrets ever touch the codebase or environment variables.

terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.0"
    }
  }
}

variable "vault_addr" {
  description = "HCP Vault cluster address"
  type        = string
}

variable "vault_namespace" {
  description = "HCP Vault namespace (admin for HCP Vault)"
  type        = string
  default     = "admin"
}

variable "vault_role" {
  description = "Vault JWT auth role for HCP Terraform OIDC"
  type        = string
}

variable "vault_jwt_token" {
  description = "OIDC JWT issued by HCP Terraform for Vault authentication"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Deployment environment label (dev, staging, prod)"
  type        = string
}

# Authenticate to Vault using the OIDC JWT from HCP Terraform.
# No static Vault token — the JWT is short-lived and scoped to this run.
provider "vault" {
  address   = var.vault_addr
  namespace = var.vault_namespace

  auth_login_jwt {
    role = var.vault_role
    jwt  = var.vault_jwt_token
  }
}

# Read a KV v2 secret from Vault — for the demo, a placeholder app config secret.
# In production this might be a database DSN, API key, or service credential.
data "vault_kv_secret_v2" "app_config" {
  mount = "secret"
  name  = "ep2-demo/${var.environment}/app-config"
}

# Surface the secret path as a non-sensitive output (the value itself is sensitive).
# This output is consumed by the Stack and becomes part of the config_facts contract
# demonstrated in Ep 5 (Ansible handshake).
output "secret_path" {
  description = "Vault KV path where the app config secret was read from"
  value       = "secret/ep2-demo/${var.environment}/app-config"
}

output "secret_version" {
  description = "Vault KV version retrieved (confirms dynamic read, not cached)"
  value       = data.vault_kv_secret_v2.app_config.version
}

# The actual secret data is intentionally NOT output here — it is consumed
# within the module. In a real pattern, you would pass data.vault_kv_secret_v2.app_config.data
# directly to the resource that needs it (e.g., a Kubernetes secret or app config).
