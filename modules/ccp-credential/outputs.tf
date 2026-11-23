output "username" {
  description = "Login retrieved from CCP (the property named by username_property)."
  value       = nonsensitive(local.account[var.username_property])
}

output "secret" {
  description = "Secret retrieved from CCP (the Content property)."
  value       = local.account.Content
  sensitive   = true
}

output "account_properties" {
  description = "All non-secret properties CCP returned for the account (Safe, Folder, Object, Address, PolicyID, ...)."
  value       = nonsensitive({ for k, v in local.account : k => v if k != "Content" })
}
