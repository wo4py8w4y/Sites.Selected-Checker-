# ==========================================
# Configuration (Maps to appsettings.json)
# ==========================================
$TenantId = "enter your own tennantID"
$ClientId = "enter your clientid"
$ClientSecret = "Qfh8Q~VWjYkvw_EQSwM1rYKV62bH7fbCqUZWDbxq"
$CheckAppId = "APP_ID_TO_CHECK_FOR_ACCESS"
#

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
    $Permissions = Invoke-RestMethod -Uri $PermissionsUrl -Headers $Headers -ErrorAction Stop
    
    if ($Permissions.value.Count -eq 0) {
        Write-Host "No explicit permissions found for this site." -ForegroundColor Yellow
    } else {
        Write-Host "`n=================================================" -ForegroundColor Green
        Write-Host " GRANTED PERMISSIONS FOR SITE" -ForegroundColor Green
        Write-Host "=================================================" -ForegroundColor Green
        
        foreach ($perm in $Permissions.value) {
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
