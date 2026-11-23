# ---------------------------------------------------------------------------
# SIA: one VM policy per Windows server / AD admin group
# ---------------------------------------------------------------------------

variable "sia_servers" {
  description = <<-EOT
    Windows servers that get a policy, keyed by machine (computer) name. Every field is optional:
      group_name            - use this AD group name instead of "<sia_group_prefix><machine>"
      domain                - AD DNS domain for the FQDN target (default: sia_domain)
      policy_name           - policy name (default: format(sia_policy_name_format, machine))
      description           - policy description, up to 200 characters
      principals            - use these principals instead of sia_principals
      additional_principals - principals added on top of the default or overridden list
      policy_tags           - tags added to sia_policy_tags
      status                - Active or Suspended (default: sia_policy_status)
      time_frame            - { from_time, to_time } in yyyy-MM-ddTHH:mm:ss (default: sia_time_frame)
  EOT
  type = map(object({
    group_name  = optional(string)
    domain      = optional(string)
    policy_name = optional(string)
    description = optional(string)
    principals = optional(list(object({
      id                    = string
      name                  = string
      type                  = string
      source_directory_id   = optional(string)
      source_directory_name = optional(string)
    })))
    additional_principals = optional(list(object({
      id                    = string
      name                  = string
      type                  = string
      source_directory_id   = optional(string)
      source_directory_name = optional(string)
    })), [])
    policy_tags = optional(list(string), [])
    status      = optional(string)
    time_frame = optional(object({
      from_time = optional(string)
      to_time   = optional(string)
    }))
  }))
  default = {}

  validation {
    condition     = alltrue([for s in values(var.sia_servers) : contains(["Active", "Suspended"], coalesce(s.status, "Active"))])
    error_message = "sia_servers[*].status must be Active or Suspended."
  }

  validation {
    condition = alltrue(flatten([
      for s in values(var.sia_servers) : [
        for p in concat(coalesce(s.principals, []), s.additional_principals) :
        contains(["USER", "GROUP", "ROLE"], p.type) && (p.type == "ROLE" || (p.source_directory_id != null && p.source_directory_name != null))
      ]
    ]))
    error_message = "Each principal type must be USER, GROUP or ROLE, and USER/GROUP principals need source_directory_id and source_directory_name."
  }
}

variable "sia_group_prefix" {
  description = "Prefix added to the machine name to form the AD group name, e.g. \"SRV-Admins-\" + \"APP01\" = \"SRV-Admins-APP01\"."
  type        = string
}

variable "sia_domain" {
  description = "Default AD DNS domain for the FQDN target rule (e.g. corp.example.com). Can be overridden per server."
  type        = string
  default     = null
}

variable "sia_principals" {
  description = <<-EOT
    Default users/groups/roles that can use each server's policy.
      id                    - Idira identity ID (max 40 characters)
      name                  - principal name
      type                  - USER, GROUP or ROLE
      source_directory_id   - directory service ID (required unless type is ROLE)
      source_directory_name - directory service name, letters/digits/underscore, max 50 (required unless type is ROLE)
  EOT
  type = list(object({
    id                    = string
    name                  = string
    type                  = string
    source_directory_id   = optional(string)
    source_directory_name = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for p in var.sia_principals :
      contains(["USER", "GROUP", "ROLE"], p.type) && (p.type == "ROLE" || (p.source_directory_id != null && p.source_directory_name != null))
    ])
    error_message = "Each principal type must be USER, GROUP or ROLE, and USER/GROUP principals need source_directory_id and source_directory_name."
  }
}

variable "sia_policy_name_format" {
  description = "format() pattern for the policy name; %s is the machine name. Max 200 characters."
  type        = string
  default     = "Server Admin - %s"
}

variable "sia_policy_tags" {
  description = "Tags applied to every policy (max 20 per policy, including per-server tags)."
  type        = list(string)
  default     = []
}

variable "sia_policy_status" {
  description = "Default policy status: Active or Suspended."
  type        = string
  default     = "Active"

  validation {
    condition     = contains(["Active", "Suspended"], var.sia_policy_status)
    error_message = "sia_policy_status must be Active or Suspended."
  }
}

