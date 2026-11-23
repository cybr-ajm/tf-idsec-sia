output "idira_api_user" {
  description = "Idira API identity retrieved from CCP (the secret is never output)."
  value       = module.ccp.username
}

output "sia_server_policies" {
  description = "SIA policy created for each server: policy ID, name and the AD admin group it assigns."
  value = {
    for machine, p in idsec_policy_vm.server_admin : machine => {
      policy_id   = p.metadata.policy_id
      name        = p.metadata.name
      admin_group = local.sia_policies[machine].group_name
    }
  }
}

output "idira_api_user_id" {
  description = "Idira user ID of the service user (connectivity check)."
  value       = data.idsec_identity_user.terraform_identity.user_id
}
