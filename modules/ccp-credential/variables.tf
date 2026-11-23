variable "base_url" {
  description = "Base URL of the CCP server, e.g. https://ccp.example.com"
  type        = string
}

variable "service_path" {
  description = "CCP web service name (IIS application)."
  type        = string
  default     = "AIMWebService"
}

variable "app_id" {
  description = "CCP Application ID authorized on the safe."
  type        = string
}

variable "safe" {
  description = "Safe holding the credential."
  type        = string
}

variable "object" {
  description = "Account object name in the safe. Set this or account_username/query."
  type        = string
  default     = null
}

variable "folder" {
  description = "Folder within the safe."
  type        = string
  default     = null
}

variable "account_username" {
  description = "Optional UserName filter for the CCP query."
  type        = string
  default     = null
}

variable "account_address" {
  description = "Optional Address filter for the CCP query."
  type        = string
  default     = null
}

variable "query" {
  description = "Optional free-form CCP Query (e.g. \"Safe=X;Folder=Root;Object=Y\")."
  type        = string
  default     = null
}

variable "username_property" {
  description = "CCP response property returned as the username output. KeyID for the CyberArkIdentityServiceUser platform (UserName holds a display label); UserName for most others."
  type        = string
  default     = "KeyID"
}

variable "ca_cert_path" {
  description = "Path to a PEM CA bundle that signed the CCP server certificate (if not publicly trusted)."
  type        = string
  default     = null
}

variable "client_cert_path" {
  description = "Path to a PEM client certificate, if the CCP application uses certificate authentication."
  type        = string
  default     = null
}

variable "client_key_path" {
  description = "Path to the PEM private key for client_cert_path."
  type        = string
  default     = null
}

variable "insecure_skip_verify" {
  description = "Skip CCP server TLS verification. Lab use only."
  type        = bool
  default     = false
}
