function Get-GraphApi {
 param (
 [parameter(Mandatory=$true)]
 $ClientID,

[parameter(Mandatory=$true)]
 $ClientSecret,

[parameter(Mandatory=$true)]
 $TenantName,

[parameter(Mandatory=$true)]
 $Url
 )


 # Graph API URLs.
 $LoginUrl = "https://login.microsoft.com"
 $RresourceUrl = "https://graph.microsoft.com"
 
 
 # Compose REST request.
 $Body = @{ grant_type = "client_credentials"; resource = $RresourceUrl; client_id = $ClientID; client_secret = $ClientSecret }
 $OAuth = Invoke-RestMethod -Method Post -Uri $LoginUrl/$TenantName/oauth2/token?api-version=1.0 -Body $Body
 
 
 # Check if authentication is successful.
 if ($OAuth.access_token -eq $null)
 {
 Write-Error "No Access Token"
 }
 else
 {
 # Perform REST call.
 $HeaderParams = @{ 'Authorization' = "$($OAuth.token_type) $($OAuth.access_token)" }
 $Result = (Invoke-WebRequest -UseBasicParsing -Headers $HeaderParams -Uri $Url)

# Return result.
 $Result
 }
}

function Get-UsageReportData {
 param (
 [parameter(Mandatory = $true)]
 [string]$ClientID,

[parameter(Mandatory = $true)]
 [string]$ClientSecret,

[parameter(Mandatory = $true)]
 [string]$TenantName,
 
 [parameter(Mandatory=$true)]
 $GraphUrl
 )
try {
 # Call Microsoft Graph and extract CSV content and convert data to PowerShell objects.
 ((Get-GraphApi -ClientID $ClientID -ClientSecret $ClientSecret -TenantName $TenantName -Url $GraphUrl).RawContent -split "\?\?\?")[1] | ConvertFrom-Csv
 }
 catch {
 $null
 }
}

$ClientID = "" # You registered apps App ID.
$ClientSecret = "" # Your registered apps key.
$TenantName = "" # Your tenant name.
$GraphUrl = "https://graph.microsoft.com/v1.0/reports/getSkypeForBusinessDeviceUsageUserDetail(period='D180')" # The Graph URL to retrieve data.




$UsageData = Get-UsageReportData -ClientID $ClientID -ClientSecret $ClientSecret -TenantName $TenantName -GraphUrl $GraphUrl
$UsageData | export-csv C:\Temp\SkypeForBusinessDeviceUsageU180day.csv

