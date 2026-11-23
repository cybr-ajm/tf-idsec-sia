terraform {
  required_version = ">= 1.3"

  required_providers {
    idsec = {
      source  = "cyberark/idsec"
      version = "0.14.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.6"
    }
  }
}
