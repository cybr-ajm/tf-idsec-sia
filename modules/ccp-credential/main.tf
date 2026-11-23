# Retrieve a credential from CyberArk Central Credential Provider (CCP).
#
# CCP REST API:
#   GET https://<ccp-host>/AIMWebService/api/Accounts?AppID=..&Safe=..&Object=..
# Response (200): JSON containing "UserName", "Content" (the secret), "Address", ...

locals {
  query_params = { for k, v in {
    AppID    = var.app_id
    Safe     = var.safe
    Object   = var.object
    Folder   = var.folder
    UserName = var.account_username
    Address  = var.account_address
    Query    = var.query
  } : k => v if v != null && v != "" }

  url = format(
    "%s/%s/api/Accounts?%s",
    trimsuffix(var.base_url, "/"),
    var.service_path,
    join("&", [for k, v in local.query_params : "${k}=${urlencode(v)}"])
  )
}

data "http" "credential" {
  url    = local.url
  method = "GET"

  request_headers = {
    Accept = "application/json"
  }

  # Optional TLS settings: custom CA for the CCP server, and a client certificate
  # if the CCP application is configured for certificate authentication.
  # The IIS binding must request the client certificate during the initial handshake
  # (netsh http ... clientcertnegotiation=enable); Go does not support renegotiation.
  ca_cert_pem     = var.ca_cert_path == null ? null : file(var.ca_cert_path)
  client_cert_pem = var.client_cert_path == null ? null : file(var.client_cert_path)
  client_key_pem  = var.client_key_path == null ? null : file(var.client_key_path)
  insecure        = var.insecure_skip_verify

  request_timeout_ms = 30000

  retry {
    attempts     = 3
    min_delay_ms = 1000
  }

  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "CCP credential retrieval failed (HTTP ${self.status_code}): ${self.response_body}"
    }
  }
}

locals {
  account = jsondecode(sensitive(data.http.credential.response_body))
}
