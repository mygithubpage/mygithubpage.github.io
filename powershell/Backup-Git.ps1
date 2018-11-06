
<#
git add .
git commit -m "update"
git push -u origin master 
#>    


$folders = "OneDrive", "Google Drive", "iCloudDrive", "Box Sync"
(Get-PSDrive -PSProvider FileSystem).Root.ForEach{
    if ( (Test-Path $_) -and ($_ | Get-ChildItem).Name.Contains("Android") ) { $folders += , $_ -replace "\\$" }
}

(Get-ChildItem "C:\github" -Recurse).ForEach{
    $file = $_
    $folders.ForEach{
        $path = if ($_ -notmatch ":") { "$env:USERPROFILE\$_\github" } else { "$_\github" }
        if (!(Test-Path $path)) { 
            New-Item $path -ItemType Directory | Out-Null
        }
        $path = $file.FullName -replace "C:", "$env:USERPROFILE\$_"
        if (!(Test-Path $path) -or (Get-Item $path).LastWriteTime -lt $file.LastWriteTime ) { 
            Copy-Item $file.FullName $path
        }

        if ($_ -match ":" -and $file.Name -match ".html") {
            $content = (Get-Content $file.FullName).Replace("/index.js", "/storage/sdcard1/github/index.js")
            if (!$content) { continue }
            Set-Content $file.FullName $content
        }
        
    }
}

$folders.ForEach{
    $path = if ($_ -notmatch ":") { "$env:USERPROFILE\$_\github" } else { "$_\github" }
    (Get-ChildItem $path -Recurse).ForEach{
        $path = $_.FullName -replace "($env:USERPROFILE\)?$_", "C:"
        if (!(Test-Path $path)) { Remove-Item $path }
    }
}