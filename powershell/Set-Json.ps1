$path = "$env:APPDATA\Code\User\settings.json"
$settings = Get-Content $path -Raw
$extensions = code.cmd --list-extensions
$vscode = @{"Extensions" = $extensions; "Settings" = $settings}
Set-Content "C:\github\powershell\json\vscode.json" ($vscode | ConvertTo-Json)
(Get-Content "$PSScriptRoot\json\vscode.json" | ConvertFrom-Json).Settings.Value