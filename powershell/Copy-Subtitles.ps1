. ".\Utility.ps1"

function Copy-Subtitles () {
    param($movieFolder, $subtitleFolder)
    
    # Move movie in movies folder
    $folders = Get-ChildItem $movieFolder -Directory
    foreach($folder in $folders)
    {
        $mp4 = Get-ChildItem -LiteralPath $folder.FullName -Filter "*.mp4"
        $subtitle = "$($mp4.FullName.TrimEnd('.mp4')).srt"
        $newName = "$($mp4.BaseName.Substring(0, $mp4.BaseName.Indexof("1080p") + 5)).mp4"
        # move movie and rename
        "`nMove '$($mp4.Name)' to '$($mp4.Directory.Parent.Name)'`nRename it as '$newName'"
        $movie = Move-Item -LiteralPath $mp4.FullName -Destination "$($mp4.Directory.Parent.FullName)\$newName"
        
        if (Test-Path -LiteralPath $subtitle) # use original name to find substile then move
        {
            "`nMove '$($subtitle.Name)' to '$($mp4.Directory.Parent.Name)'"
            "`nRename it as '$($movie.FullName.TrimEnd('.mp4')).srt'"
            Move-Item -LiteralPath $subtitle -Destination "$($movie.FullName.TrimEnd('.mp4')).srt"
        }
        Remove-Item -LiteralPath $folder.FullName -Recurse
    }

    $subtitles = Get-ChildItem $subtitleFolder -Filter "*.zip"
    $movies = Get-ChildItem $movieFolder -Filter "*.mp4"

    # Find movie without subtitle
    foreach($movie in $movies)
    {
        $subtitle = "$($movie.FullName.TrimEnd('.mp4'))p.srt"
        $name = $subtitle.TrimEnd('.1080p.srt').Split("\")[-1]
        if(!(Test-Path $subtitle))
        {     
            "Can not find $($subtitle.Split("\")[-1]), try to find the zip file in '$subtitleFolder'"
            $zipName = $name.Replace(".", "*")
            $zip = $subtitles -like "$($zipName.ToLower())*.zip"
    
            if($zip.Length -eq 0) # Download from
            {
                $uri = "https://yts.am/movie/"
                $uri += $name.ToLower() -replace "\.", "-"
                "Can not find the zip file in '$subtitleFolder',try to Download it from $uri"

                $html = Get-Html $name $uri
                $uri = ($html.links | 
                ForEach-Object {if($_.href -like "http://www.yifysubtitles.com/movie-imdb/*") {$_.href} })[0]
                Remove-Item "$PSScriptRoot\$name.html"
                $html = Get-Html $name $Uri
                $subtitleUri = ($html.links | ForEach-Object {if($_.href -like "*english*") {$_.href} })[0]
                $uri = "http://www.yifysubtitles.com$($subtitleUri.TrimStart('about:').Remove(9,1)).zip"
                Invoke-WebRequest -Uri $uri -OutFile $subtitleFolder\$name.zip
                $zip = "$name.zip"
                Remove-Item "$PSScriptRoot\$name.html"
            }
            
            "Unzip $zip, move it to '$movieFolder' and rename it as '$($subtitle.Split("\")[-1])'`n"
            Expand-Archive -LiteralPath ($subtitleFolder + $zip) -DestinationPath $subtitleFolder
            Move-Item -LiteralPath ($subtitleFolder + ((Get-ChildItem $subtitleFolder) -like "*.srt")) `
            -Destination $subtitle
            Remove-Item -LiteralPath ($subtitleFolder + $zip) 
        }
    }
}

Copy-Subtitles "$Home\Videos\Movies\" "$Home\Downloads\Compressed\"
