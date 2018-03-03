
# Install Visual Studio Code
# https://github.com/PowerShell/vscode-powershell/blob/master/scripts/Install-VSCode.ps1

# Download Installer
$codePath = "C:\Program Files\Microsoft VS Code\Code.exe"
$installerFile = "$HOME\Downloads\Visual Studio Code.exe"
if (!(Test-Path $codePath)) 
{ 
    if (!(Test-Path $installerFile)) 
    {
        Write-Host "`nDownloading latest stable Visual Studio Code..."
        $html = Invoke-WebRequest "https://code.visualstudio.com/docs/setup/windows"
        $uri = $html.ParsedHtml.body.getElementsByTagName("a") | `
        ForEach-Object {if($_.innerText -eq "Visual Studio Code installer"){$_.href}}
        Invoke-WebRequest $uri -OutFile $installerFile
    }
    else 
    {
        Write-Host "`nVisual Studio Code is already downloaded."
    }
    Write-Host "`nInstalling Visual Studio Code..."
    Invoke-Item $installerFile 
}
else 
{
    Write-Host "`nVisual Studio Code is already installed." 
}

# Install Extensions
$extensions = "ms-vscode.cpptools", "ms-vscode.csharp", "ms-vscode.powershell", "ms-python.python", `
"formulahendry.code-runner", "zhuangtongfa.material-theme", "robertohuertasm.vscode-icons", `
"DavidAnson.vscode-markdownlint"
foreach($extension in $extensions)
{
    Write-Host "`nInstalling extension $extension..."
    code.cmd --install-extension $extension
}

# Change Settings
$settingsFile = "$env:APPDATA\Code\User\settings.json"

if (!(Test-Path $settingsFile)) 
{ 
    New-Item $settingsFile 
    Set-Content $settingsFile -Value `
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

Write-Host "`nInstallation complete, starting Visual Studio Code...`n`n"
code.cmd