<#
.SYNOPSIS
    Installs and updates Microsoft.UI.XAML
.DESCRIPTION
	Installs Microsoft.UI.XAML if not detected at all,
    or updates if the subversion detected are old.
    ⚠️This is normally only necessary on Windows Server and Windows Sandbox.
    ⚠️Winget and Windows Terminal will not run without Microsoft.UI.XAML
    ⚠️Both versions 2.7 and 2.8 are necessary
    
    🪟Deployment tested on:
        - ✅Windows Sandbox
        - ✅Windows Server 2019
        - ✅Windows Server 2022
        - ✅Windows Server 2022 vNext (Windows Server 2025)
.PARAMETER BypassChocolatey
    (Optional)
    By default disabled. If Chocolatey is installed on the system,
    Chocolatey will be used to install/update Microsoft.UI.XAML.
    If Chocolatey is not present, this parameter has no effect.
    If Chocolatey is installed but Chocolatey install fails for
    whatever reason, the manual install will occur as if the bypass
    was activated.
    ⚠️Currently only version 2.7 is avialable on Chocolatey.
.EXAMPLE
    PS> ./Deploy_Microsoft_UI_XAML
.LINK
	https://github.com/gabrielvanca/Microsoft.UI.XAML
.NOTES
	Author: Gabriel Vanca
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $False)] [Switch]$BypassChocolatey = $False,
    [Parameter(Mandatory = $False)] [Switch]$ForceReinstall = $False
)

[String]$VersionToLookFor = "14.0.30704.0"


#Requires -RunAsAdministrator

# Force use of TLS 1.2 for all downloads.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


$windowsVersion = [Environment]::OSVersion.Version
if ($windowsVersion.Major -lt "10") {
    throw "This package requires a minimum of Windows 10 / Server 2019."
}

# .appx is only  supported on Windows 10 version 1709 and later - https://learn.microsoft.com/en-us/windows/msix/supported-platforms
# See https://en.wikipedia.org/wiki/Windows_10_version_history for build numbers
if ($windowsVersion.Build -lt "16299") {
    throw "This package requires a minimum of Windows 10 / Server 2019 version 1709 / OS build 16299."
}



Write-Host "Checking Microsoft UI XAML status" -ForegroundColor DarkYellow

[String]$UIXAML_VersionToLookFor = "7.2208.15002.0"
$UIXAML_List = Get-AppxPackage Microsoft.UI.Xaml.2.7 | Where-Object version -ge $UIXAML_VersionToLookFor
if([string]::IsNullorEmpty($UIXAML_List)) {
    Write-Host "Microsoft.UI.Xaml version missing" -ForegroundColor DarkMagenta
    Write-Host "Initialising install of Microsoft.UI.Xaml" -ForegroundColor DarkYellow

    $WebClient = New-Object System.Net.WebClient
    # https://github.com/microsoft/microsoft-ui-xaml/releases?q=xaml&expanded=true
    $fileURL = "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.7.3/Microsoft.UI.Xaml.2.7.x64.appx"
    $fileDownloadLocalPath = "$env:Temp\Microsoft.UI.Xaml.2.7.x64.appx"
    $WebClient.DownloadFile($fileURL, $fileDownloadLocalPath)

    # Installing the component
    Add-AppxPackage $fileDownloadLocalPath 
    # Removing installation file
    Remove-Item $fileDownloadLocalPath 

    $UIXAML_List = Get-AppxPackage Microsoft.UI.Xaml.2.7 | Where-Object version -ge $UIXAML_VersionToLookFor
    if([string]::IsNullorEmpty($UIXAML_List)) {
        Write-Error "Microsoft UI Xaml installation failed."
    } else {
        Write-Host "Microsoft UI Xaml installed successfully" -ForegroundColor DarkGreen
    }
} else {
    Write-Host "Microsoft.UI.Xaml.2.7 present" -ForegroundColor DarkGreen
}

$UIXAML_VersionToLookFor = "8.2306.22001.0"
$UIXAML_List = Get-AppxPackage Microsoft.UI.Xaml.2.8 | Where-Object version -ge $UIXAML_VersionToLookFor
if([string]::IsNullorEmpty($UIXAML_List)) {
    Write-Host "Microsoft.UI.Xaml version missing" -ForegroundColor DarkMagenta
    Write-Host "Initialising install of Microsoft.UI.Xaml" -ForegroundColor DarkYellow

    $WebClient = New-Object System.Net.WebClient
    # https://github.com/microsoft/microsoft-ui-xaml/releases?q=xaml&expanded=true
    $fileURL = "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.5/Microsoft.UI.Xaml.2.8.x64.appx"
    $fileDownloadLocalPath = "$env:Temp\Microsoft.UI.Xaml.2.8.x64.appx"
    $WebClient.DownloadFile($fileURL, $fileDownloadLocalPath)

    # Installing the component
    Add-AppxPackage $fileDownloadLocalPath 
    # Removing installation file
    Remove-Item $fileDownloadLocalPath 

    $UIXAML_List = Get-AppxPackage Microsoft.UI.Xaml.2.8 | Where-Object version -ge $UIXAML_VersionToLookFor
    if([string]::IsNullorEmpty($UIXAML_List)) {
        Write-Error "Microsoft UI Xaml installation failed."
    } else {
        Write-Host "Microsoft UI Xaml installed successfully" -ForegroundColor DarkGreen
    }
} else {
    Write-Host "Microsoft.UI.Xaml.2.8 present" -ForegroundColor DarkGreen
}
