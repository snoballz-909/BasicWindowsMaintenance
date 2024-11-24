# .\WindowsMaintenance.ps1
# Author: snoballz-909
# Date: 21/11/24

# Description:
# A simple PowerShell script to perform basic maintenance tasks with hardware checks along with the cleanup of redundant files and a Windows Update.
# This script will perform the following tasks:
# 1. Disk Storage Check which will warn when C drive is over 80% usage.
# 2. RAM Check will query how many slots are in use and warn if there is less than 2GB of available memory.
# 3. Perform a System File Check scan to repair courrupt system files.
# 4. Launch Reliability Monitor to manually check for reoccuring application faults.
# 5. Clear browser data will clear browser data such as Cookies, Cache and History from Edge, Chrome, Firfox and Brave.
# 6. Perform a Windows Update by first installing the NuGet package manager to then install PSWindowsUpdate to perform the Windows Update.

$asciiArt = @"

░██╗░░░░░░░██╗██╗███╗░░██╗██████╗░░█████╗░░██╗░░░░░░░██╗░██████╗
░██║░░██╗░░██║██║████╗░██║██╔══██╗██╔══██╗░██║░░██╗░░██║██╔════╝
░╚██╗████╗██╔╝██║██╔██╗██║██║░░██║██║░░██║░╚██╗████╗██╔╝╚█████╗░
░░████╔═████║░██║██║╚████║██║░░██║██║░░██║░░████╔═████║░░╚═══██╗
░░╚██╔╝░╚██╔╝░██║██║░╚███║██████╔╝╚█████╔╝░░╚██╔╝░╚██╔╝░██████╔╝
░░░╚═╝░░░╚═╝░░╚═╝╚═╝░░╚══╝╚═════╝░░╚════╝░░░░╚═╝░░░╚═╝░░╚═════╝░

███╗░░░███╗░█████╗░██╗███╗░░██╗████████╗███████╗███╗░░██╗░█████╗░███╗░░██╗░█████╗░███████╗
████╗░████║██╔══██╗██║████╗░██║╚══██╔══╝██╔════╝████╗░██║██╔══██╗████╗░██║██╔══██╗██╔════╝
██╔████╔██║███████║██║██╔██╗██║░░░██║░░░█████╗░░██╔██╗██║███████║██╔██╗██║██║░░╚═╝█████╗░░
██║╚██╔╝██║██╔══██║██║██║╚████║░░░██║░░░██╔══╝░░██║╚████║██╔══██║██║╚████║██║░░██╗██╔══╝░░
██║░╚═╝░██║██║░░██║██║██║░╚███║░░░██║░░░███████╗██║░╚███║██║░░██║██║░╚███║╚█████╔╝███████╗
╚═╝░░░░░╚═╝╚═╝░░╚═╝╚═╝╚═╝░░╚══╝░░░╚═╝░░░╚══════╝╚═╝░░╚══╝╚═╝░░╚═╝╚═╝░░╚══╝░╚════╝░╚══════╝

"@

Write-Host $asciiArt -ForegroundColor Magenta

# Set error handling
$ErrorActionPreference = "Stop"

@"
`r
 --------------------------------------------------------------------------------------------------
|################################# - DISK STORAGE CHECK - #########################################|
 --------------------------------------------------------------------------------------------------
`r
"@
# Begin disk storage check
Write-Output "Checking C drive storage usage..."

# Get C drive details
$cDrive = Get-PSDrive -Name C
$usedSpaceGB = [math]::Round(($cDrive.Used / 1GB), 2)
$totalSpaceGB = [math]::Round(($cDrive.Free + $cDrive.Used) / 1GB, 2)
$usedPercentage = [math]::Round(($cDrive.Used / ($cDrive.Free + $cDrive.Used)) * 100, 2)

Write-Output "C:\ Drive Usage: $usedSpaceGB GB used out of $totalSpaceGB GB ($usedPercentage% full)"

