$iCloud = "C:\Users\decisactor\iCloudDrive"

$destination = $iCloud
$files = Get-ChildItem "C:\github\toefl\og\*\*.html"
foreach($file in $files) {
    if($destination.Contains("iCloud")) {
        $content = (Get-Content $file.FullName).Replace("/initialize.js", "../../initialize.js")
        if(!$content) { continue }
        Set-Content $file.FullName.Replace("C:\github", "$iCloud") $content
    }
    else {
        $content = (Get-Content $file.FullName).Replace("/initialize.js", "/storage/sdcard1/toefl/initialize.js")
        if(!$content) { continue }
        Set-Content $file.FullName.Replace("C:\github", "D:") $content
    }
}

$files = Get-ChildItem "C:\github\*.js"
foreach($file in $files) {
    if($destination.Contains("iCloud")) {
        $content = (Get-Content $file.FullName)
        if(!$content) { continue }
        $content = $content.Replace("folder = `"`"", "folder = `"../..`"")
        $content = $content.Replace("folder + `"/toefl/`"", "folder + `"/`"")
        Set-Content $file.FullName.Replace("C:\github", "$iCloud\toefl") $content
    }
    else {
        $content = (Get-Content $file.FullName)
        if(!$content) { continue }
        $content = $content.Replace("folder = `"`"", "folder = `"/storage/sdcard1/toefl`"")
        $content = $content.Replace("folder + `"/toefl/`"", "folder + `"/`"")
        Set-Content $file.FullName.Replace("C:\github", "D:\toefl") $content
    }
    
}

<#$xml = [xml](Get-Content $file)
    Set-Content $file.FullName (Format-Xml -Xml $xml -Indent 2)#>