
. "$PSScriptRoot\Utility.ps1"
##  Script Structure
##  1 Script Entrance
#       Set Global variable
#
##  2 Loop
#       2.1 Get-Sets (Comment Set-Translation and New-TPOHtml)
#       2.2, 2.3 Set-Translation and New-TPOHtml
#
##      2.1 Get-Sets
#           2.1.1 Set-Links
function Add-XmlNodes ($xml, $parentNode, $nodes) {
    foreach ($node in $nodes) {
        $xmlElement = $xml.CreateElement($node.Name)
        $xmlElement.innerText = $node.innerText
        try {
            foreach ($attribute in $node.attributes.GetEnumerator()) { $xmlElement.SetAttribute($attribute.Name, $attribute.Value) }
        }
        catch {}
        $parentNode.AppendChild($xmlElement)
        $xmlElement
    }
}

function Add-XmlTestItemNode ($attributes) {
    $xml = ConvertTo-Xml -InputObject $xml
    $xml.RemoveAll()

    $node = @{ Name = "TestItem"; Attributes = $attributes }
    Add-XmlNodes $xml $xml $node | Out-Null
    $xml
}

function Add-XmlChildNodes ($xml, $names, $innerTexts, $type) {
    $parentNode = $xml.FirstChild
    if ($type) { $parentNode = Add-XmlNodes $xml $xml.FirstChild @{ Name = $type} }
    $nodes = @()
    for ($i = 0; $i -lt $names.Count; $i++) {
        $node = @{ Name = $names[$i]; innerText = $innerTexts[$i] }
        $nodes += $node
    }
    Add-XmlNodes $xml $parentNode $nodes | Out-Null
}

function ConvertTo-HtmlName ($Name) {
    
    $type = $Name.Substring($setsLength, 1)
    $sections.ForEach{ 
        if ($_.Substring(0,1) -eq $type) { $Name = $Name.Replace($type, "-$_").ToLower() }
    }
    $Name -creplace "q", "-question" -creplace "p\.", "-reading." -creplace "r\.", "-replay."
}

function ConvertTo-XmlName ($Name) {
    $Name = $Name.ToUpper()
    $Names = $Name.Split("-")
    $Name = $Names[0] + $Names[1].Substring(0,1) + $Names[1].Substring(0,$Name.Length - 1)
    $Name -creplace "-question", "Q" -creplace "-reading.", "P." -creplace "-replay.", "R."
}

function New-File ($file, $path) {
    New-Item $path -ErrorAction SilentlyContinue | Out-Null
    if ($file.GetType().Name -eq "XmlDocument") {$file = Format-Xml $file}
    Set-Content -Value $file -Path $path -Encoding UTF8
}

function Update-Characters ($string) {
    # https://unicode-table.com
    $string = $string -replace "\u2014", "-" 
    $string = $string -replace "\u2018", "'" 
    $string = $string -replace "\u2019", "'" 
    $string = $string -replace "\u201C", "`"" 
    $string = $string -replace "\u201D", "`"" 
    $string = $string -replace "\u2026", "..." 
    
    # HTML Code
    ConvertTo-Code $string "utf8"
}

function Remove-Characters ($string) {
    <#
    if ($type -eq "selection") {$digit = "0-9"}
    $character = "[^A-za-z$digit!#$%&'()*+,./:;<=>?@\^_`{}~-]"
    while ($string -and $string.Substring(0, 1) -match $character) { $string = $string.Remove(0, 1) } 
    while ($string -and $string.Substring($string.Length - 1, 1) -match $character) { $string = $string.Remove($string.Length - 1, 1) } 
    if ($type -eq "question") { while ($string.Substring(0, 1) -match "[^A-Za-z]") { $string = $string.Remove(0, 1) } }
    while($string.Contains("  ")) { $string = $string.Replace("  ", " ") }
    #>
    if (!$string) {return}
    while ($string.Substring(0, 1) -eq " ") { $string = $string.Remove(0, 1) } 
    while ($string.Substring($string.Length - 1, 1) -eq " ") { $string = $string.Remove($string.Length - 1, 1) } 
    while ($string.Contains("  ")) { $string = $string.Replace("  ", " ") }

    $string = $string -replace "\u2587", "" # Block Elements - Lower Seven Eighths Block
    $string = $string -replace "\u25A0", "" # Geometric Shapes - Black Square
    #>
    Update-Characters $string.Replace("&nbsp;") 
}

function Format-Paragraphs ($string) {
    $string = $string -replace "\s*`r`n\s*", "`r"
    $string = $string -replace "`r`n`r`n", "`r"
    while($string.Contains("  ")) { $string = $string.Replace("  ", " ") }
    $string = $string.Replace("`r", "`n" + " " * 8)
    Update-Characters $string
}

function Add-Shading ($text, $highlight) {

    $sentenceIndex = $text.IndexOf($highlight.parentNode.innerText)
    $selectionIndex = $highlight.parentNode.innerHTML.IndexOf('<span class="light">')

    # if innerText has img tag
    if ($highlight.parentNode.firstChild.tagName -eq "img") {
        $imgLength = $highlight.parentNode.firstChild.outerHTML.Length
        $selectionIndex -= $imgLength
    }

    # if innerText has insert-area tag
    $index = $highlight.parentNode.innerHTML.IndexOf("data-answer=") + 23
    if ($index -ne 22 -and $selectionIndex -gt $index) { $selectionIndex -= $index }

    $selection = $highlight.innerText
    $text = $text.Insert($selectionIndex + $sentenceIndex, "[")
    $startIndex = $selectionIndex + $sentenceIndex + $selection.Length + 1
    if ($selection.Substring($selection.Length - 1, 1) -eq " ") { $startIndex-- }
    $text = $text.Insert($startIndex, "[")
    $text
}

