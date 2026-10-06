function Read-RequiredInput {
    param([string]$Prompt)
    do {
        $value = (Read-Host $Prompt).Trim()
        if ([string]::IsNullOrWhiteSpace($value)) { Write-Warning "A value is required." }
    } while ([string]::IsNullOrWhiteSpace($value))
    $value
}

$TenantId = Read-RequiredInput "Enter tenant ID or verified domain"
$ClientId = Read-RequiredInput "Enter provisioner app client ID"
$CheckAppId = Read-RequiredInput "Enter target app client ID to inspect"
do {
    $SiteUrl = Read-RequiredInput "Enter SharePoint site URL (https://tenant.sharepoint.com/sites/name)"
    $siteUri = $null
    $validSiteUrl = [Uri]::TryCreate($SiteUrl, [UriKind]::Absolute, [ref]$siteUri) -and $siteUri.Scheme -eq 'https' -and $siteUri.Host.EndsWith('.sharepoint.com') -and $siteUri.AbsolutePath -ne '/'
    if (-not $validSiteUrl) { Write-Warning "Enter a complete HTTPS SharePoint Online site URL." }
} while (-not $validSiteUrl)
$clientSecretSecure = Read-Host "Enter provisioner app client secret" -AsSecureString
$secretBstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($clientSecretSecure)
$ClientSecret = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($secretBstr)

# ==========================================
# 1. Authenticate & Get Access Token
# ==========================================
Write-Host "Authenticating to Entra ID..." -ForegroundColor Cyan
$TokenUrl = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"
$TokenBody = @{
    client_id     = $ClientId
    client_secret = $ClientSecret
    scope         = "https://graph.microsoft.com/.default"
    grant_type    = "client_credentials"
}

try {
    $TokenResponse = Invoke-RestMethod -Uri $TokenUrl -Method Post -Body $TokenBody -ErrorAction Stop
    $Token = $TokenResponse.access_token
    $Headers = @{ Authorization = "Bearer $Token" }
} catch {
    Write-Error "Authentication failed. Please check your Tenant ID, Client ID, and Secret."
    exit
} finally {
    if ($secretBstr -and $secretBstr -ne [IntPtr]::Zero) {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($secretBstr)
    }
    $ClientSecret = $null
    $TokenBody.client_secret = $null
}

# ==========================================
# 2. Resolve SharePoint Site URL to Site ID
# ==========================================
Write-Host "Resolving Site ID for: $SiteUrl" -ForegroundColor Cyan
$Uri = [System.Uri]$SiteUrl
$HostName = $Uri.Host
$SitePath = $Uri.AbsolutePath

$SiteGraphUrl = "https://graph.microsoft.com/v1.0/sites/$HostName`:$SitePath"

try {
    $Site = Invoke-RestMethod -Uri $SiteGraphUrl -Headers $Headers -ErrorAction Stop
    $SiteId = $Site.id
    Write-Host "Found Site ID: $SiteId" -ForegroundColor Green
} catch {
    Write-Error "Failed to find the SharePoint site."
    exit
}
# ==========================================
# 3. List All Explicit Permissions
# ==========================================
Write-Host "Retrieving all explicit permissions for the site..." -ForegroundColor Cyan
$PermissionsUrl = "https://graph.microsoft.com/v1.0/sites/$SiteId/permissions"

try {
    $PermissionResponse = Invoke-RestMethod -Uri $PermissionsUrl -Headers $Headers -ErrorAction Stop
    $Permissions = @($PermissionResponse.value | Where-Object { $_.grantedToIdentitiesV2.application.id -contains $CheckAppId })
    
    if ($Permissions.Count -eq 0) {
        Write-Host "No explicit permissions found for app $CheckAppId on this site." -ForegroundColor Yellow
    } else {
        Write-Host "`n=================================================" -ForegroundColor Green
        Write-Host " GRANTED PERMISSIONS FOR SITE" -ForegroundColor Green
        Write-Host "=================================================" -ForegroundColor Green
        
        foreach ($perm in $Permissions) {
            $Roles = $perm.roles -join ", "
            $identities = $perm.grantedToIdentitiesV2

            foreach ($identity in $identities) {
                
                # --- APPLICATION ---
                if ($null -ne $identity.application) {
                    $AppName = $identity.application.displayName
                    $AppId   = $identity.application.id
                    Write-Host "[Application] Name: $AppName" -ForegroundColor White
                    Write-Host "              ID:   $AppId" -ForegroundColor DarkGray
                    Write-Host "              Role: $Roles`n" -ForegroundColor Yellow
                }
                
                # --- USER ---
                elseif ($null -ne $identity.user) {
                    $UserName = $identity.user.displayName
                    $UserId   = $identity.user.id
                    $Upn      = "Unknown"

                    # Make a secondary call to resolve the UPN from the Object ID
                    if ($UserId) {
                        try {
                            # %24 is the URL-encoded version of $ (prevents PowerShell variable issues)
                            $UserUrl = "https://graph.microsoft.com/v1.0/users/$UserId?%24select=userPrincipalName"
                            $UserObj = Invoke-RestMethod -Uri $UserUrl -Headers $Headers -ErrorAction Stop
                            $Upn = $UserObj.userPrincipalName
                        } catch {
                            $Upn = "Could not resolve UPN (User may be deleted or external)"
                        }
                    }

                    Write-Host "[User] Name: $UserName" -ForegroundColor Cyan
                    Write-Host "       UPN:  $Upn" -ForegroundColor Gray
                    Write-Host "       Role: $Roles`n" -ForegroundColor Yellow
                }
                
                # --- GROUP ---
                elseif ($null -ne $identity.group) {
                    $GroupName = $identity.group.displayName
                    $GroupId   = $identity.group.id
                    Write-Host "[Group] Name: $GroupName" -ForegroundColor Magenta
                    Write-Host "        ID:   $GroupId" -ForegroundColor Gray
                    Write-Host "        Role: $Roles`n" -ForegroundColor Yellow
                }
            }
        }
        Write-Host "=================================================`n" -ForegroundColor Green
    }

} catch {
    Write-Error "Failed to retrieve site permissions."
}
