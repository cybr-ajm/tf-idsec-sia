# ---------------------------------------------------------------------------
# CyberArk CCP
# ---------------------------------------------------------------------------

variable "ccp_base_url" {
  description = "Base URL of the CCP server, e.g. https://ccp.example.com"
  type        = string
}

variable "ccp_service_path" {
  description = "CCP web service name (IIS application)."
  type        = string
  default     = "AIMWebService"
}

variable "ccp_app_id" {
  description = "CCP Application ID authorized on the safe."
  type        = string
}

variable "ccp_safe" {
  description = "Safe holding the Idira API credential."
  type        = string
}

variable "ccp_object" {
  description = "Account object name in the safe. Set this or ccp_account_username/ccp_query."
  type        = string
  default     = null
}

variable "ccp_folder" {
  description = "Folder within the safe."
  type        = string
  default     = null
}

variable "ccp_account_username" {
  description = "Optional UserName filter for the CCP query."
  type        = string
  default     = null
}

variable "ccp_account_address" {
  description = "Optional Address filter for the CCP query."
  type        = string
  default     = null
}

variable "ccp_query" {
  description = "Optional free-form CCP Query (e.g. \"Safe=X;Folder=Root;Object=Y\")."
  type        = string
  default     = null
}

variable "ccp_username_property" {
  description = "CCP response property holding the Idira login. KeyID for the CyberArkIdentityServiceUser platform; UserName for most others."
  type        = string
  default     = "KeyID"
}

variable "ccp_ca_cert_path" {
  description = "Path to a PEM CA bundle that signed the CCP server certificate (if not publicly trusted)."
  type        = string
  default     = null
}

variable "ccp_client_cert_path" {
  description = "Path to a PEM client certificate, if the CCP application uses certificate authentication."
  type        = string
  default     = null
}

variable "ccp_client_key_path" {
  description = "Path to the PEM private key for ccp_client_cert_path."
  type        = string
  default     = null
}

variable "ccp_insecure_skip_verify" {
  description = "Skip CCP server TLS verification. Lab use only."
  type        = bool
  default     = false
}

# ---------------------------------------------------------------------------
# Idira (idsec provider)
# ---------------------------------------------------------------------------

variable "idsec_auth_method" {
  description = "idsec auth method used with the CCP credential: identity_service_user or identity."
  type        = string
  default     = "identity_service_user"

  validation {
    condition     = contains(["identity_service_user", "identity"], var.idsec_auth_method)
    error_message = "idsec_auth_method must be identity_service_user or identity."
  }
}

variable "idsec_subdomain" {
  description = "Optional Idira tenant subdomain (e.g. my-tenant)."
  type        = string
  default     = null
}

