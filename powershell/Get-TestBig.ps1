<#
$links = @()
$html = Invoke-WebRequest "https://www.testbig.com/toefl"
$links += $html.Links.Where{$_.href -like "*integrated*"} | Select-Object href
$links += $html.Links.Where{$_.href -like "*independent*"} | Select-Object href
$links | Export-Csv $PSScriptRoot\TestBig\TestBigW.csv
#>
. .\Utility.ps1
function Update-Xml()
{
    param($Xml, $Content)
    $Content = $Content -replace "P>", "p>"
    $cdata = $xml.CreateCDataSection($Content)
    $xml.LastChild.LastChild.AppendChild($cdata) | Out-Null
    $xml.InnerXml = $xml.InnerXml.Replace("<![CDATA[").Replace("]]>")
}

$links = Import-Csv $PSScriptRoot\TestBig\TestBigW.csv
for($i = 1; $i -le $links.Length; $i++)
{
    $n = $links[$i-1].href.Split("-")[4]
    $question = if($links[$i-1].href -like "*integrated*") {1} else {2}
    "TPO$n" + "W$question"
    $Path = "$PSScriptRoot\TestBig\TPO$n\TPO$($n)W$question.html"
    [xml]$xml = New-Html $Content $Path

    $html = Invoke-WebRequest "https://www.testbig.com$($links[$i-1].href)"
    $pages = $html.ParsedHtml.body.getElementsByClassName("pager__item")
    $page = ($pages | Select-Object innerText).innerText
    $page = $page.indexOf(($page -like "*next*")[0])
    
    $count = 0
    $items = @()

    for ($j = 1; $j -le $page; $j++) 
    {
        "page $j"
        $responses = $html.Links.Where{$_.innerText -like "*Read full essay*"} | Select-Object href
        foreach($response in $responses)
        {
            $html = Invoke-WebRequest ("https://www.testbig.com$($response.href)")
            $user = ($html.Links.Where{$_.href -like "*users*" -and $_.class -eq "username"})[0]
            $text = $html.ParsedHtml.body.getElementsByClassName("node__content")
            $text = $text[0].innerText -replace "`r`n","</p><p>"
            
            Update-Xml $xml ("<article class=`"$($user.href.split("/")[-1])`"><h3>$($user.innerText)</h3><p>$text</p></article>" -replace "<p></p>")
            $xml.Save($path)
        }
        if($j -lt $page) {$html = Invoke-WebRequest ("https://www.testbig.com$($response.href)" + "?page=$j")}
    }
}

#$links = Import-Csv $PSScriptRoot\TestBig\TestBigS.csv

for($i = 1; $i -le -$links.Length; $i++)
{
    $question = if ($i % 6 -eq 0) {6} else {$i % 6}
    $n = [Math]::Ceiling($i/6)
    if($i -gt 204) { $n += 5}
    $n = if($n -lt 10) { "0$n" } else { $n }
    "TPO$n" + "S$question.csv"

    $html = Invoke-WebRequest "https://www.testbig.com$($links[$i-1].href)"
    $pages = $html.ParsedHtml.body.getElementsByClassName("pager__item")
    $page = ($pages | Select-Object innerText).innerText
    $page = $page.indexOf(($page -like "*next*")[0])
    $comments = $html.ParsedHtml.body.getElementsByClassName("comment__content") 
    if($comments) 
    { 
        $comments = $comments.ForEach{$_.getElementsByClassName("field__item")[0].innerHTML}
        $path = "$HOME\Downloads\ETS\TOEFL Programs\Temp\TOEFLspeaking\forml1\TPO$n\Speaking\TPO$($n)S$question.xml"
        [xml]$xml = Get-Content $path
        foreach($comment in $comments)
        {
            Update-Xml $xml "<article>$comment</article>"
        }
        $xml.Save($path)
    }
    
    $count = 0
    $items = @()

    for ($j = 1; $j -le $page; $j++) 
    {
        "page $j"
        $responsess = $html.Links.Where{$_.innerText -like "*Read full essay*"} | Select-Object href
        foreach($responses in $responsess)
        {
            $count++
            $number = if($count -lt 10) { "0$count" } else { $count }
            $html = Invoke-WebRequest ("https://www.testbig.com$($responses.href)")
            $audio = $html.ParsedHtml.body.getElementsByTagName("audio")[0].outerHTML
            if($audio)
            {
                $start = $audio.IndexOf("src=") + 5
                $end = $audio.IndexOf(".mp3") + 4
                if($end -eq 3) { $end = $audio.IndexOf(".wav") + 4 }
                $audio = $audio.Substring($start, $end - $start)
                $user = ($html.Links.Where{$_.href -like "*users*"})[0].innerText
                
                $name = "tpo$n" + "s$question$number" + $audio.Substring($audio.Length - 4, 4)
                $name

                $item = New-Object PSObject
                $item | Add-Member Name $name
                $item | Add-Member User $user
                $item | Add-Member Audio $audio
                $items += $item
            }
        }
        if($j -lt $page) {$html = Invoke-WebRequest ("https://www.testbig.com$($links[$i-1].href)" + "?page=$j")}
    }
    $items | Export-Csv ("$PSScriptRoot\TestBig\TPO$n" + "S$question.csv")
}

function Get-Essay()
{
    $essays = Get-Content $PSScriptRoot\essay.txt
    $finish = $false
    $count = 0

    foreach($line in $essays)
    {
        
        if ($line -like "*Toefl*Essay*" -or $line.Length -lt 5) 
        {
            if ($passage.EndsWith("<p>")) 
            {
                $passage = $passage.Remove($passage.Length - 3, 3)
                $finish = $true
            }
            continue
        }

        if ($finish) 
        {
            $count++
            $passage = "<article class=`"topic$number`">$passage</article>"
            $passage = $passage -replace "&", "&amp;" -replace "<p></p>", ""
            New-Html $passage "$PSScriptRoot\Essay\Topic$number-$count.html"
            "Topic$number-$count.html"
            $passage = ""
        }

        if ($line.StartsWith("Topic ")) 
        {
            $text = "<h3>$line</h3><p>"
            $number = ($line -split " ")[1]
            $finish = $false
        }
        else 
        {
            $text = "$line "
        }
        $passage += $text
    
        if ($line.EndsWith(".") -or $line.EndsWith("?") -or $line.EndsWith("!") `
        -or $line.EndsWith(".`"") -or $line.EndsWith("?`"") -or $line.EndsWith("!`"")) 
        {
            $passage += "</p><p>"    
        }
    }
}
#Get-Essay