variable "sia_policy_type" {
  description = "Recurring or OnDemand."
  type        = string
  default     = "Recurring"

  validation {
    condition     = contains(["Recurring", "OnDemand"], var.sia_policy_type)
    error_message = "sia_policy_type must be Recurring or OnDemand."
  }
}

variable "sia_delegation_classification" {
  description = "Policy user rights: Restricted or Unrestricted."
  type        = string
  default     = "Unrestricted"

  validation {
    condition     = contains(["Restricted", "Unrestricted"], var.sia_delegation_classification)
    error_message = "sia_delegation_classification must be Restricted or Unrestricted."
  }
}

variable "sia_time_zone" {
  description = "Time zone for the access window and time frame (e.g. GMT, America/New_York). Max 50 characters."
  type        = string
  default     = "GMT"
}

variable "sia_time_frame" {
  description = "Default period the policies are active, { from_time, to_time } in yyyy-MM-ddTHH:mm:ss. null = no limit."
  type = object({
    from_time = optional(string)
    to_time   = optional(string)
  })
  default = null
}

variable "sia_access_window" {
  description = "Days (Sunday=0 to Saturday=6) and HH:MM hours when connections are allowed."
  type = object({
    days_of_the_week = set(number)
    from_hour        = string
    to_hour          = string
  })
  default = {
    days_of_the_week = [0, 1, 2, 3, 4, 5, 6]
    from_hour        = "00:00"
    to_hour          = "23:59"
  }

  validation {
    condition = (
      alltrue([for d in var.sia_access_window.days_of_the_week : d >= 0 && d <= 6]) &&
      can(regex("^([01][0-9]|2[0-3]):[0-5][0-9]$", var.sia_access_window.from_hour)) &&
      can(regex("^([01][0-9]|2[0-3]):[0-5][0-9]$", var.sia_access_window.to_hour))
    )
    error_message = "days_of_the_week must be 0-6 and from_hour/to_hour must be HH:MM."
  }
}

variable "sia_max_session_duration" {
  description = "Maximum session length, in hours."
  type        = number
  default     = 1
}

variable "sia_override_max_session_duration" {
  description = "true = use sia_max_session_duration; false = use the SIA global setting."
  type        = bool
  default     = true
}

variable "sia_idle_time" {
  description = "Idle time before the session ends, in minutes."
  type        = number
  default     = 10
}

variable "sia_override_idle_time" {
  description = "true = use sia_idle_time; false = use the SIA global setting."
  type        = bool
  default     = true
}

variable "sia_recording" {
  description = "Record sessions. Only applies when sia_override_recording is true."
  type        = bool
  default     = true
}

variable "sia_override_recording" {
  description = "true = use sia_recording; false = use the SIA global setting."
  type        = bool
  default     = false
}

variable "sia_access_approval" {
  description = "Dual control. When required is true, connections need approval from up to 5 approvers (empty = workspace delegates). Not available on every tenant."
  type = object({
    required = bool
    approvers = optional(list(object({
      id                    = string
      name                  = string
      type                  = string
      source_directory_id   = optional(string)
      source_directory_name = optional(string)
    })), [])
  })
  default = { required = false }

  validation {
    condition     = length(var.sia_access_approval.approvers) <= 5
    error_message = "sia_access_approval supports at most 5 approvers."
  }
}

variable "sia_additional_domain_groups" {
  description = "Other AD groups the ephemeral domain user joins on every server, on top of the per-server admin group."
  type        = list(string)
  default     = []
}

variable "sia_local_groups" {
  description = "Local groups the ephemeral domain user joins on the target (e.g. \"Remote Desktop Users\"). Usually empty, since the AD group already grants admin."
  type        = list(string)
  default     = []
}

variable "sia_ssh_username" {
  description = "SSH certificate username. The SIA API requires it on every VM policy; it has no effect on Windows/RDP connections."
  type        = string
  default     = "root"
}

variable "sia_enable_ephemeral_user_reconnect" {
  description = "Allow the ephemeral user to reconnect to a disconnected session."
  type        = bool
  default     = true
}