# Check if disk is at more than 80% capacity
if ($usedPercentage -gt 80) {
    Write-Host "++++++ WARNING: Your C:\ drive is more than 80% full! ++++++" -ForegroundColor Red
    Write-Host "****** Delete unused files and unnecessary apps! ******" -ForegroundColor Cyan
} else {
    Write-Host "====== C:\ drive storage is under control ======" -ForegroundColor Green
}

@"
`r
 --------------------------------------------------------------------------------------------------
|#################################### - RAM CHECK - ###############################################|
 --------------------------------------------------------------------------------------------------
`r
"@

# Checks for RAM slots in use, the most commonly utilized RAM set-up is 2 slots in use
Write-Output "Checking RAM slots in use..."
$ramSlots = Get-CimInstance -ClassName Win32_PhysicalMemory
$slotsInUse = $ramSlots.Count
Write-Host "Number of RAM slots in use: $slotsInUse" -ForegroundColor Yellow

if ($slotsInUse -lt 2) {
    Write-Host "++++++ WARNING: You are only utilizing 1 RAM slot! ++++++" -ForegroundColor Red
    Write-Host "****** Should you be utilizing Dual Channel memory? ******" -ForegroundColor Cyan
} else {
    Write-Host "====== RAM slot check complete ======" -ForegroundColor Green
}

# Check total and available physical memory
Write-Output "Checking physical memory details..."
$memoryInfo = Get-CimInstance -ClassName Win32_OperatingSystem
$totalMemoryGB = [math]::Round($memoryInfo.TotalVisibleMemorySize / 1MB, 2)
$availableMemoryGB = [math]::Round($memoryInfo.FreePhysicalMemory / 1MB, 2)

Write-Output "Total Physical Memory: $totalMemoryGB GB"
Write-Host "Available Physical Memory: $availableMemoryGB GB" -ForegroundColor Yellow

# If needed, provide a warning for low memory
if ($availableMemoryGB -lt 2) {
    Write-Host "++++++ WARNING: Available physical memory is less than 2 GB! ++++++" -ForegroundColor Red
} else {
    Write-Host "====== Physical memory usage is sufficient ======" -ForegroundColor Green
}

@"
`r
 --------------------------------------------------------------------------------------------------
|############################### - System File Check Scan - #######################################|
 --------------------------------------------------------------------------------------------------
`r
"@

# System File Checker scan to identify and replace courrupt system files
Write-Output "Running System File Checker (sfc /scannow)..."

# Run the command
Start-Process -FilePath "cmd.exe" -ArgumentList "/c sfc /scannow" -Wait
Write-Host "Output from scan is saved at C:\Windows\Logs\CBS\CBS.log" -ForegroundColor Yellow

Write-Host "====== System File Checker scan completed ======" -ForegroundColor Green

@"
`r
 --------------------------------------------------------------------------------------------------
|################################## - Disk Clean Up -##############################################|
 --------------------------------------------------------------------------------------------------
`r
"@

# Disk Cleanup setting parameters
Write-Output "Setting Disk Cleanup Parameters..."
Write-Host "****** Tick all boxes and press OK under Disk Clean-Up Settings pop-up ******" -ForegroundColor Cyan
Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sageset:1" -Wait
Write-Output "Disk Cleanup Parameters Set..."

# Disk Cleanup process
Write-Output "Starting Disk Cleanup..."
Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sagerun:1" -Wait
Write-Host "====== Disk Cleanup completed ======" -ForegroundColor Green

@"
`r
 --------------------------------------------------------------------------------------------------
|############################### - Reliability Monitor - ##########################################|
 --------------------------------------------------------------------------------------------------
`r
"@

# Launch Reliability Monitor to analyse for Critical events
Write-Output "Launching Reliability Monitor..."
Start-Process -FilePath "perfmon.exe" -ArgumentList "/rel"
Write-Host "****** Check Reliability Monitor for Critical events ******" -ForegroundColor Cyan

@"
`r
 --------------------------------------------------------------------------------------------------
|############################### - Clear Browser Data - ###########################################|
 --------------------------------------------------------------------------------------------------
`r
"@

