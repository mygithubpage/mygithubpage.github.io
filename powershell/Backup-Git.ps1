<# 



@("OneDrive", "Google Drive", "iCloudDrive").ForEach{
    $folder = $_
    $directory = "$env:USERPROFILE\$folder\"
    (Get-ChildItem "C:\github" -Recurse -File).ForEach{
        $item = $_
    }
}
#>

function Update-Git {
    git add .
    git commit -m "update"
    git push -u origin master 
}

function Update-Android {
    <#
    (Get-PSDrive -PSProvider FileSystem).Root.ForEach{
    ($_ | Get-ChildItem).Name.IndexOf("Android")
    }
    #>

    (Get-ChildItem "D:\github\" -Recurse -File).ForEach{
        $file = $_
        if ($file.Name -match ".html") {
            $content = (Get-Content $file.FullName).Replace("/index.js", "/storage/sdcard1/github/index.js")
            if (!$content) { continue }
            Set-Content $file.FullName $content
        }
    }
}


#Update-Android
Update-Git
# w3.css
# highlight.js v9.12.0
# JSXGraph 0.99.7