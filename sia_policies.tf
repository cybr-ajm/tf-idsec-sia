# ---------------------------------------------------------------------------
# One SIA VM policy per Windows server.
#
# Pattern: each server <machine> has an AD group "<sia_group_prefix><machine>"
# nested in its local Administrators group. The policy targets that one machine
# and has SIA's ephemeral domain user put in that AD group for the session, so
# whoever connects through the policy is a local admin on that server only.
# ---------------------------------------------------------------------------

locals {
  sia_policies = {
    for machine, s in var.sia_servers : machine => {
      machine     = machine
      group_name  = coalesce(s.group_name, "${var.sia_group_prefix}${machine}")
      domain      = try(coalesce(s.domain, var.sia_domain), null)
      policy_name = coalesce(s.policy_name, format(var.sia_policy_name_format, machine))
      description = substr(coalesce(
        s.description,
        "Local admin on ${machine} via AD group ${coalesce(s.group_name, "${var.sia_group_prefix}${machine}")}"
      ), 0, 200)
      principals  = concat(s.principals != null ? s.principals : var.sia_principals, s.additional_principals)
      policy_tags = distinct(concat(var.sia_policy_tags, s.policy_tags))
      status      = coalesce(s.status, var.sia_policy_status)
      time_frame  = s.time_frame != null ? s.time_frame : var.sia_time_frame
    }
  }

  # Dual control is optional and not on every tenant; only send the block when it's turned on.
  sia_access_approval = var.sia_access_approval.required ? {
    required = true
    approvers = [for a in var.sia_access_approval.approvers : {
      id                    = a.id
      name                  = a.name
      type                  = a.type
      source_directory_id   = a.source_directory_id
      source_directory_name = a.source_directory_name
    }]
  } : null
}

resource "idsec_policy_vm" "server_admin" {
  for_each = local.sia_policies

  delegation_classification = var.sia_delegation_classification

  metadata = {
    name        = each.value.policy_name
    description = each.value.description
    policy_entitlement = {
      target_category = "VM"
      location_type   = "FQDN/IP"
      policy_type     = var.sia_policy_type
    }
    policy_tags = length(each.value.policy_tags) > 0 ? each.value.policy_tags : null
    status      = { status = each.value.status }
    time_frame  = each.value.time_frame
    time_zone   = var.sia_time_zone
  }

  principals = [for p in each.value.principals : {
    id                    = p.id
    name                  = p.name
    type                  = p.type
    source_directory_id   = p.source_directory_id
    source_directory_name = p.source_directory_name
  }]

  targets = {
    fqdnip_resource = {
      fqdn_rules = [{
        operator             = "EXACTLY"
        computername_pattern = each.value.machine
        domain               = each.value.domain
      }]
    }
  }

  behavior = {
    rdp_profile = {
      domain_ephemeral_user = {
        assign_domain_groups            = distinct(concat([each.value.group_name], var.sia_additional_domain_groups))
        assign_groups                   = var.sia_local_groups # API requires a list, even if empty
        enable_ephemeral_user_reconnect = var.sia_enable_ephemeral_user_reconnect
      }
    }
    # The API requires an SSH profile on every VM policy; it is unused for Windows/RDP targets.
    ssh_profile = {
      username = var.sia_ssh_username
    }
  }

  conditions = {
    access_window                 = var.sia_access_window
    max_session_duration          = var.sia_max_session_duration
    override_max_session_duration = var.sia_override_max_session_duration
    idle_time                     = var.sia_idle_time
    override_idle_time            = var.sia_override_idle_time
    recording                     = var.sia_recording
    override_recording            = var.sia_override_recording
    access_approval               = local.sia_access_approval
  }
}