Write-Output "Starting browser data cleanup..."

# Searching for chrome process and stopping it from running
$chromeprocess = Get-Process -Name "chrome" -ErrorAction SilentlyContinue
if ($chromeprocess) {
    Write-Host "Chrome process is running! Attempting to close..." -ForegroundColor Yellow
    Stop-Process -Name "chrome" -Force
} else {
    Write-Host "Chrome process not running..."
}

# Searching for msedge process and stopping it from running
$edgeprocess = Get-Process -Name "msedge" -ErrorAction SilentlyContinue
if ($edgeprocess) {
    Write-Host "Edge process is running! Attempting to close..." -ForegroundColor Yellow
    Stop-Process -Name "msedge" -Force
    Start-Sleep -Seconds 2
} else {
    Write-Host "Edge process not running..."
}

# Searching for firefox process and stopping it from running
$firefoxprocess = Get-Process -Name "firefox" -ErrorAction SilentlyContinue
if ($firefoxprocess) {
    Write-Host "Firefox process is running! Attempting to close..." -ForegroundColor Yellow
    Stop-Process -Name "firefox" -Force
} else {
    Write-Host "Firefox process not running..."
}

# Searching for brave process and stopping it from running
$braveprocess = Get-Process -Name "brave" -ErrorAction SilentlyContinue
if ($braveprocess) {
    Write-Host "Brave process is running! Attempting to close..." -ForegroundColor Yellow
    Stop-Process -Name "brave" -Force
} else {
    Write-Host "Brave process not running..."
}

# Setting variables for Chrome data locations
Write-Output "Clearing Google Chrome data..."
$chromeCache = "$env:LocalAppData\Google\Chrome\User Data\Default\Cache"
$chromeCookies = "$env:LocalAppData\Google\Chrome\User Data\Default\Network\Cookies"
$chromeHistory = "$env:LocalAppData\Google\Chrome\User Data\Default\History"

if (Test-Path $chromeCache) {
    Remove-Item -Path $chromeCache -Recurse -Force
}
if (Test-Path $chromeCookies) {
    Remove-Item -Path $chromeCookies -Force
}
if (Test-Path $chromeHistory) {
    Remove-Item -Path $chromeHistory -Force
}

# Setting variables for Edge data locations
Write-Output "Clearing Microsoft Edge data..."
$edgeCache = "$env:LocalAppData\Microsoft\Edge\User Data\Default\Cache"
$edgeCookies = "$env:LocalAppData\Microsoft\Edge\User Data\Default\Network\Cookies"
$edgeHistory = "$env:LocalAppData\Microsoft\Edge\User Data\Default\History"

if (Test-Path $edgeCache) {
    Remove-Item -Path $edgeCache -Recurse -Force
}
if (Test-Path $edgeCookies) {
    Remove-Item -Path $edgeCookies -Force
}
if (Test-Path $edgeHistory) {
    Remove-Item -Path $edgeHistory -Force
}

# Start the process of clearing Firefox browser data
Write-Output "Clearing Mozilla Firefox data..."

# Check if AppData path exists before getting the profile
if (Test-Path "$env:AppData\Mozilla\Firefox\Profiles") {
    $firefoxProfilePath = (Get-ChildItem "$env:AppData\Mozilla\Firefox\Profiles" -Directory | Where-Object { $_.Name -like "*default-release*" } | Select-Object -First 1).FullName
} else {
    Write-Output "Firefox AppData path does not exist, skipping..."
}

# Check if LocalAppData path exists before getting the profile
if (Test-Path "$env:LocalAppData\Mozilla\Firefox\Profiles") {
    $firefoxProfilePath2 = (Get-ChildItem "$env:LocalAppData\Mozilla\Firefox\Profiles" -Directory | Where-Object { $_.Name -like "*default-release*" } | Select-Object -First 1).FullName
} else {
    Write-Output "Firefox LocalAppData path does not exist, skipping..."
}

