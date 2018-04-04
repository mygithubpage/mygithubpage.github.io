
(Get-ChildItem "C:\github\toefl\*\*\*.html").ForEach{
    $content = (Get-Content $_.FullName).Replace("/initialize.js", "/storage/sdcard1/toefl/initialize.js")
    if(!$content) { continue }
    Set-Content $_.FullName.Replace("C:\github", "D:") $content
}


(Get-ChildItem "C:\github\*.js").ForEach{
    $content = (Get-Content $_.FullName)
    if(!$content) { continue }
    $content = $content.Replace("folder = `"`"", "folder = `"/storage/sdcard1/toefl`"")
    $content = $content.Replace("folder + `"/toefl/`"", "folder + `"/`"")
    Set-Content $_.FullName.Replace("C:\github", "D:\toefl") $content
}