function Get-Audio ($Link, $Path) {
    $global:flag = $false
    $audioName = $Path.Split("\")[-1]
    # Download mp3
    $mp3 = "$htmlPath\$(($sets + $number).ToLower())\" + (ConvertTo-HtmlName $audioName)
    if (Test-Path $mp3) { }#Write-Host "$mp3 Exist" }
    else {
        
        $file = "$sets$number.html"
        if (!(Test-Path $file)) { Invoke-WebRequest $Link -OutFile $file }

        $html = Get-Content $file -Encoding UTF8
        foreach($line in $html) {
            # Listen again to part of the conversation.
            if ($line.Contains("Listen again to part of the conversation.")) { $global:flag = $true } 
            $end = $line.IndexOf(".mp3") + 4
            $start = $line.IndexOf("https://")
            if ($end -ne 3 -and $start -ne -1 -and !$line.Contains("speaking_beep_prepare")) {
                $audioLink = Update-Characters $line.Substring($start, $end - $start)
            }
        }
        Remove-Item $file
        if ($flag) { 
            $audioName = $audioName.Insert($audioName.Length - 4, "R") 
            $mp3 = $mp3.Insert($mp3.Length - 4, "-replay") 
            $Path = $Path.Insert($Path.Length - 4, "R") 
        }

        #Write-Host "Downloading" $audioName
        & $idmExe /n /d $audioLink -p "$htmlPath\$(($sets + $number).ToLower())\" -f (ConvertTo-HtmlName $audioName)
        while (!(Test-Path $mp3)) {} # Wait for downloading completed
    }

    # Convert mp3
    $wav = $Path.Replace(".mp3", ".wav")
    if ((Test-Path $mp3.Replace(".mp3", ".wav")) -or (Test-Path $wav)) { }#Write-Host "$($mp3.Replace(".mp3", ".wav")) Exist" }
    else {
        #Write-Host "Converting" $mp3.Split("\")[-1]
        & $switchExe -convert $mp3 -overwrite always -hide -format .wav -settings .wav PCM16 22050 2
        while (!(Test-Path $mp3.Replace(".mp3", ".wav"))) {} # Wait for converting completed
    }

    if (!(Test-Path $wav)) { 
        Wait-FileUnlock $mp3.Replace(".mp3", ".wav") 100
        Move-Item $mp3.Replace(".mp3", ".wav") $wav 
    }
}

function Get-Passage ($Uri) {

    $job = Start-Job { 
        param($Uri)
        . C:\github\powershell\Utility.ps1
        $ie = Invoke-InternetExplorer $Uri 
        $passageHtml = ""

        foreach($item in $ie.Document.IHTMLDocument3_getElementsByTagName("span")) {
            if ($item.className -ne "text" -or $item.tagName -ne "span") { continue }
            if ($item.firstChild.tagName -eq "img") {
                $item.removeChild($item.firstChild)
                $passageHtml = "<span id=`"arrow`"></span>"
            }
            if ($item.previousSibling.className -eq "time") {
                $passageHtml += $item.previousSibling.outerHTML
            }
            $passageHtml += $item.innerHTML
            if ($item.parentNode.nextSibling.tagName -eq "br") { 
                $passageHtml += "</p><p>"
            }
        }
        $passageHtml = $passageHtml.Replace("</span><span class=`"underline`">", "</span> <span class=`"underline`">")
        "<p>$passageHtml".Remove($passageHtml.Length, 3).Replace("<br>")
    } -Arg $Uri

    Wait-Job $job
    $result = Receive-Job $job 
    Remove-Job $job
    if ($result.Count -gt 1) { 
        $i = 0
        while($result[$i].GetType().Name -ne "String") {$i++}
        $result = $result[$i] 
    }
    Remove-Characters $result
}


function New-TPOHtml () {
    
    function New-Html ($Content, $Path) {
    
        if ($Path.Contains("listening")) {
            if ($Content.Contains("</span></span>")) {
                while($Content.Contains("</span></span>")) {
                    $Content = $Content.Replace("</span></span>", "</span>").Replace("<span class=`"highlight`"><span class=`"highlight`">", "<span class=`"highlight`">")
                }
            }
            #else { return }
        }
    
        $html = [xml](Get-Content "C:\github\gre\notes\vocabulary.html") # create empty teamplate html
    
        # Create title Node and Add title
        $titles = $Path.Split('\\')[-1].TrimEnd(".html").Split('-')
        
        $innerText = $titles[0].ToUpper() + " " + ($titles[1].Substring(0,1).ToUpper() + 
        $titles[1].Substring(1,$titles[1].length - 1)).insert($titles[1].length - 1, " ")
        Add-XmlNode ("title", $innerText) (Select-Xml "//head" $html).Node $true | Out-Null
    
        # Add Select Question 
        if ($titles[1].Contains("reading") -or $titles[1].Contains("listening")) {
            $prefix = "$($titles[0])\*\$($titles[0] + $titles[1].Substring(0,1) + $titles[1].Substring($titles[1].Length - 1, 1))"
            $n = 1
            $questionsDiv = Add-XmlNode ("div", @{id = "questions"}) (Select-Xml "//main" $html).Node
            foreach ($item in Get-ChildItem "$xmlPath\$prefix*Q*.xml") {
                Write-Host $item.BaseName
                $xml = [xml] (Get-Content $item.FullName)
                $questionDiv = Add-XmlNode ("div", @{id = "question$n"}) $questionsDiv
                $div = Add-XmlNode ("div") $questionDiv
                
                $replay = ConvertTo-HtmlName $item.Name
                $replay = $Path.Replace($Path.Split("\")[-1]) + $replay.insert($replay.length - 4, "-replay").replace("xml", "mp3")
                if (Test-Path $replay) {  $div.SetAttribute("class", "replay")  }
    
                $p = Add-XmlNode ("p", $xml.TestItem.Stem) $div
                $nodes = (Select-Xml "//Distractor" $xml)
                $type = if ($xml.TestItem.Key.Trim(" ").Length -gt 1) { "checkbox" } else { "radio" }
    
                if ($xml.TestItem.Box) {
                    $type = "radio"
                    $table = Add-XmlNode ("table", @{class="w3-border w3-bordered w3-table"}) $div
    
                    # thead
                    $thead = Add-XmlNode ("thead") $table
                    $tr = Add-XmlNode ("tr") $thead
                    
                    $category = (Select-Xml "//Category" $xml)
                    Add-XmlNode ("th") $tr | Out-Null
                    foreach($column in $category) {
                        Add-XmlNode ("th", $column.Node.innerText) $tr | Out-Null
                    }
    
                    # tbody
                    $tbody = Add-XmlNode ("tbody") $table
                    $j = 1
                    foreach ($node in $nodes) {
                        $tr = Add-XmlNode ("tr") $tbody
                        Add-XmlNode ("td", $node.Node.InnerText) $tr | Out-Null
    
                        foreach($column in $category) {
                            $td = Add-XmlNode ("td") $tr

                            $label = Add-XmlNode ("label", @{class = "my-label"}) $td
                            Add-XmlNode ("input", @{type = $type; name = "$type$j"}) $label | Out-Null
                            Add-XmlNode ("span", @{class = "my-$type"}) $label | Out-Null
                        }
                        $j++
                    }
                }
                elseif ($xml.TestItem.CLASS.Contains("draggy")) {
                    if ($xml.TestItem.Stem.Contains("brief summary")) {
                        $choices = (Select-Xml "//tpObject_list" $xml).Node.InnerXml -replace "tpObject", "p" -replace "(\d{1,3}\,){4}"
                        Add-XmlNode ("div", @{class="choices"}, $choices) $questionDiv | Out-Null
                        $p.innerText = ($questionDiv.div)[1].p[-1]
                        $questionDiv.ChildNodes[2].RemoveChild($questionDiv.ChildNodes[2].LastChild)
                    }
                    else {
                        $table = Add-XmlNode ("table", @{class="w3-border w3-bordered w3-table"}) $div
    
                        # thead
                        $thead = Add-XmlNode ("thead") $table
                        $tr = Add-XmlNode ("tr") $thead
                        Add-XmlNode ("th") $tr | Out-Null
                        for ($i = -3; $i -lt -1; $i++) {
                            $innerText = $nodes[$i].Node.InnerText
                            $innerText = $innerText.Substring($innerText.IndexOf(",0,") + 3)
                            Add-XmlNode ("th", $innerText) $tr | Out-Null
                        }
    
                        # tbody
                        $tbody = Add-XmlNode ("tbody") $table
                        for ($i = 0; $i -lt $nodes.Count - 3; $i++) {
                            $tr = Add-XmlNode ("tr") $tbody
                            $innerText = $nodes[$i].Node.InnerText
                            $innerText = $innerText.Substring($innerText.IndexOf(",0,") + 3)
                            Add-XmlNode ("td", $innerText) $tr | Out-Null
    
                            for ($j = 0; $j -lt 2; $j++) {
                                $td = Add-XmlNode ("td") $tr

                                $label = Add-XmlNode ("label", @{class = "my-label"}) $td
                                Add-XmlNode ("input", @{type = $type; name = "$type$i"}) $label | Out-Null
                                Add-XmlNode ("span", @{class = "my-$type"}) $label | Out-Null
                            }
                        }
                        $innerText = $nodes[$nodes.Count - 1].Node.InnerText
                        $p.innerText = $innerText.Substring($innerText.IndexOf(",0,") + 3)
                    }
                }
                elseif ($xml.TestItem.CLASS.Contains("insertText")) {
                    $p.innerText = $nodes.Node.innerText
                    $choices = ""
                    for ($i = 1; $i -le 4; $i++) {
                        $choices += "<p>$([char]($i + 64))</p>"
                    }
                    Add-XmlNode ("div", @{class="choices"}, $choices) $questionDiv | Out-Null
                }
                else {
                    if ($false -and $titles[1].Contains("listening")) { 
                        Add-XmlNode ("audio", @{src = $Path.Split('\\')[-1].Replace(".html", "-question$n.mp3")}) $div | Out-Null
                        if (Test-Path $replay) {
                            Add-XmlNode ("audio", @{src = $replay.Split('\\')[-1]}) $div | Out-Null
                        }
                    }
                    $choices = (Select-Xml "//Distractor_list" $xml).Node.InnerXml -replace "Distractor", "p"
                    Add-XmlNode ("div", @{class="choices"}, $choices) $questionDiv | Out-Null
                }
    
                # answer
                $answer = ""
                foreach($item in $xml.TestItem.Key.Trim(" ").ToCharArray()) {
                    $answer += [char]([int]$item + 16)
                }
    
                $explanation = $xml.TestItem.Explanation.Replace("`n", "</p><p>") -replace "<p></p>"
                $explanation = Add-XmlNode ("div", @{class="explanation"}, "<p>$explanation</p>") $questionDiv 
                $explanation.SetAttribute("data-answer", $answer)
                $n++
            }
        }
    
        $string = (Format-Xml $html 2).ToString()
        $string = $string.Replace("`"|", "`"<span class=`"highlight`">").Replace("|`"", "</span>`"")
        $string = $string.Replace("$($titles[0])/","").Replace("</span><span class=`"highlight`">", "</span> <span class=`"highlight`">")
                    
    
        ("<!DOCTYPE html>`n" + $string) | Out-File "$Path" -Encoding "utf8"
        if ($titles[1].Contains("reading")) { Add-Highlight "$xmlPath\$prefix*Q*.xml" }
    }
    
    function Add-Highlight($file) {
        $flag = $false
        function Update-Content ($content) {
            $content = $content.Replace("<script src=`"/<span class=`"question$num`">index</span>.js`">", "<script src=`"/index.js`">")
            $content.Replace("-s<span class=`"question$num`">peak</span>ing", "-speaking")
        }
        function Get-Match ($match) {
            $prefix = "(<span class=`"(highlight)? ?(question\d\d?)?`">)?"
            $pattern = "( ?(</span>)?\)?,?;?`"? ?`"?\(?$prefix)?"
            $highlight = $match.TrimEnd(".`"").Replace(",").Replace("`"").Replace(".", "\.").Replace("'", "(</span>)?'")
            $highlight = $highlight.Replace(" ", $pattern).Replace("-", "(</span>)?-$prefix")
            $highlight = "$prefix$highlight ?(</span>)?\.?"
            $selection = ( Get-Content $path -Raw | Select-String $highlight ).Matches
            if ($selection) { $selection = $selection[0].Value.TrimStart(",. ").TrimEnd(", ") }
            $selection
        }
        foreach ($item in Get-ChildItem $file.Replace(".xml", ".txt")) {
            $num = $item.Name.Substring($setsLength + 1, 1)
            $path = "$htmlPath\$sets$number\$sets$number-reading$num.html"
            $content = Get-Content $path -Raw
            $xml = [xml]$content
            $flag = $false
            (Select-String "\[.*?\[" $item.FullName).Matches.ForEach{
                Write-Host $item.FullName
                $match = $_.Value.Trim("[")
                $num = [int]$item.Name.SubString($setsLength + 3, 2)
                foreach ($node in (Select-Xml "//article/p/span[@class='light']" $xml).Node) {
                    $innerText = $node.InnerXml.Replace("</span><span class=`"highlight`">", " ").Replace("<span class=`"highlight`">").Replace("</span>")
                    if ($innerText -ne $match) { continue }
                    if ($node.FirstChild.InnerText -eq $node.InnerText) {
                        $content = $content.Replace("<span class=`"light`"><span class=`"highlight`">", "<span class=`"light`">")
                        $content = $content.Replace("</span></span>", "</span>")
                        while ((Get-AllIndexesOf $content "</span>").Length -ne (Get-AllIndexesOf $content "<span").Length) {
                            $content = $content.Replace("<span class=`"highlight`"><span class=`"highlight`">", "<span class=`"light`">")
                        }

                    }
                    $content = if ($innerText.Contains(" ")) { 
                        $content.Replace("class=`"light`"", "class=`"question$num`"") }
                    else {
                        $content.Replace("class=`"light`"", "class=`"highlight question$num`"")
                    }
                    Set-Content $path (Update-Content $content)
                    $flag = $true
                    break
                }
                if ($flag) { continue }
                if (!$match.Contains(" ")) {
                    $nodes = (Select-Xml "//article/p/span[@class='light']" $xml).Node
                    foreach($node in $nodes) {
                        if ($node.InnerText -ne $match -or $node.parentNode.parentNode.id -match "question") { continue }
                        $content = $content.Replace($node.outerxml, $node.outerxml.Replace("highlight", "highlight question$num"))
                        Set-Content $path (Update-Content $content)
                        $flag = $true
                        break
                    }
                }
                if ($flag) { continue }
                $text = Get-Content $item.FullName -Raw
                $flag = (Get-AllIndexesOf $text $match).Length -gt 1
                if ($flag) {
                    $temp = $match
                    $match = $text.Substring($text.IndexOf("[") - 10, 11 + $match.Length).Replace("[")
                }
                if (!$match.Contains(" ")) { 
                    $content = $content.Replace($match, "<span class=`"question$num`">$match</span>")
                    Set-Content $path (Update-Content $content)
                    continue
                }
                
                $selection = Get-Match $match
                if (!$selection) {
                    if ($flag) {
                        $match = $text.Substring($text.IndexOf("["), 11 + $temp.Length).Replace("[")
                        $selection = Get-Match $match
                    }
                    if (!$selection) {
                        $item.Name
                    }
                }
                if ($flag) { $content = $content.Replace($selection, $selection.Replace($temp, "<span class=`"question$num`">$temp</span>")) }
                else { $content = $content.Replace($selection, "<span class=`"question$num`">$selection</span>") }
                

                Set-Content $path (Update-Content $content)
            }
    
        }
    }

    function Set-Category ($json, $xml, $html) {
        $category = (Select-Xml "//Category" $xml).Node.InnerText.TrimEnd(".")
        $section = ($html | select-string "(?<=-)\w+(?=\d)").Matches.Value
        
        $json.$section.ForEach{
            if ($_.category -eq $category -and !$_.hrefs.Contains($html)) {
                $_.hrefs += , $html
            }
        }
    }

    $json = ConvertFrom-Json ((Get-Content "C:\github\js\category.js" -Raw) -replace "categorys = ")

    (Get-ChildItem "$xmlPath\$sets$number\$("?" * ($setsLength + 2)).xml" -Recurse -File).ForEach{
        #if ($_.BaseName.Contains("S") -or $_.BaseName.Contains("W")) { return }
        $xml = [xml](Get-Content $_.FullName)
        $text = ""
        $node = (Select-Xml "//miniPassageText" $xml).Node
        if ($node) { 
            if ($_.Name -like "*S[34]*") {
                $text = "<section id=`"reading-text`"><h3>Reading Text</h3><article><h4 class=`"w3-center`">" + $node.ParentNode.miniPassageTitle + "</h4><p>" + $node.innerText + "</p></article></section>"
            }
            else {
                $text = $node.innerText.Replace("`n", "</p><p>")
                $text = "<section id=`"reading-text`"><h3>Reading Text</h3><article><p>$text</p></article></section>"
            }
        }
        $node = (Select-Xml "//PassageText" $xml).Node
        if ($node) { 
            $text = $node.InnerXml
            $title = (Select-Xml "//Title" $xml).Node.InnerText
            $text = "<article class=`"passage`"><h4 class=`"w3-center`">$title</h4>$text</article>"
        }
        $node = (Select-Xml "//AudioText" $xml).Node
        if ($node) { 
            $audioText = $node.InnerXml
            if (!$audioText.Contains("<p>")) { $audioText = $audioText.Replace("`n","</p><p>") }
            if ($audioText.StartsWith("<p>")) { $audioText = $audioText.Remove(0,3) }
            if ($audioText.EndsWith("</p>")) { $audioText = $audioText.Remove($audioText.Length - 4,4) }
            $title = (Select-Xml "//Title" $xml).Node.InnerText
            if($title) {$title = "<h4 class=`"w3-center`">$title</h4>"}
            $text += "<div><audio src=`"" + (ConvertTo-HtmlName $_.Name).Replace(".xml", ".mp3") + "`" controls=`"controls`"></audio></div>" + 
            "<article class=`"passage`">$title<p>$audioText</p></article>"
        }
        $node = (Select-Xml "//SampleResponse" $xml).Node
        if ($node) { 
            if ($_.BaseName.Contains("S") -and $false) {
                $text += "<audio src=`"" + (ConvertTo-HtmlName $_.Name).Replace(".xml", "-question.mp3") + "`"></audio>"
                if ($_.Name -like "*S[34]*") {
                    $text += "<audio src=`"" + (ConvertTo-HtmlName $_.Name).Replace(".xml", "-reading.mp3") + "`"></audio>"
                }
            }
            
            $text += "<section id=`"question`"><h4>Question</h4><p>" + $node.ParentNode.Stem + "</p></section>"
            $text += "<section id=`"sample-response`"><h4>Sample Response</h4><article><p>" + $node.innerText.Replace("`n", "</p><p>") + "</p></article></section>"
        }

        
        $html = ConvertTo-HtmlName $_.Name.Replace(".xml", ".html")
        Set-Category $json $xml $html
        $path = "$htmlPath\$($_.Name.Substring(0, $setsLength).ToLower())"
        New-Item $path -ItemType "Directory" -ErrorAction SilentlyContinue | Out-Null
        $text = $text.Replace("<span id=`"arrow`"></span>")
        $text = $text.Replace("<span class=`"underline`">", "<span class=`"highlight`">")  -replace "<p></p>"
        New-Html $text "$path\$html"
    }
    
    Set-Content "C:\github\js\category.js" -Value "categorys = " + (ConvertTo-Json $json) | Out-Null
}


function Get-Translation ($Content) {

    function Start-Translation ($Content, $Count) {
        if (!$Count) { 
            $textarea.value = $Content
            $ie.Document.IHTMLDocument3_getElementById("gt-submit").click() 
        }
        do { 
            if (!$textarea.value) { $textarea.value = $Content }
            Start-Sleep -Milliseconds 1500 
            $result = $ie.Document.IHTMLDocument3_getElementById("result_box")
            if($Count -ne $null -and $Count -lt 2) { $Count++ }
            elseif($Count -ne $null -and $Count -ge 2) { return }

        } until ($result.innerText -and !$result.innerText.Contains("Translating...") -and (($result.innerText.Length -lt 40 -and $Content.TrimEnd(" ").Length -lt 15) -or ($result.innerText.Length -gt 40 -and $result.innerText.TrimEnd(".") -ne $global:temp.TrimEnd(".") )))
        $global:temp = $result.innerText
        $result.innerText
    }

    do {
        Start-Sleep 1
        $textarea = $ie.Document.IHTMLDocument3_getElementById("source")
        if ( $ie.Document.Title.Contains("connect securely to this page") ) {
            $ie.Navigate("https://translate.google.cn/#zh_CN/en")
        }
    } until ($textarea)

    do {
        Start-Sleep 1
        $textarea.value = $Content
    } until ($textarea.value)

    if (!$ie.LocationURL.Contains("#zh-CN")) { 
        if ($ie.LocationURL.Split("/")[3]) { $ie.Navigate($ie.LocationURL.Replace($ie.LocationURL.Split("/")[3], "#zh-CN")) }
    }

    $ie.Document.IHTMLDocument3_getElementById("gt-submit").click()
    $translation = Start-Translation $Content 0

    if(!$translation) { 
        $indexes = Get-AllIndexesOf ($Content -replace "\u3002", "$") "$"
        $midPoint = $indexes[[int](($indexes).Count / 2 )] + 1
        $firstHalf = $Content.Substring(0, $midPoint)
        $secondHalf = $Content.Substring($midPoint, $Content.Length - $midPoint)
        $translation = Start-Translation $firstHalf
        $translation += Start-Translation $secondHalf
    }

    if ($result.innerText -match "[\u4E00-\u9FFF]") {
        $result.innerText
    }
    
    Update-Characters $translation
}

function Set-Translation ($Path) {
    $global:ie = Invoke-InternetExplorer "https://translate.google.cb/#zh_CN/en"
    $element = if($Path.Contains("Q")) { "Explanation" } else { "Category" }
    $files = Get-ChildItem $Path

    foreach($file in $files) {
        $xml = [xml] (Get-Content $file)
        $node = (Select-Xml "//$element" $xml).Node
        if ([regex]::IsMatch($node.InnerText, "[\u4E00-\u9FFF]")) {
            Write-Host $file.BaseName
            $node.InnerText = Get-Translation $node.InnerText
            New-File $xml $file.FullName
        }
    }

}

# Test whether Dependency Program has been installed
function Test-Dependency () {
    # Check Downloader and Audio Converter

    if (!(Test-Path $idmExe)) { 
        "$idmExe Does not Exist"
        exit 
    }

    if (!(Test-Path $switchExe)) { 
        "$switchExe Does not Exist"
        exit
    }

    if (!(Test-Path $xmlPath)) { 
        "$xmlPath Does not Exist"
        exit
    }

    if (!(Test-Path $htmlPath)) { 
        "$htmlPath Does not Exist"
        exit
    }
}

function Get-Key($InnerText) {
    $answer = $InnerText        
    $keys = ""
    foreach($item in $answer.ToCharArray()) {
        $keys += ([int][char]$item - 64).ToString()
    }
    $keys
}
   
function Set-Explanation ($Path, $Link, $Explanation, $set) {
    if (Test-Path $Path) { 
        $flag = $set
        $xml = [xml] (Get-Content $Path)
        $node = (Select-Xml "//Explanation" $xml).Node
        if (!$node) { $flag = $true }
        
        elseif(!$node.innerText -or $node.innerText.Contains("??") -or $node.innerText.Contains("Translating") -or $node.innerText.Length -lt 40 -or ($explanation -and $explanation.TrimEnd(".") -eq $node.innerText.TrimEnd("."))) { $flag = $true }
        if ($flag -or $true) {
            $html = (Invoke-WebRequest $Link)
            $document = $html.ParsedHtml.body
            $textContent = $document.getElementsByClassName("desc")[0].textContent
            if(!$textContent.Contains("`n")) { $textContent = $document.getElementsByClassName("desc")[0].innerText }
            $explanation = $textContent

            if (!$node) { Add-XmlNode ("Explanation", $explanation) (Select-Xml "//TestItem" $xml).Node | Out-Null }
            else {  $node.innerText = $explanation }
            $keys = Get-Key $document.getElementsByClassName("left correctAnswer")[0].children[0].innerText
            (Select-Xml "//Key" $xml).Node.innerText = $keys
            New-File $xml $Path
        }
    }
}

function Set-Category ($Path, $Category, $Title) {
    if (Test-Path $Path) { 
        $xml = [xml] (Get-Content $Path)
        $testItem = (Select-Xml "//TestItem" $xml).Node
        if ($Title) {
            $node = (Select-Xml "//Title" $xml).Node
            if (!$node) { Add-XmlNode ("Title", $Title) $testItem | Out-Null }
            else { $node.innerText = $Title }
        }
        
        $node = (Select-Xml "//Category" $xml).Node
        if (!$node) { Add-XmlNode ("Category", $Category) $testItem | Out-Null }
        elseif(!$node.innerText -or $node.innerText.Contains("??") -or $node.innerText.Contains("Translating") -or $node.innerText.length -gt 40) { $node.innerText = $Category }
        New-File $xml $Path
        #continue 
    }
}

function Test-Category ($Path) {
    $files = Get-ChildItem $Path
    $flag = $true
    foreach($file in $files) {
        $fileFlag = $true
        $xml = [xml] (Get-Content $file)
        $node = (Select-Xml "//Category" $xml).Node
        if (!$node) { 
            $fileFlag = $false
            $flag = $false }
        elseif(!$node.innerText -or $node.innerText.Contains("??") -or $node.innerText.Contains("Translating") -or $node.innerText.length -gt 40) { 
            $fileFlag = $false
            $flag = $false }
        if (!$fileFlag) { Write-Host $file.Name }
    }
    $flag
}

function Test-Explanation ($Path) {
    $files = Get-ChildItem $Path
    $flag = $true
    foreach($file in $files) {
        $fileFlag = $true
        $xml = [xml] (Get-Content $file)
        if ($files.indexOf($file) -eq 0) { continue }
        $explanation = (Select-Xml "//Explanation" ([xml](Get-Content $files[$files.indexOf($file) - 1]))).Node.InnerText
        $node = (Select-Xml "//Explanation" $xml).Node
        if (!$node) { 
            $fileFlag = $false
            $flag = $false }
        elseif(!$node.innerText -or $node.innerText.Contains("??") -or $node.innerText.Contains("Translating") -or $node.innerText.Length -lt 40 -or ($explanation -and $explanation.TrimEnd(".") -eq $node.innerText.TrimEnd("."))) { 
            $fileFlag = $false
            $flag = $false  }
        if (!$fileFlag) { Write-Host $file.Name }
    }
    $flag
}

function Set-Links ($section) {
    
    $global:sectionFlag = if ($section -match "Read|Listen") { $true } else { $false } # Read,Listen or Speak,Write
    $letter = $section.Substring(0, 1)
    $global:prefix = "$sets$number\$section\$sets$number$letter"
    New-Item -Path "$xmlPath\$sets$number\$section" -ItemType "Directory" -ErrorAction SilentlyContinue  | Out-Null
    $global:type = $section.Remove($section.Length - 3, 3).ToLower()

    #$flag = $true
    #$flag = Test-Category ("$xmlPath\$prefix" + "?.xml")
    
    #if ($sectionFlag) { $flag = Test-Explanation "$xmlPath\$prefix*Q*.xml" }

    $global:articles = @()
    $global:links = @()
    $global:category = @() # Require Translate later

    #if ($flag) { return }
    if ($section.Contains("Writ")) { $global:type = "write" }
    $html = (Invoke-WebRequest "$website/$type/$location.html")

    foreach ($item in $html.ParsedHtml.body.getElementsByClassName("title")) {
        if ($item.innerText -like "*$sets$([int]$number)*") { $test = $item }
    }

    # 
    $classes = "btnn2", "btnn2 aspan", "btnn blue", "btnn blue"
    for ($i = 0; $i -lt $sections.Count; $i++) {
        if ($sections[$i] -eq $section) { 
            $className = $classes[$i]
            break
        }
    }
    
    
    foreach ($item in $test.nextSibling.nextSibling.getElementsByClassName($className)) { 
        if ($sectionFlag) { $item = $item.parentNode }
        $global:links += $item.href
        $global:articles += $item.href.Split("-")[1]
    }

    # get category
    $className = if ($sectionFlag) { "item_img_tips" } else { "text_tit" }
    foreach ($item in $test.nextSibling.nextSibling.getElementsByClassName($className)) { 
        if ($sectionFlag) { $item = $item.children[0] }
        $content = $item.innerText
        if ($section.Contains("Listen")) { $content = $item.innerText.Split("-")[1] }
        $global:category += $content
    }
  
    if ($section.Contains("Listen")) {
        $global:titles = @() 
        foreach ($item in $test.nextSibling.nextSibling.getElementsByClassName("item_text_en")) { 
            $global:titles += $item.innerText
        }
    }
}

function Get-Sets ($selectedSection, $set, $question) {
    # Get whole test or one or two sections
    foreach($section in $selectedSection) {
        Set-Links $section
        for ($i = 1; $i -le $links.Count; $i++) {
            if ($set) { $i = $set }
            $global:filePath = "$prefix$i"
            Write-Host $filePath
            #$xmlFile = [xml](Get-Content "$xmlPath\$filePath.xml")
            if(Test-Path "$xmlPath\$filePath.xml") {
                #$innerText = $xmlFile.TestItem.Category
                #if(!([regex]::IsMatch($innerText, "[\u3400-\u9FFF]"))) { $category[$i-1] = $innerText}
            }
            
            $html = (Invoke-WebRequest $links[$i-1])
            $global:document = $html.ParsedHtml.body
            $global:article = $articles[$i-1]

            if ($sectionFlag) {
                
                if ($section -eq "Reading") {
                    $textType = "PassageText"
                    $title = $document.getElementsByClassName("article_tit")[0].innerText
                    $text = $document.getElementsByClassName("article")[0].innerText
                    $text = Format-Paragraphs $text
                    $text = "}$title}`n        $text"
                    $text = $text.Insert(0, " " * (60 - [int]($title.Length/2) ) )
                    $text = $text.Replace("[", "(")
                    $text = $text.Replace("]", ")")
                    New-File $text "$xmlPath\$filePath.txt"
                    
                    $xml = Add-XmlTestItemNode @{CLASS = "view_this_passage_noquest"}
                    Add-XmlChildNodes $xml @("TPPassage", "Title", $textType, "Category") @("$filePath.txt", $title, "", $category[$i-1])
                    
                }
                else {
                    $textType = "AudioText"
                    $xml = Add-XmlTestItemNode @{CLASS = "lecture"}
                    $names = "LecturePicture", "LectureSound", "LecturePicture", "Title", $textType, "Category"
                    $nodes = "$filePath.jpg", "$filePath.wav", "Sampler\GetReady.gif", $titles[$i-1], "", $category[$i-1]
                    Add-XmlChildNodes $xml $names $nodes
                    
                    Get-Audio $links[$i-1] "$xmlPath\$filePath.mp3"
                    #continue
                }
                $count = 0
                while (!$xml.InnerXml.Contains("underline") -and $count -lt 5) {
                    (Select-Xml "//$textType" $xml).Node.InnerXml = (Get-Passage $links[$i-1])[1]
                    $count++
                    New-File $xml "$xmlPath\$filePath.xml"
                }
                
                $questions = @()
                foreach ($item in $document.getElementsByClassName("undone")) {
                    $questions += $item.parentNode.href
                }


                for ($j = 1; $j -le $questions.Count; $j++) {
                    if ($question) { $j = $question }
                    if ($j -lt 10 -and $section -eq "Reading") {$k = "0$j"} else {$k = $j}
                    
                    $global:filePath = "$prefix$($i)Q$k"
                    Write-Host $filePath
        
                    if(Test-Path "$xmlPath\$filePath.xml") {
                        #Set-Explanation "$xmlPath\$filePath.xml" $questions[$j-1] $explanation $set
                        #$explanation = (Select-Xml "//Explanation" ([xml] (Get-Content "$xmlPath\$filePath.xml"))).Node.innerText 
                    }
                    
                    #continue
                    # Question Text
                    $html = (Invoke-WebRequest "$($questions[$j-1])")
                    $global:document = $html.ParsedHtml.body

                    Invoke-Expression "Get-$section"
                }

            }
            else {
                Invoke-Expression "Get-$section `$i"
            }
        }
    }
}

function Get-Reading($set, $question) {

    $names = @("TPPassage")
    $nodes = @("$filePath.txt")
    
    # Add scroll line element if the question number is large
    $names += "TPTopScrollLine"
    $nodes += ([int](($j - 1) * 2.5)).ToString()
    
    $xml = Add-XmlTestItemNode @{CLASS = "passage_ssmc"}

    $text = $document.getElementsByClassName("article")[0]
    $passageText = $text.innerText
    $passageText = Format-Paragraphs $passageText 
    $passageText = "}$title}`n        $passageText"
    $passageText = $passageText.Insert(0, " " * (60 - [int]($title.Length/2) ) )
    $passageText = $passageText.Replace("[", "(")
    $passageText = $passageText.Replace("]", ")")

    $question = $document.getElementsByClassName("left text")[0]

    # Add paragraph mark and paragraph element if question text has "(P|p)aragraph 2" or "paragraphs 3 and 4" 
    $match = ($question.innerText | Select-String "aragraphs? ?(?<Para1>[0-9])( and (?<Para2>[0-9]))?").Matches
    if ($match) {
        $names += "Paragraph"
        $paragraphs = $match[0].Groups["Para1"].Value
        $indexes = Get-AllIndexesOf $passageText ("`n" + " " * 8)
        $passageText = $passageText.Insert($indexes[[int]$paragraphs - 1] + 1, "^6")
        $paragraph2 = $match[0].Groups["Para2"].Value
        if ($paragraph2) {
            $passageText = $passageText.Insert($indexes[[int]$paragraph2 - 1] + 3, "^6")
            $paragraphs += " and $paragraph2"
        }
        $nodes += $paragraphs
    }

    # highlighted Question
    foreach ($highlight in $text.getElementsByClassName("light")) {
        if ((Get-AllIndexesOf $text.innerText $highlight.innerText).Count -gt 1 ) {
            $passageText = Add-Shading $passageText $highlight
        } 
        else {
            $passageText = Update-Characters $passageText.Replace($highlight.innerText, "[$($highlight.innerText)[")
        }
    }
    $questionText = $question.innerText
    foreach ($highlight in $question.getElementsByClassName("light")) {
        $questionText = Update-Characters $questionText.Replace("$($highlight.innerText) ","|$($highlight.innerText)|")
        #$highlight = $questionHighlight[0]
        #$questionText = Add-Shading (Update-Characters $questionText.innerText) $highlight "|"
    }
    
    # Insert Text Question
    if ($questionText.Contains("[")) {
        $xml.TestItem.CLASS = "passage_insertText"

        # Add question sauare
        
        $questionText = (Remove-Characters $questionText).Replace("[]", "[ |    | ]")
        $questionText = $questionText.Replace("]that", "] that")

        # Add passage square 
        $highlights = $text.getElementsByClassName("insert-area")
        for ($k = 0; $k -lt $highlights.Length; $k++)  {
            $indexes = Get-AllIndexesOf (Remove-Characters $highlights[$k].innerText) "["
            $sentence = $highlights[$k].innerText.Replace("[","(").Replace("]",")")

            $startPosition = $passageText.IndexOf($sentence)
            if ($indexes.Count -gt 1) { # 2 squares in one sentence
                $passageText = $passageText.Remove($startPosition, 3)
                $passageText = $passageText.Remove($startPosition + $indexes[1] - 3, 3)
                $passageText = $passageText.Insert($startPosition + $indexes[1] - 3, "|]    ]| ")
                $passageText = $passageText.Insert($startPosition, "|]    ]| ")
                $k++
            }
            else { # square in start 
                $passageText = $passageText.Remove($startPosition + $indexes, 3)
                $passageText = $passageText.Insert($startPosition + $indexes, "|]    ]| ")
            }
        }
    }

    # Add question text node
    $names += "Stem"
    $nodes += (Remove-Characters $questionText).Replace("[ | | ]", "[ |    | ]")
    Add-XmlChildNodes $xml $names $nodes

    # Draggy question
    $draggyFlag = $questionText.Contains("points.") -or $j -eq $questions.Count
    $tableFlag = !$questionText.Contains("brief summary")

    if ($draggyFlag) { 
        Add-XmlNodes $xml $xml.FirstChild @{Name = "TPviewtext"; Attributes = @{PASSAGE = "$filePath.txt"}} | Out-Null
        
        $names = "tpFont", "QuestBmp"
        $nodes = "Arial,12,0", "$filePath.bmp"
        Add-XmlChildNodes $xml $names $nodes

        # Options and Answers location 
        $xCoordinates = "540", "45"
        $yCoordinates = "570"
        $bucketNames = "tpBucket", "tpBucket", "tpBucket"

        if ($tableFlag) {
            $xml.TestItem.CLASS = "draggy_table"
            Copy-Item "$xmlPath\Sampler\draggy_table.bmp" "$xmlPath\$filePath.bmp"

            $bucketNodes = "410,300", "410,350", "410,430", "410,480", "410,530"
            $bucketNames += "tpBucket", "tpBucket"
        }
        else {
            $xml.TestItem.CLASS = "draggy"
            Copy-Item "$xmlPath\Sampler\draggy.bmp" "$xmlPath\$filePath.bmp"

            $bucketNodes = "300,320", "300,400", "300,480"
        }    
    }
    
    # Options
    $names = @()
    $nodes = @()
    $options = $document.getElementsByClassName("ops")
    
    # Draggy question
    if ($draggyFlag) {
        for($k = 1; $k -le $options.Length; $k++) {
            $names += "tpObject"
            if ($tableFlag) { $step = 45 }
            else { $step = 75 }
            $coordinates = "$($xCoordinates[$k % 2]),$([int]$yCoordinates + $step * ([Math]::Ceiling($k / 2) - 1))"
            $nodes += "$coordinates,450,0,$(Remove-Characters $options[$k-1].innerText)"
            $bucketNames += "tpBucket"
            $bucketNodes += $coordinates
        }
    }
    else {
        foreach($option in $options) {
            $names += "Distractor"
            $nodes += Remove-Characters $option.innerText
        }

        Add-XmlChildNodes $xml $names $nodes "Distractor_list"
    }
    

    # Add Draggy Question Summary or category
    if ($draggyFlag) {
        if ($tableFlag) {
            $category = @()
            foreach ($item in $document.getElementsByClassName("grouptext")) {
                $category += $item.innerText
            }
            $questionText = $questionText.Remove(0, $questionText.IndexOf("Directions") + "Directions".Length + 2)
            $index = $category.IndexOf("ANSWER CHOICE")
            $category = if ($index -ne -1) { $category[0..($index-1)] }
            
            <#
            $index = $questionText.IndexOf($category[1].Split(" ")[0].ToLower())
            if ($index -eq -1) { $index = $questionText.IndexOf($category[1].Split(" ")[0]) }
            if ($questionText.Substring(0, $index).Contains("two")) {
            
                [Array]::Reverse($category)
            }
            #>
            for($k = 0; $k -lt $category.Count; $k++) {
                $nodes += "160,$(285 + $k * 140),800,0,$((Get-Culture).TextInfo.ToTitleCase($category[$k].ToLower()))"
            }
            $names += "tpObject", "tpObject", "tpObject"
            $nodes += "200,130,700,0,$(Remove-Characters $questionText)"
        }
        else {
            if (!$questionText.EndsWith(".")) {
                $questionText += "."
            }

            $summary = $questionText.Split(".")[-2]
            $count = 0
            while($summary.Length -lt 20 -or $summary.IndexOf("answer choice") -gt 0) { 
                $count--
                $summary = "$($questionText.Split(".")[$count-2])"
            }
            $names += "tpObject"
            $nodes += "150,240,800,0,$(Remove-Characters $summary)." 
            # !!!!!tpObjects[-1].Substring(tpObjects[-1].IndexOf(",0,") + 3)
        }
        Add-XmlChildNodes $xml $names $nodes "tpObject_list"
        Add-XmlChildNodes $xml $bucketNames $bucketNodes "tpBucket_list"
    }

    # Key
    
    $keys = Get-Key $document.getElementsByClassName("left correctAnswer")[0].children[0].innerText
    
    Add-XmlChildNodes $xml @("Key") @($keys)

    # Add draggy question special answer
    if ($draggyFlag) {
        if ($tableFlag) {
            $pairs = $keys -Split "0"
            $answers = "123456789"
            $keys = "00000"
            foreach($pair in $pairs) {
                if ($pair.Length -lt 3) {
                    for ($l = 0; $l -lt $pair.Length; $l++) {
                        $answers = $answers.Remove([int]$pair[$l].ToString() - 1, 1)
                        $answers = $answers.Insert([int]$pair[$l].ToString() - 1, "0")
                        $keys = $keys.Remove($l, 1)
                        $keys = $keys.Insert($l, $pair[$l])
                    }
                }
                else {
                    for ($l = 0; $l -lt $pair.Length; $l++) {
                        $answers = $answers.Remove([int]$pair[$l].ToString() - 1, 1)
                        $answers = $answers.Insert([int]$pair[$l].ToString() - 1, "0")
                        $keys = $keys.Remove($l + 2, 1)
                        $keys = $keys.Insert($l + 2, $pair[$l])
                    }
                }
            }
        }
        else {
            $answers = "1234567"
            for ($k = 0; $k -lt $keys.Length; $k++) {
                $answers = $answers.Remove([int]$keys.Chars($k).ToString() - 1, 1)
                $answers = $answers.Insert([int]$keys.Chars($k).ToString() - 1, "0")
            }
        }

        $answers = $keys + $answers
        $keys = ""
        for ($k = 0; $k -lt $answers.Length; $k++) {
            $keys += $answers.Chars($k).ToString() + ","
        }
        Add-XmlChildNodes $xml @("specialShowAnswer") @($keys)
    }

    #$explanation = Get-Translation $document.getElementsByClassName("desc")[0].innerText
    Add-XmlChildNodes $xml @("Explanation") @($document.getElementsByClassName("desc")[0].innerText)

    New-File $xml "$xmlPath\$filePath.xml" 
    New-File $passageText "$xmlPath\$filePath.txt"
    if ($question -and $question.GetType() -eq "String") { return }

}

function Get-Listening ($set, $question) {

    # question Text
    $html = (Invoke-WebRequest "$($questions[$j-1])")
    $document = $html.ParsedHtml.body

    $xml = Add-XmlTestItemNode @{CLASS = "ssmc_simple"}
    $questionText = $document.getElementsByClassName("left text")[0].innerText
    $names = "Stem", "StemWav"
    $nodes = (Remove-Characters $questionText), "$filePath.wav"
    Add-XmlChildNodes $xml $names $nodes

    # option
    $names = @()
    $nodes = @()
    $options = @()
    foreach($item in $document.getElementsByClassName("ops")) {
        $options += $item.innerText
    }

    foreach($option in $options) {
        $names += "Distractor"
        $nodes += Remove-Characters $option
    }
    Add-XmlChildNodes $xml $names $nodes "Distractor_list"

    # Key .children[0]
    $answer = $document.getElementsByClassName("left correctAnswer")[0].children[0].innerText
    $keys = ""
    foreach($item in $answer.ToCharArray()) {
        $keys += ([int][char]$item - 64).ToString()
    }
    Add-XmlChildNodes $xml @("Key") @($keys)

    # box
    if ($keys.Length -gt 2) {
        $names = @()
        $nodes = @()
        foreach ($item in $document.getElementsByClassName("name")) {
            $names += "Category"
            $nodes += $item.innerText
        }
        Add-XmlChildNodes $xml $names $nodes "Box"
    }

    # audio link

    Get-Audio "$website/$type/answer.html?&article_id=$article&seqno=$j" "$xmlPath\$prefix$($i)Q$j.mp3"

    # repeat question
    if ($flag) {
        Get-Audio "$website/$type/answer.html?step=2&article_id=$article&seqno=$j"  "$xmlPath\$prefix$($i)Q$j.mp3"
        "$sets$number$letter$($i)Q$($j)R"
        $names = "LecturePicture", "LectureSound"
        $nodes = "Sampler\RplayLec.gif", "$($filePath)R.wav"
        Add-XmlChildNodes $xml $names $nodes "miniLecture"

    }

    #$explanation = Get-Translation $document.getElementsByClassName("desc")[0].innerText
    Add-XmlChildNodes $xml @("Explanation") @($document.getElementsByClassName("desc")[0].innerText)

    New-File $xml "$xmlPath\$filePath.xml" 
}

function Get-Speaking ($i) {

    $xml = Add-XmlTestItemNode `
    @{
        CLASS          = "speaking_paced"; 
        TIMELIMIT      = $time[0][[Math]::Ceiling($i / 2) - 1]; 
        PREPLIMIT      = $time[1][[Math]::Ceiling($i / 2) - 1]; 
        SHOWDIRECTIONS = "FALSE"
    }
    
    if ($i -ne 1 -and $i -ne 2) {
        if ($i -eq 3 -or $i -eq 4) {
            # "miniPassage" 
            $title = $document.getElementsByClassName("article_tit")[0].innerText 
            $article = $document.getElementsByClassName("article")[0].innerText
            
            $names = "miniPassageIntroSound", "miniPassageIntroPic", "miniPassageDuration", "miniPassageTitle", "miniPassageText"
            $nodes = "$($filePath)P.wav", "Sampler\headphon.jpg", 45, $title, (Remove-Characters $article)
            Add-XmlChildNodes $xml $names $nodes "miniPassage"     

            Get-Audio "$website/$type/start-$($articles[$i-1])-13.html?step=getpaper" "$xmlPath\$prefix$($i)P.mp3"
        }
        
        # "miniLecture"
        $names = "LecturePicture", "LectureSound", "LecturePicture"
        $nodes = "$filePath.jpg", "$filePath.wav", "Sampler\SGetReady.gif"
        Add-XmlChildNodes $xml $names $nodes "miniLecture"

        # "AudioText"
        Add-XmlNodes $xml $xml.FirstChild `
        @{
            Name      = "AudioText";
            innerText = (Update-Characters $document.getElementsByClassName("audio_topic")[0].innerText)
        } | Out-Null

        # question text
        $text = $document.getElementsByClassName("article ques")[0].innerText

        #Get Question Audio
        Get-Audio $Links[$i-1] "$xmlPath\$filePath.mp3"

    }
    else { # independent speaking
        # question text
        $text = $document.getElementsByClassName("article")[0].innerText
        if (!$text) { $text = $document.getElementsByClassName("article")[0].nextSibling.innerText }
    }

    # Get Question Audio
    Get-Audio "$website/$type/start-$($articles[$i-1])-13.html?step=getquestion" "$xmlPath\$prefix$($i)Q.mp3"

    $sampleText = $document.getElementsByClassName("ansart")[0].innerText

    $names = "Stem", "StemWav", "SampleResponse", "Category"
    $nodes = `
    @( 
        (Update-Characters $text),
        "$($filePath)Q.wav",
        (Update-Characters $sampleText),
        $category[$i-1]
    )
    Add-XmlChildNodes $xml $names $nodes 

    New-File $xml "$xmlPath\$filePath.xml"
    if ($set) { return }

}

function Get-Writing ($i) {

    if ($i -eq 1) { # Integrated Writing 
        # miniPassage
        $xml = Add-XmlTestItemNode @{CLASS = "writelisten_paced"; TIMELIMIT = "20"; SHOWDIRECTIONS = "FALSE"} 
        $text = $document.getElementsByClassName("article")[0].innerText
        if (!$text) { $text = $document.getElementsByClassName("article")[0].nextSibling.innerText }
        $names = "miniPassageDuration", "miniPassageText"
        $nodes = 180, (Update-Characters $text)
        Add-XmlChildNodes $xml $names $nodes "miniPassage"

        # "LecturePicture", "LectureSound"
        $names = "LecturePicture", "LectureSound", "LecturePicture"
        $nodes = "$filePath.jpg", "$filePath.wav", "Sampler\WGetReady.gif"
        Add-XmlChildNodes $xml $names $nodes "miniLecture"
    
        # "AudioText", "Stem", "StemWav"
        
        $names = "AudioText", "Stem", "StemWav"
        $nodes = `
        @(
            (Update-Characters $document.getElementsByClassName("audio_topic")[0].innerText),
            (Update-Characters $document.getElementsByClassName("tigan")[0].innerText)
            "Sampler\SAWQ.wav"
        )  

        # Audio Link
        Get-Audio $links[$i-1] "$xmlPath\$filePath.mp3"

    }
    else { # Independent Writing Xml
        
        $xml = Add-XmlTestItemNode @{CLASS = "independentwriting_paced"; TIMELIMIT = "30"}
        $questionText = $document.getElementsByClassName("article")[0].innerText
        
        # Question
        $names = @("Stem") 
        $nodes = @(Update-Characters $questionText) 
    }

    # sample Text
    $sampleText = $document.getElementsByClassName("noedit fanwen")[0].innerText
    if (!$sampleText.Contains("`n")) { $sampleText = $document.getElementsByClassName("noedit fanwen")[0].textContent }
    $names += "SampleResponse", "Category"
    $nodes += (Update-Characters $sampleText), $category[$i-1]
    Add-XmlChildNodes $xml $names $nodes

    New-File $xml "$xmlPath\$filePath.xml"
    if ($set) { return }
}


## Script Entrance
$global:website = "https://top.zhan.com/toefl"
$global:sections = "Reading", "Listening", "Speaking", "Writing"
$global:time = @("45", "60", "60"), @("15", "30", "20")
$global:sets = "TPO" 
$global:setsLength = if ($sets -eq "OG") {3} else {5} # folder name length

$global:xmlPath = "$env:USERPROFILE\Downloads\ETS\TOEFL Programs\Sampler\forml1"
$global:htmlPath = "C:\github\toefl\$($sets.ToLower())"
$global:idmExe = "C:\Program Files (x86)\Internet Download Manager\IDMan.exe"
$global:switchExe = "C:\Program Files (x86)\NCH Software\Switch\switch.exe"
$global:temp = ""

Test-Dependency

for ($n = 54; $n -le 54; $n++) 
{   
    $global:number = $n
    $global:tpos = if ($number % 4 -eq 0) { "$number" } else {"$($number - $number % 4 + 4)"}
    $location = if ($sets -eq "TPO") { "alltpo$tpos" } else { $sets.ToLower()} # website 
    if ($number -lt 10 -and $sets -eq "TPO") {$number = "0$number"}
    Write-Host "$sets$number"

    # New Set Number Folder, like \TPO01\ for XML files
    New-Item "$xmlPath\$sets$number\" -ItemType "Directory" -ErrorAction SilentlyContinue | Out-Null
    #Get-Sets $sections # Get sections like $sections[1..2] (Listening and Speaking)
    Set-Translation "$xmlPath\$sets$number\*\TPO*.xml"
    New-TPOHtml

    #return
}
#

#Set-Translation "$xmlPath\TPO*\*\TPO*Q*.xml"

#Get-CategoryString

#Update-SamplerXml 
#Update-Audio #"test"
<#
    $files = Get-ChildItem "$env:USERPROFILE\Downloads\ETS\TOEFL Programs\Sampler\forml1\TPO*\*\TPO*Q*.xml"
    foreach($file in $files) {
        continue
        $xml = [xml] (Get-Content $file)
        $innerText = (Select-Xml "//Explanation" $xml).Node.InnerText
        if ($files.indexOf($file) -eq 0) { continue }
        $previous = (Select-Xml "//Explanation" ([xml](Get-Content $files[$files.indexOf($file) - 1]))).Node.InnerText
        if (!$innerText -or $innerText.length -lt 40 -or ($previous -and $innerText.TrimEnd(".") -eq $previous.TrimEnd("."))) { $file.Name }
    }

    $files = Get-ChildItem "$env:USERPROFILE\Downloads\ETS\TOEFL Programs\Sampler\forml1\TPO*\*\TPO????.xml"
    foreach($file in $files) {
        $xml = [xml] (Get-Content $file)
        $innerText = (Select-Xml "//Category" $xml).Node.InnerText
        if (!$innerText -or $innerText.length -gt 40) { $file.Name }
    }

$explanations = @()
$files = Get-ChildItem "$env:USERPROFILE\Downloads\ETS\TOEFL Programs\Sampler\forml1\TPO*\*\TPO*Q*.xml"
foreach($file in $files) {
    $xml = [xml] (Get-Content $file)
    $innerText = (Select-Xml "//Explanation" $xml).Node.InnerText
    $explanations += $file.BaseName + "| $innerText"
}
for ($i = 0; $i -lt $explanations.Count; $i++) {

    for ($j = $i + 1; $j -lt $explanations.Count; $j++) {
        if( $explanations[$i].Split("|")[1].TrimEnd(".") -eq $explanations[$j].Split("|")[1].TrimEnd(".") ) { 
            Write-Host "`n"
            Write-Host $explanations[$i].Split("|")[0]
            Write-Host $explanations[$j].Split("|")[0]
        }
    }
}
#>