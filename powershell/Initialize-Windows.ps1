

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

    if ($cmdPath -cmatch " Code") { 
        $fileUri = "https://vscode-update.azurewebsites.net/latest/win32-x64/stable" 
        $installer = "$env:TEMP\$installer.exe"
    }
    else {
        $html = Invoke-WebRequest $fileUri
        $document = $html.ParsedHtml.body

        $fileUri = $document.getElementsByTagName("a") | Foreach-Object { if ($_.href -match $installer) { $_.href }}
        $installer = "$env:TEMP\" + $fileUri.Split("/")[-1] 
    }

    if (!(Test-Path $CmdPath) -or !(Test-Version $FileUri) ) {
        if (!(Test-Path $Installer)) 
        {
            Write-Host "Downloading $Installer..."
            Invoke-WebRequest $FileUri -OutFile $Installer
        }
        Write-Host "`nInstalling $Installer..."
        Invoke-Item $Installer
    }
    
}


# Set-ExecutionPolicy Undefined
$programs = "VSCode", "iCloud", "Git"
# https://github.com/PowerShell/vscode-powershell/blob/master/scripts/Install-VSCode.ps1

$programs.ForEach{
    $startMenu = "Microsoft\Windows\Start Menu\Programs\$_"
    $cmdPath = "$env:ProgramFiles\$startMenu"

    if ($_ -match "Git") {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

        $fileUri = "https://git-scm.com/download/win"
        $installer = "64-bit.exe"
    }
    elseif ($_ -match "VSCode") {
        $cmdPath = "$env:APPDATA\$startMenu" -replace "VSCode", "Visual Studio Code"
    }
    elseif ($_ -match "iCloud") {
        $fileUri = "https://support.apple.com/en-us/HT204283"
        $installer = "iCloudSetup.exe"
    }

    Invoke-Installer $installer $fileUri

    if ($_ -match "VSCode") {
        # Install Extensions
        (Get-Content "$PSScriptRoot\json\vscode.json" | ConvertFrom-Json).Extensions.ForEach{
            code --install-extension $_
        }
        # Change Settings
        Set-Content "$env:APPDATA\Code\User\settings.json" $json.Settings.Value
    }
}