
# Install VS Code
# https://github.com/PowerShell/vscode-powershell/blob/master/scripts/Install-VSCode.ps1

# Download Installer
$name = "VS Code"
$path = "C:\Program Files\Microsoft VS Code\Code.exe"
$installer = "$HOME\Downloads\$name.exe"
if (!(Test-Path $path)) 
{ 
    if (!(Test-Path $installer)) 
    {
        Write-Host "`nDownloading latest stable $name..."
        $html = Invoke-WebRequest "https://code.visualstudio.com/docs/setup/windows"
        $uri = $html.ParsedHtml.body.getElementsByTagName("a") | `
        ForEach-Object {if($_.innerText -eq "$name installer"){$_.href}}
        #$uri = "https://go.microsoft.com/fwlink/?Linkid=852157"
        Invoke-WebRequest $uri -OutFile $installer
    }
    else 
    {
        Write-Host "`n$name is already downloaded."
    }
    Write-Host "`nInstalling $name..."
    Invoke-Item $installer 
}
else 
{
    Write-Host "`n$name is already installed." 
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
$setting= "$env:APPDATA\Code\User\settings.json"

if (!(Test-Path $setting)) 
{ 
    New-Item $setting
    Set-Content $setting-Value `
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

Write-Host "`nInstallation complete, starting $name...`n`n"
code.cmd