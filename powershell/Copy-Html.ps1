$files = Get-ChildItem "C:\github\toefl\*\*\*.html"
foreach($file in $files) {
    $content = (Get-Content $file.FullName).Replace("/initialize.js", "/storage/sdcard1/toefl/initialize.js")
    if(!$content) { continue }
    Set-Content $file.FullName.Replace("C:\github", "D:") $content
}

$files = Get-ChildItem "C:\github\*.js"
foreach($file in $files) {
    $content = (Get-Content $file.FullName)
    if(!$content) { continue }
    $content = $content.Replace("folder = `"`"", "folder = `"/storage/sdcard1/toefl`"")
    $content = $content.Replace("folder + `"/toefl/`"", "folder + `"/`"")
    Set-Content $file.FullName.Replace("C:\github", "D:\toefl") $content
}

<#$xml = [xml](Get-Content $file)
    Set-Content $file.FullName (Format-Xml -Xml $xml -Indent 2)#>