# SharePoint Sites.Selected Checker

PowerShell scripts for provisioning, granting, revoking, and inspecting Microsoft Graph `Sites.Selected` site permissions. The scripts are exploratory and use different approaches; the certificate-based wizard is the most complete end-to-end workflow in this repository.

## How Sites.Selected Works

The target application must have the Microsoft Graph **application** permission `Sites.Selected`, with tenant admin consent. That permission alone grants access to no sites. A separate provisioning identity with `Sites.FullControl.All` grants the target application an explicit role on each selected site.

Use the narrowest site role that meets the workload's needs. The wizard defaults to `Read`; choose a broader role only when the workload requires it.

## Prerequisites

- Windows with PowerShell 7 or later.
- An Entra tenant and an account authorized to consent to the Graph permissions and create/update app registrations and service principals.
- Microsoft Graph PowerShell modules. The wizard's module setup code is commented out, so install the module before running it:

  ```powershell
  Install-Module Microsoft.Graph -Scope CurrentUser
  ```

- A real SharePoint Online site URL, for example `https://contoso.sharepoint.com/sites/Finance`.
- Approval for the provisioning identity's broad `Sites.FullControl.All` permission. Keep its certificate private and restrict access to the generated `certs` folder and exported PFX files.

The wizard requests these delegated Graph scopes: `Application.ReadWrite.All`, `AppRoleAssignment.ReadWrite.All`, `Directory.ReadWrite.All`, `Sites.FullControl.All`, and `Organization.Read.All`. Admin consent and appropriate directory roles may be required by your tenant.

## Recommended: Wizard Workflow

Run from the repository directory. The script prompts for the tenant, then offers the target and provisioner app display names shown below as editable defaults. Pass `-TenantId` instead when you want a repeatable run without that prompt.

```powershell
& ".\sites.selected wizard -adds Revoke.ps1" -DefaultRole Read
```

1. Complete the Microsoft Graph device sign-in shown in the console, using an account authorized for the requested scopes.
2. The script finds or creates two app registrations and their service principals:
   - Target app: `mysite SharePoint`, assigned Graph `Sites.Selected`.
   - Provisioner app: `Sites.Selected provisioning`, assigned Graph `Sites.FullControl.All`.
   Review the names and resulting app IDs in the run summary. Existing apps with these names are reused.
3. At the certificate menu, choose **1** to create and attach certificates for both apps. The script stores certificates in `certs` and writes a timestamped log in `logs`. The private keys are installed in the current user's certificate store.
4. If another system must use a certificate, choose **3** to export a PFX and enter a strong password when prompted. Protect the PFX and password as credentials. Choose **2** only when you need the public CER file; a CER does not contain the private key.
5. Answer **Y** to the grant prompt. Enter each real SharePoint site URL; a blank URL ends the list and no placeholder site is substituted. At the role prompt, enter `read`, `write`, `manage`, or `fullcontrol`; pressing Enter uses the configured `-DefaultRole`, which defaults to `Read`.
6. The script connects as the provisioning app certificate and creates the site-specific grant for the target app.
7. To revoke, answer **Y** at the revoke prompt and enter the site URLs. Review the listed permission IDs and roles, select individual numbers or `ALL`, then confirm. Revocation removes only the selected site permission objects; it does not delete either app registration or its tenant-level API permission.
8. Answer **Y** to the validation prompt to check the grants created during this run. If a grant is not visible yet, allow for Graph propagation and rerun validation.
9. Review the run summary and timestamped log under `logs`. Keep logs and certificate files in appropriately restricted storage.

The default certificate validity is two years. Plan certificate renewal and removal of expired credentials through your normal credential lifecycle process.

## Alternative: Grant an Existing App

Use [Grant-SitesSelected-Graph.ps1](Grant-SitesSelected-Graph.ps1) when the target app already exists and already has tenant-consented Graph `Sites.Selected`. With no arguments, it interactively asks for the tenant, site URL, target app ID/name, and role, then uses a delegated Graph connection with `Sites.FullControl.All`. It does not provision the app or create its certificate.

To be prompted for all values and preview the requested operation:

```powershell
& ".\Grant-SitesSelected-Graph.ps1" -DryRun
```

After checking the preview, rerun without `-DryRun` to apply the grant. You can also pass any of the prompted values as parameters. `-TestAccess` is optional and securely prompts for the target app's client secret if `-AppClientSecret` was not supplied; it lists drives and uploads a test file. Do not enable it unless you intend that write operation and have chosen an appropriate `-UploadPath`.

## Script Guide

| Script | Purpose and current limitations |
| --- | --- |
| [sites.selected wizard -adds Revoke.ps1](sites.selected%20wizard%20-adds%20Revoke.ps1) | Most complete flow: interactively prompts for tenant and app names, creates/reuses apps, attaches certificates, grants and revokes per-site access, and validates grants. Requires PowerShell 7, Graph modules, and delegated admin access. |
| [Grant-SitesSelected-Graph.ps1](Grant-SitesSelected-Graph.ps1) | Focused grant for an existing target app; interactively prompts for tenant/site/app/role when values are omitted, supports `-DryRun`, and optionally tests access. |
| [Add sites.selected to SP page and ServicePrince.ps1](Add%20sites.selected%20to%20SP%20page%20and%20ServicePrince.ps1) | Experimental one-shot app creation, Graph and SharePoint permission assignment, and site grant. It prompts for a Web ID but resolves the site independently; treat as an alternate implementation, not the recommended path. |
| [Get-sitesselected.ps1](Get-sitesselected.ps1) | Prompts for tenant, provisioner app ID/secret, site URL, and target app ID, then lists that target app's explicit permission grants. The provisioner app needs app-only Graph permission sufficient to read site permissions. |
| [live_dry_runner.ps1](live_dry_runner.ps1) | Input-stub runner for the wizard, but points to an absolute `C:\TEMP\ENTRA` script path and is not portable as checked in. |
| [smoke_check_harness.ps1](smoke_check_harness.ps1) | Mock-based smoke harness with the same hard-coded external script path; it is not a portable test of the checked-in wizard. |

## Credential Safety

Credential-like values were present in repository files. A client secret has been removed from `Get-sitesselected.ps1`, and the app-registration dump has been removed from this README. Treat any previously exposed secret as compromised: revoke/rotate it in Entra ID, check other copies and repository history, and avoid committing secrets, PFX files, or private keys. Removing a value from the current files does not remove it from existing Git history or copies.

## References

- [Selected permissions overview](https://learn.microsoft.com/graph/permissions-selected-overview)
- [Delete a site permission with Microsoft Graph](https://learn.microsoft.com/graph/api/site-delete-permission?view=graph-rest-1.0)
- [Remove-MgSitePermission](https://learn.microsoft.com/powershell/module/microsoft.graph.sites/remove-mgsitepermission?view=graph-powershell-1.0)
