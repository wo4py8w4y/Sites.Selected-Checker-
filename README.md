# Sites.Selected-Checker-
Powershell to add and/or validate specific sites.selected permissions exist for user objects
Using powershell MSGraph module it will ask you to enter the sharepoint URL to check and then enumerate the permisisons and/or add permissiolns
you must authenticate using an applicaiton registration with the api permissions to MSGraph with sites.fullaccess with Application delgation.
```Codeblock
"displayName": "Sites.Selected provisioning",
	"description": null,
	"groupMembershipClaims": null,
	"identifierUris": [],
	"isDeviceOnlyAuthSupported": null,
	"isDisabled": null,
	"isFallbackPublicClient": null,
	"nativeAuthenticationApisEnabled": null,
	"notes": "This app registration can be utilised to apply the permission sites.selected using the appropriate script.
	"serviceManagementReference": null,
	"signInAudience": "AzureADMyOrg",
	"tags": [],
	"tokenEncryptionKeyId": null,
	"samlMetadataUrl": null,
	"defaultRedirectUri": null,
	"certification": null,
	"optionalClaims": null,
	"servicePrincipalLockConfiguration": null,
	"requestSignatureVerification": null,
	"addIns": [],
	"api": {
		"acceptMappedClaims": null,
		"knownClientApplications": [],
		"requestedAccessTokenVersion": null,
		"oauth2PermissionScopes": [],
		"preAuthorizedApplications": []
	},
	"appRoles": [],
	"info": {
		"logoUrl": "https://aadcdn.msftauthimages.net/81d6b03a-glbkmzkvdhgzhdl1-a-6gg5xj0of3-vocm8enm2wrva/appbranding/mdgjmbd6esaqnfzktacb-cuf6cvwcsow4acmk7buwpm/1033/bannerlogo?ts=639088285881977531",
		"marketingUrl": null,
		"privacyStatementUrl": null,
		"supportUrl": null,
		"termsOfServiceUrl": null
	},
	"keyCredentials": [
		{
			"customKeyIdentifier": "2253490CFFDAF53CC2C8F0C8FAC6322394E2E96A",
				"endDateTime": "2027-03-10T04:43:45Z",
			"key": null,
			"keyId": "db0ed6a8-3ae1-4150-ab57-ddddd398ce70",
			"startDateTime": "2026-03-10T04:43:45Z",
			"type": "AsymmetricX509Cert",
			"usage": "Verify"
		},
		{
			"customKeyIdentifier": "54B22D7AD8DDFBAAD57D9DA7A9CF839169333C36",
			"displayName": "CN=Sites.Selected provisioning",
			"endDateTime": "2028-03-11T12:14:09Z",
			"key": null,
			"keyId": "d61c2d01-7127-4046-a67b-bd60287b8000",
			"startDateTime": "2026-03-11T12:04:09Z",
			"type": "AsymmetricX509Cert",
			"usage": "Verify"
		}
	],
	"parentalControlSettings": {
		"countriesBlockedForMinors": [],
		"legalAgeGroupRule": "Allow"
	},
	"passwordCredentials": [
		{
			"customKeyIdentifier": null,
			"displayName": "Password uploaded on Tue Jun 23 2026",
			"endDateTime": "2026-12-20T07:50:01.108Z",
			"hint": "Qfh",
			"keyId": "8e5635cb-8897-4139-9fbc-2800d08ed396",
			"secretText": null,
			"startDateTime": "2026-06-23T07:50:01.108Z"
		},
		{
			"customKeyIdentifier": null,
			"displayName": "Password uploaded on Wed Mar 18 2026",
			"endDateTime": "2026-06-16T06:18:34.427Z",
			"hint": "c-G",
			"keyId": "df42a0f3-02a4-4c9f-8c12-a5b94a9d0328",
			"secretText": null,
			"startDateTime": "2026-03-18T06:18:34.427Z"
		}
	],
	"publicClient": {
		"redirectUris": []
	},
	"requiredResourceAccess": [
		{
			"resourceAppId": "00000003-0000-0000-c000-000000000000",
			"resourceAccess": [
				{
					"id": "a82116e5-55eb-4c41-a434-62fe8a61c773",
					"type": "Role"
				}
			]
		}
	],
	"verifiedPublisher": {
		"displayName": null,
		"verifiedPublisherId": null,
		"addedDateTime": null
	},
	"web": {
		"homePageUrl": null,
		"logoutUrl": null,
		"redirectUris": [],
		"implicitGrantSettings": {
			"enableAccessTokenIssuance": false,
			"enableIdTokenIssuance": false
		},
		"redirectUriSettings": []
	},
	"spa": {
		"redirectUris": []
	}
}jeZokqyy2Vq@57nB
