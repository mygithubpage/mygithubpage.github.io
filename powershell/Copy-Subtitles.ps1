#. ".\Utility.ps1"

$movies = Get-ChildItem "$Home\Downloads" -Directory | Where-Object { $_.BaseName -like "*20*" }
foreach ($movie in $movies) {
    $mp4 = $movie.GetFiles("*.mp4")
    $newName = "$($mp4.BaseName.Substring(0, $mp4.BaseName.Indexof("1080p") + 5)).mp4"
    $newName
    $name = $newName.substring(0,$newName.Length - 10)
    $uri = $name.ToLower() -replace "\.", "-"

    $uri = "https://yts.am/movie/$uri"
    $html = Invoke-Webrequest $uri -OutFile "$name.html"
    $link = (Get-Content "$name.html" | Select-String "imdb/tt.*?`""  -AllMatches).Matches[0].Value.Split("/")[1].Trim("`"")
    Remove-Item "$name.html"
    $html = ""
    $html = Invoke-Webrequest "http://www.yifysubtitles.com/movie-imdb/$link"
    if (!$html) { continue }

    $uri = ($html.links | ForEach-Object {if($_.href -like "*english*") {$_.href} })[0].replace("subtitles", "subtitle")
    Invoke-WebRequest -Uri "http://www.yifysubtitles.com/$uri.zip" -OutFile "$name.zip"

    Move-Item -LiteralPath $mp4.FullName -Destination "$Home\Downloads\Movies\$newName" | Out-Null
    Expand-Archive -LiteralPath "$name.zip" -DestinationPath $mp4.FullName
    Get-ChildItem -LiteralPath $mp4.FullName | Move-Item -Destination ("$Home\Downloads\Movies\" + $newName.Replace(".mp4", ".srt")) | Out-Null
    Remove-Item "$name.zip"
    Remove-Item $movie.FullName
}

