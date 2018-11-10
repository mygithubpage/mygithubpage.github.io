

function Invoke-Installer {
    param (
        [string]$Installer,
        [string]$FileUri
    )

    function Test-Version {
        if ($FileUri -match "/git/") {
            $fileUri.Contains((git --version) -replace "git version ")
        }
        else {
            $true
        }
    }

    if (!(Test-Path $CmdPath)) {
        if ($cmdPath -cmatch " Code") { 
            $fileUri = "https://aka.ms/win32-x64-user-stable" 
            $installer = "$env:TEMP\VSCode.exe"
        }
        else {
            $html = Invoke-WebRequest $fileUri
            $document = $html.ParsedHtml.body
            
            $fileUri = $document.getElementsByTagName("a") | Foreach-Object { if ($_.href -match $installer) {$_.href}}
            if ($fileUri -match "about:") { $fileUri -replace "about:", $html.BaseResponse.ResponseUri.AbsoluteUri}
            $installer = "$env:TEMP\" + $fileUri.Split("/")[-1] 
        }
        
        if (!(Test-Path $Installer)) {
            Write-Host "Downloading $Installer..."
            Invoke-WebRequest $FileUri -OutFile $Installer
        }
        Write-Host "Installing $Installer..."
        Invoke-Item $Installer
    }
    
}

# Setting Up Windows
if ((Get-ExecutionPolicy) -eq "Restricted") {
    Start-Process powershell -Verb runAs -Argumentlist "Set-ExecutionPolicy Unrestricted"
}
#Start-Process -FilePath "C:\Program Files (x86)\Internet Explorer\iexplore.exe" # Setup IE for iwr
# Show Hidden Item; File Extension

# Installation
$programs = "Git", "Node", "VSCode", "7-Zip"
if ((Get-CimInstance Win32_LogicalDisk).Size[0] / (2 -shl 29) -gt 60) { 
    $programs += , "iCloud", "Google Sync", "Box", "Chrome", "Firefox", "VMware", "VirtualBox", "TeamViewer", "VLC",
    ".Net Core", "Anaconda", "Steam", "Office"
}
$apps = "iTunes", "VPN Pro"
$programs.ForEach{
    $startMenu = "Microsoft\Windows\Start Menu\Programs\$_"
    $cmdPath = "$env:ProgramData\$startMenu"

    if ($_ -match "Git") {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

        $fileUri = "https://git-scm.com/download/win"
        $installer = "64-bit.exe"
    }
    elseif ($_ -match "VSCode") {
        $cmdPath = "$env:APPDATA\$startMenu" -replace "VSCode", "Visual Studio Code"
    }
    elseif ($_ -match "7-Zip") {
        $fileUri = "https://www.7-zip.org/"
        $installer = "x64.exe"
    }
    elseif ($_ -match "iCloud") {
        $fileUri = "https://support.apple.com/en-us/HT204283"
        $installer = "iCloudSetup.exe"
    }
    
    Invoke-Installer $installer $fileUri

    while (!(Test-Path $cmdPath)) {}
    if ($_ -match "VSCode") {
        # Install Extensions
        $extensions = code.cmd --list-extensions
        $json = (Get-Content "$PSScriptRoot\json\vscode.json" | ConvertFrom-Json)
        $json.Extensions.ForEach{
            Write-Host "Installing $_..."
            if ($_ -notin $extensions) { 
                Start-Process PowerShell -Argumentlist "code.cmd --install-extension $_"
            }
        }
        # Change Settings
        Set-Content "$env:APPDATA\Code\User\settings.json" $json.Settings.Value
    }
    elseif ($_ -match "Git") {
        $path = "C:\GitHub"
        Set-Location "C:"
        $site = "mygithubpage.github.io"
        $commands = "git clone https://github.com/mygithubpage/$site.git"
        $commands += "; Rename-Item C:\$site $path; Copy-Item $path\index.js C:\"
        Start-Process PowerShell -Argumentlist $commands
    }
}