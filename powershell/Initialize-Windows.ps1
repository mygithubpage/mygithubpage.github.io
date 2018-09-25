#  

#Set-ExecutionPolicy Undefined
$programs = "Git", "VSCode"
# https://github.com/PowerShell/vscode-powershell/blob/master/scripts/Install-VSCode.ps1

function Install-VSCode {
    param (
        [string]$Architecture = "64-bit",
        [string]$BuildEdition = "Stable"
    )

    # Setting Variable
    $bitVersion = "win32-x64"

    $codeCmdPath = "$env:LocalAppData\Programs\Microsoft VS Code\bin\code.cmd"
    $appName = "Visual Studio Code ($($Architecture))"
    $fileUri = "https://vscode-update.azurewebsites.net/latest/$($bitVersion)/stable"

    $installer = "$env:TEMP\vscode-$($BuildEdition).exe"

    # Installing Application
    if (!(Test-Path $codeCmdPath)) {
        if (!(Test-Path $installer)) 
        {
            Write-Host "`nDownloading latest $appName..."
            Invoke-WebRequest $fileUri -OutFile $installer
        }
        else {
            Write-Host "`n$installer is already downloaded."
        }
        Write-Host "`nInstalling $appName..."
        Start-Process -Wait $installer -ArgumentList "/verysilent /tasks=addcontextmenufiles,addcontextmenufolders,addtopath"
    }
    else {
        Write-Host "`n$appName is already installed." 
    }

    # Install Extensions
    $extensions = "ms-vscode.cpptools", "ms-vscode.csharp", "ms-vscode.powershell", "ms-python.python", `
    "formulahendry.code-runner", "zhuangtongfa.material-theme", "robertohuertasm.vscode-icons", `
    "DavidAnson.vscode-markdownlint"
    foreach($extension in $extensions) {
        Write-Host "`nInstalling extension $extension..."
        & $codeCmdPath --install-extension $extension
    }

    # Change Settings
    $setting = "$env:APPDATA\Code\User\settings.json"

    if (!(Test-Path $setting)) { 
        New-Item $setting
        Set-Content $setting `
        '{
            "editor.minimap.enabled": false,
            "editor.wordWrap": "on",
            "extensions.autoUpdate": true,
            "files.autoSave": "afterDelay",
            "files.encoding": "utf8",
            "vsicons.dontShowNewVersionMessage": true,
            "workbench.colorTheme": "One Dark Pro",
            "workbench.iconTheme": "vscode-icons"
        }'
    }
    else {
        Get-Content
    }

    Write-Host "`nInstallation complete, starting $appName...`n`n"
    $codeCmdPath
}

function Install-Git {
    
}

$prgrams.ForEach{
    Invoke-Expression "Install-$_"
}