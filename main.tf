# The idsec provider authenticates with the credential pulled from CCP (module "ccp" in ccp.tf).
# CCP login (KeyID) -> service user / username, CCP "Content" -> service token / secret.
provider "idsec" {
  auth_method = var.idsec_auth_method

  # identity_service_user (recommended for automation)
  service_user  = var.idsec_auth_method == "identity_service_user" ? module.ccp.username : null
  service_token = var.idsec_auth_method == "identity_service_user" ? module.ccp.secret : null

  # identity
  username = var.idsec_auth_method == "identity" ? module.ccp.username : null
  secret   = var.idsec_auth_method == "identity" ? module.ccp.secret : null

  subdomain = var.idsec_subdomain
}

# Read-only connectivity check: confirms the CCP credential can log in to Idira.
# Remove once the SIA resources are in place.
data "idsec_identity_user" "terraform_identity" {
  username = module.ccp.username
}

# SIA resources go here.
