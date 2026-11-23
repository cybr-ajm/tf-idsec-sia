# Retrieve the Idira API credential from CyberArk CCP (local module in ./modules).
module "ccp" {
  source = "./modules/ccp-credential"

  base_url             = var.ccp_base_url
  service_path         = var.ccp_service_path
  app_id               = var.ccp_app_id
  safe                 = var.ccp_safe
  object               = var.ccp_object
  folder               = var.ccp_folder
  account_username     = var.ccp_account_username
  account_address      = var.ccp_account_address
  query                = var.ccp_query
  username_property    = var.ccp_username_property
  ca_cert_path         = var.ccp_ca_cert_path
  client_cert_path     = var.ccp_client_cert_path
  client_key_path      = var.ccp_client_key_path
  insecure_skip_verify = var.ccp_insecure_skip_verify
}