# Build paths for cache, cookies, and history if the profiles exist
if ($firefoxProfilePath2) {
    $firefoxCache = Join-Path $firefoxProfilePath2 "cache2"
} else {
    Write-Output "Firefox Cache path does not exist, skipping cache clearing..."
}

if ($firefoxProfilePath) {
    $firefoxCookies = Join-Path $firefoxProfilePath "cookies.sqlite"
    $firefoxHistory = Join-Path $firefoxProfilePath "places.sqlite"
} else {
    Write-Output "Firefox Profile path does not exist, skipping cookies and history clearing..."
}

# Clear Cache
if ($firefoxCache -and (Test-Path $firefoxCache)) {
    Write-Output "Clearing Firefox cache..."
    Remove-Item -Recurse -Force $firefoxCache
}

# Clear Cookies
if ($firefoxCookies -and (Test-Path $firefoxCookies)) {
    Write-Output "Clearing Firefox cookies..."
    Remove-Item -Force $firefoxCookies
}

# Clear History
if ($firefoxHistory -and (Test-Path $firefoxHistory)) {
    Write-Output "Clearing Firefox history..."
    Remove-Item -Force $firefoxHistory
}

# Setting variables for Brave data locations
Write-Output "Clearing Brave data..."
$braveCache = "$env:LocalAppData\BraveSoftware\Brave-Browser\User Data\Default\Cache"
$braveCookies = "$env:LocalAppData\BraveSoftware\Brave-Browser\User Data\Default\Network\Cookies"
$braveHistory = "$env:LocalAppData\BraveSoftware\Brave-Browser\User Data\Default\History"

if (Test-Path $braveCache) {
    Remove-Item -Path $braveCache -Recurse -Force
}
if (Test-Path $braveCookies) {
    Remove-Item -Path $braveCookies -Force
}
if (Test-Path $braveHistory) {
    Remove-Item -Path $braveHistory -Force
}

Write-Host "====== Browser data cleanup complete ======" -ForegroundColor Green

@"
`r
 --------------------------------------------------------------------------------------------------
|################################# - Windows Update - #############################################|
 --------------------------------------------------------------------------------------------------
`r
"@

# Check and install NuGet PackageProvider
Write-Output "Checking if PackageProvider 'NuGet' is installed..."
$nugetProvider = Get-PackageProvider -Name "NuGet" -ErrorAction SilentlyContinue
if (-not $nugetProvider) {
    Write-Output "'NuGet' PackageProvider is not installed. Installing..."
    Install-PackageProvider -Name "NuGet" -MinimumVersion 2.8.5.201 -Force
    Write-Output "'NuGet' PackageProvider installed successfully."
} else {
    Write-Output "'NuGet' PackageProvider is already installed..."
}

# Import NuGet PackageProvider
Write-Output "Importing PackageProvider 'NuGet'..."
Import-PackageProvider -Name "NuGet" -Force

# Check and install PSWindowsUpdate module
Write-Output "Checking if module 'PSWindowsUpdate' is installed..."
$psWindowsUpdateModule = Get-Module -Name "PSWindowsUpdate" -ListAvailable -ErrorAction SilentlyContinue
if (-not $psWindowsUpdateModule) {
    Write-Output "'PSWindowsUpdate' module is not installed. Installing..."
    Install-Module -Name "PSWindowsUpdate" -Force
    Write-Output "'PSWindowsUpdate' module installed successfully..."
} else {
    Write-Output "'PSWindowsUpdate' module is already installed..."
}

# Import PSWindowsUpdate module
Write-Output "Importing module 'PSWindowsUpdate'..."
Import-Module -Name "PSWindowsUpdate"

# Fetch available Windows updates
Write-Output "Fetching available Windows Updates..."
Get-WindowsUpdate

# Install Windows updates
Write-Output "Installing Windows Updates..."
Install-WindowsUpdate -AcceptAll -AutoReboot

Write-Host "====== System maintenance tasks complete ======" -ForegroundColor Green