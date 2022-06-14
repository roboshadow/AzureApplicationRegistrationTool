function Load-Az-Module() {
    if (-not(Get-InstalledModule Az -ErrorAction silentlycontinue)) {
        try {
            Write-Host "Installing Az Module..."
            Install-Module -Name Az -AllowClobber -Repository PSGallery -Force -ErrorAction Inquire
            Import-Module Az
        }
        catch {
            Write-Host "Error Installing Module - Antivirus or Permissions may be blocking this script. Please try installing manually if errors continue, 'Install-Module -Name Az'"
        }
    }
    else {
        try {
            Write-Host "Importing Az Module..."
            Import-Module Az -ErrorAction Inquire
        }
        catch {
            Write-Host "Error Importing Module - Antivirus or Permissions may be blocking this script."
        }
    }
}

function Check-Existing-Application($appName) {
    Write-Host "Checking if Application already exists..."

    if ($existingApp = Get-AzADApplication -Filter "DisplayName eq '$($appName)'") {
        $warningMessage = "Azure App Registration already exists, would you like to replace? [y/n]"
        $input = Read-Host -Prompt $warningMessage

        while($input -ne "y")
        {
            if ($input -eq 'n') {
                Return $true
            }
        
            $input = Read-Host -Prompt $warningMessage
        }

        Get-AzADApplication -Filter "DisplayName eq '$($appName)'" | Remove-AzADApplication
        Return $false
    }

    Return $false
}

function Create-Robo-Application($appName) {
    Write-Host "Creating new Application..." -NoNewline

    $roboApp = New-AzADApplication -DisplayName $appName -ReplyUrls @("https://portal.roboshadow.com/")
    Start-Sleep -Seconds 1

    Write-Host " Done"

    return $roboApp.Id, $roboApp.AppId
}

function Create-Robo-Secret($clientId) {
    Write-Host "Creating Secret Key..." -NoNewline

    $dateToday = Get-Date
    $roboSecret = New-AzADAppCredential -ObjectId $clientId -StartDate $dateToday -EndDate $dateToday.AddYears(2)
    Start-Sleep -Seconds 1

    Write-Host " Done"

    return $roboSecret.SecretText
}

function Add-Robo-Permissions($clientId) {
    Write-Host "Adding Permissions to Application..." -NoNewline

    # Permission Reference - https://docs.microsoft.com/en-us/graph/permissions-reference
    $permissions = @{}
    $permissions.Add("AuditLog.Read.All", "b0afded3-3588-46d8-8b3d-9842eff778da");
    $permissions.Add("Device.ReadWrite.All", "1138cb37-bd11-4084-a2b7-9f71582aeddb");
    $permissions.Add("Directory.ReadWrite.All", "19dbc75e-c2e2-444c-a770-ec69d8559fc7");
    $permissions.Add("MailboxSettings.ReadWrite", "6931bccd-447a-43d1-b442-00a195474933");
    $permissions.Add("Reports.Read.All", "230c1aed-a721-4c5d-9cb4-a90514e508ef");
    $permissions.Add("RoleManagement.Read.All", "c7fbd983-d9aa-4fa7-84b8-17382c103bc4");
    $permissions.Add("RoleManagement.Read.Directory", "483bed4a-2ad3-4361-a73b-c83ccdbdc53c");
    $permissions.Add("User.ReadWrite.All", "741f803b-c850-494e-b5df-cde7c675a1ca");
    $permissions.Add("UserAuthenticationMethod.Read.All", "38d9df27-64da-44fd-b7c5-a6fbac20248f");

    $graphApiId = "00000003-0000-0000-c000-000000000000"

    foreach ($id in $permissions.Values) {
        Add-AzADAppPermission -ObjectId $clientId -ApiId $graphApiId -PermissionId $id -Type Role
    }

    Write-Host " Done"
}

function Consent-Robo-Permissions($tenantId, $appId) {
    Start-Sleep -Seconds 5
    Write-Host "Waiting for App Creation, admin consent required. (A new window will be opened in 2 minutes)"
    Start-Sleep -Seconds 120

    Invoke-Expression "cmd.exe /C start https://login.microsoftonline.com/'$($tenantId)'/adminconsent?client_id='$($appId)'"
}

If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
  # Relaunch as an elevated process
  Start-Process powershell.exe "-File",('"{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
  exit
}

Load-Az-Module

Write-Host "Global Administrator sign-in required."
Connect-AzAccount -WarningAction Inquire | Out-Null
($tenant = Get-AzTenant) | Out-Null

$appName = "RoboshadowAdSync"
$tenantId = $tenant.Id

if (Check-Existing-Application -appName $appName) {exit}

$clientDetails = Create-Robo-Application -appName $appName
$clientId = $clientDetails[0]
$appId = $clientDetails[1]
$clientSecret = Create-Robo-Secret -clientId $clientId

Add-Robo-Permissions -clientId $clientId
Consent-Robo-Permissions -tenantId $tenantId -appId $appId

Write-Host "----------------------------------------------------"
Write-Host "Tenant Id: '$($tenantId)'"
Write-Host "Client Id: '$($appId)'"
Write-Host "Client Secret: '$($clientSecret)'"
Write-Host "----------------------------------------------------"
$input = Read-Host -Prompt "Please type 'confirm' to exit, or close window"

while($input -ne "confirm")
{
    if ($input -eq 'n') {
        {exit}
    }
        
    $input = Read-Host -Prompt "Please type 'confirm' to exit, or close window"
}
