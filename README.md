# CyberArk SIA server admin policies with Terraform

Creates one CyberArk Secure Infrastructure Access (SIA) VM policy per Windows server, using the `cyberark/idsec` provider.

For each server `<machine>` there is an AD group `<sia_group_prefix><machine>` nested in that server's local Administrators group. The policy targets only that machine, and SIA's ephemeral domain user is put in that AD group for the session. Whoever connects through the policy is a local admin on that one server.

The Idira API credential is not stored in Terraform. It is retrieved at plan/apply time from CyberArk Central Credential Provider (CCP) by the module in [modules/ccp-credential](modules/ccp-credential).

## Files

| File | Purpose |
|---|---|
| `versions.tf` | Terraform and provider versions |
| `ccp.tf` | Gets the Idira credential from CCP |
| `main.tf` | `idsec` provider configuration and a connectivity check |
| `sia_policies.tf` | One `idsec_policy_vm` per server |
| `variables.tf` | CCP and Idira inputs |
| `sia_variables.tf` | SIA policy inputs |
| `outputs.tf` | Policy IDs and names per server |
| `terraform.tfvars.example` | Example values to copy |

## Usage

```sh
cp terraform.tfvars.example terraform.tfvars   # then edit with your values
terraform init
terraform plan
terraform apply
```

## Requirements

- A CCP application ID with access to the safe holding the Idira service user credential (platform `CyberArkIdentityServiceUser`, where the login is in `KeyID`).
- If CCP uses client certificate authentication, the IIS binding must request the certificate during the initial TLS handshake (`clientcertnegotiation=enable`), because Go does not support renegotiation.
- The per-server AD groups exist and are nested in each server's local Administrators group.

## Notes

- `terraform.tfvars`, state files, and certificates are git-ignored. Don't commit them: state contains the credential retrieved from CCP.
- Dual control (`sia_access_approval`) is not available on every tenant.
