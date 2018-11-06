

$movieFolders = (Get-ChildItem "$Home\Downloads" -Directory).Where{ $_.BaseName -match "\((19|20)\d{2}\)" }
foreach ($movieFolder in $movieFolders) {
    $mp4 = $movieFolder.GetFiles("*.mp4")[0]
    $newName = $mp4.Name -replace ".1080p.*(?=\.mp4)"
    $newName
    
    $srt = $movieFolder.GetFiles("*.srt")[0]
    if (!$srt) { 
        $query = $newName.ToLower().Replace(".", "-") -replace "-mp4"
        $uri = "https://yts.am/movie/$query"
        $html = Invoke-Webrequest $uri -OutFile "$Home\Downloads\$newName.html"
        $link = (Select-String "(?<=imdb/)tt\d+" "$Home\Downloads\$newName.html" ).Matches.Value[0]
        Remove-Item "$Home\Downloads\$newName.html"
    
        $html = ""
        $html = Invoke-Webrequest "http://www.yifysubtitles.com/movie-imdb/$link"
        if (!$html) { continue }

        $uri = ($html.links.ForEach{if($_.href -like "*english*") {$_.href} })[0].replace("subtitles", "subtitle")
        Invoke-WebRequest "http://www.yifysubtitles.com/$uri.zip" -OutFile "$Home\Downloads\$newName.zip"
        
        Expand-Archive "$Home\Downloads\$newName.zip" "$($movieFolder.FullName)\$newName"
        $srt = Get-ChildItem -LiteralPath "$($movieFolder.FullName)\$newName"
        Remove-Item "$Home\Downloads\$newName.zip"
    }
    
    Move-Item -LiteralPath $srt.FullName "$Home\Downloads\Movies\$($newName.Replace("mp4","srt"))" | Out-Null
    Move-Item -LiteralPath $mp4.FullName "$Home\Downloads\Movies\$newName" | Out-Null
    Remove-Item -LiteralPath $movieFolder.FullName -Force
}

<#
$files = Get-ChildItem "$Home\Downloads\Movies\"
foreach ($file in $files) {
    $newName = "$($file.BaseName.Substring(0, $file.BaseName.Indexof(".1080p")))$($file.Extension)"
    Rename-Item $file.FullName $newName
}#>

