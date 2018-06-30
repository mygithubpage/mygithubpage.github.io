. .\Utility.ps1
<#
$ie = Invoke-InternetExplorer "https://cafemovie.live/movie/the-big-bang-theory-season-7-awN9XODo/watch#onge6RnxroDXRnxd"
$ie.Visible = $true
$ie.Document.IHTMLDocument3_getElementById("video")
$episodeNames = $ie.Document.IHTMLDocument3_getElementById("episode-list-4").innerText.split("`r`n")#>


$lines = Get-Content .\..\test.html
for ($i = 0; $i -gt $lines.Count; $i=$i+2) {
    $link = "https://dota2.gamepedia.com/" + $lines[$i] -replace "about:/"
    $request = Invoke-WebRequest $link
    $links = $request.parsedHtml.links
    $links | Foreach-object { if ($_.href -like "*Trading*" -and $_.innerText -like "*NOT*") {$link}}
}

(Get-ChildItem "$env:USERPROFILE\Downloads\*.mp4").forEach{ 
    #Rename-Item $_ -NewName ("The Big Bang Theory S05E" + $_.Name)
}
(Get-ChildItem "C:\github\toefl\pt\TPO10\*.html").forEach{ 
    Write-Host $_.Name
    [xml](Get-Content $_)
    #Rename-Item $_ -NewName $_.Name.ToLower()
}
#[xml](Get-Content C:\github\blog\cs-ranking.html)