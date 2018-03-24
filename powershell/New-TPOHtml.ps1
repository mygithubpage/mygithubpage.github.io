
. "$PSScriptRoot\Utility.ps1"


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
        if ($_.Substring(0,1) -eq $type) { 
            $Name = $Name.Replace($type, "-$_").ToLower()
        }
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
    Set-Content -Value $file -Path $path
}

function Update-Characters ($string) {
    # https://unicode-table.com
    $string = [regex]::Replace($string, "\u2014", "-") 
    $string = [regex]::Replace($string, "\u2018", "'") 
    $string = [regex]::Replace($string, "\u2019", "'") 
    $string = [regex]::Replace($string, "\u201C", "`"") 
    $string = [regex]::Replace($string, "\u201D", "`"") 
    $string = [regex]::Replace($string, "\u2026", "...") 

    # HTML Code
    $string = [regex]::Replace($string, "\uFF08", "%EF%BC%88") # Fullwidth Left Parenthesis
    $string = [regex]::Replace($string, "\uFF09", "%EF%BC%89") # Fullwidth Right Parenthesis
    $string = [regex]::Replace($string, "\u91CD", "%E9%87%8D") # CJK Unified Ideographs - double 
    $string = [regex]::Replace($string, "\u590D", "%E5%A4%8D") # CJK Unified Ideographs - repeat
    $string = [regex]::Replace($string, "\u542C", "%E5%90%AC") # CJK Unified Ideographs - hear
    $string = [regex]::Replace($string, "\u9898", "%E9%A2%98") # CJK Unified Ideographs - title
    $string = [regex]::Replace($string, "\u76EE", "%E7%9B%AE") # CJK Unified Ideographs - look
    $string = [regex]::Replace($string, "\u90E8", "%E9%83%A8") # CJK Unified Ideographs - part
    $string = [regex]::Replace($string, "\u5206", "%E5%88%86") # CJK Unified Ideographs - divide
    $string = [regex]::Replace($string, "\u9605", "%E9%98%85") # CJK Unified Ideographs - review
    $string = [regex]::Replace($string, "\u8BFB", "%E8%AF%BB") # CJK Unified Ideographs - read
    $string = [regex]::Replace($string, "\u8BED", "%E8%AF%AD") # CJK Unified Ideographs - saying
    $string = [regex]::Replace($string, "\u6BB5", "%E6%AE%B5") # CJK Unified Ideographs - section
    $string = [regex]::Replace($string, "\u97F3", "%E9%9F%B3") # CJK Unified Ideographs - sound
    $string = [regex]::Replace($string, "\u9891", "%E9%A2%91") # CJK Unified Ideographs - frequently
    $string = [regex]::Replace($string, "\u5BF9", "%E5%AF%B9") # CJK Unified Ideographs - facing
    $string = [regex]::Replace($string, "\u8BDD", "%E8%AF%9D") # CJK Unified Ideographs - dialect
    $string = [regex]::Replace($string, "\u95EE", "%E9%97%AE") # CJK Unified Ideographs - ask
    $string = [regex]::Replace($string, "\u5E72", "%E5%B9%B2") # CJK Unified Ideographs - dried
    $string = [regex]::Replace($string, "\u53E3", "%E5%8F%A3") # CJK Unified Ideographs - talk
    $string = [regex]::Replace($string, "\u8BB2", "%E8%AE%B2") # CJK Unified Ideographs - talk
    $string = [regex]::Replace($string, "\u5EA7", "%E5%BA%A7") # CJK Unified Ideographs - base
    $string = [regex]::Replace($string, "\u8BD5", "%E8%AF%95") # CJK Unified Ideographs - test
    $string = [regex]::Replace($string, "\u6F14", "%E6%BC%94") # CJK Unified Ideographs - perform
    $string = [regex]::Replace($string, "\u6307", "%E6%8C%87") # CJK Unified Ideographs - finger
    $string = [regex]::Replace($string, "\u5BFC", "%E5%AF%BC") # CJK Unified Ideographs - direct
    $string = [regex]::Replace($string, "\u5408", "%E5%90%88") # CJK Unified Ideographs - join
    $string = [regex]::Replace($string, "\u5E76", "%E5%B9%B6") # CJK Unified Ideographs - combine
    $string = [regex]::Replace($string, "\u6587", "%E6%96%87") # CJK Unified Ideographs - cultrue
    $string = [regex]::Replace($string, "\u4EF6", "%E4%BB%B6") # CJK Unified Ideographs - matter
    $string
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

    $string = [regex]::Replace($string, "\u2587", "") # Block Elements - Lower Seven Eighths Block
    $string = [regex]::Replace($string, "\u25A0", "") # Geometric Shapes - Black Square
    #>
    Update-Characters $string.Replace("&nbsp;", "") 
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
        "<p>$passageHtml".Remove($passageHtml.Length, 3).Replace("<br>", "")
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

function Add-XmlNode ($Node, $Xml, $Parent, $Before) {
    if (!$Parent) { $Parent = $Xml }
    $element = $Xml.createElement($Node[0])
    foreach ($attribute in $Node[1].GetEnumerator()) { 
        $element.SetAttribute($attribute.Name, $attribute.Value) 
    }
    if ($Node[2] -ne $null) {
        if ($Node[2].Contains("</") -or $Node[2].Contains("</")) { $element.InnerXml = $Node[2] }
        else { $element.InnerText = $Node[2] }
    }
    if (!$Before) {$element = $Parent.appendChild($element)}
    else {
        $element = $Parent.InsertBefore($element, $Parent.FirstChild)
    }
    $element
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

        $xml = ConvertTo-Xml -InputObject $xml
        $xml.RemoveAll()
    
        # Create html Node and Set Attribute lang="en" <html lang="en"></html>
        $html = Add-XmlNode ("html", @{lang = "en"}, "") $xml
    
        # Create head Node
        $head = Add-XmlNode ("head", @{}, "") $xml $html
     
        # Create title Node and Add title
        $titles = $Path.Split('\\')[-1].TrimEnd(".html").Split('-')
        $innerText = $titles[0].ToUpper() + " " + ($titles[1].Substring(0,1).ToUpper() + 
        $titles[1].Substring(1,$titles[1].length - 1)).insert($titles[1].length - 1, " ")
        Add-XmlNode ("title", @{}, $innerText) $xml $head | Out-Null
    
        # Create Script Element
        Add-XmlNode ("script", @{src = "/initialize.js"}, "") $xml $head | Out-Null
    
        # Create body Node
        $body = Add-XmlNode ("body", @{}, "") $xml $html
        # Create body Node
        $main = Add-XmlNode ("main", @{class = "w3-container"}, $Content) $xml $body

        # Add Select Question 
        if ($titles[1].Contains("reading") -or $titles[1].Contains("listening")) {
            $prefix = "$($titles[0])\*\$($titles[0] + $titles[1].Substring(0,1) + $titles[1].Substring($titles[1].Length - 1, 1))"
            $n = 1
            $questionDiv = Add-XmlNode ("div", @{id = "question"}, "") $xml $main
            foreach ($item in Get-ChildItem "$xmlPath\$prefix*Q*.xml") {
                Write-Host $item.BaseName
                $questionXml = [xml] (Get-Content $item.FullName)
                $div = Add-XmlNode ("div", @{id = "question$n"}, "") $xml $questionDiv
                $replay = ConvertTo-HtmlName $item.Name
                $replay = $Path.Replace($Path.Split("\")[-1], "") + $replay.insert($replay.length - 4, "-replay").replace("xml", "mp3")
                if (Test-Path $replay) { 
                    $div.SetAttribute("class", "replay") 
                }
                $p = Add-XmlNode ("p", @{}, $questionXml.TestItem.Stem) $xml $div
                $nodes = (Select-Xml "//Distractor" $questionXml)
                $type = if ($questionXml.TestItem.Key.Length -gt 1) { "checkbox" } else { "radio" }
    
                if ($questionXml.TestItem.Box) {
                    $type = "radio"
                    $table = Add-XmlNode ("table", @{class="w3-border w3-bordered w3-table"}, "") $xml $div
    
                    # thead
                    $thead = Add-XmlNode ("thead", @{}, "") $xml $table
                    $tr = Add-XmlNode ("tr", @{}, "") $xml $thead
                    
                    $category = (Select-Xml "//Category" $questionXml)
                    Add-XmlNode ("th", @{}, "") $xml $tr | Out-Null
                    foreach($column in $category) {
                        Add-XmlNode ("th", @{}, $column.Node.innerText) $xml $tr | Out-Null
                    }
    
                    # tbody
                    $tbody = Add-XmlNode ("tbody", @{}, "") $xml $table
                    $j = 1
                    foreach ($node in $nodes) {
                        $tr = Add-XmlNode ("tr", @{}, "") $xml $tbody
                        Add-XmlNode ("td", @{}, $node.Node.InnerText) $xml $tr | Out-Null
    
                        foreach($column in $category) {
                            $td = Add-XmlNode ("td", @{}, "") $xml $tr
                            $label = Add-XmlNode ("label", @{class = "my-label"}, "") $xml $td
                            Add-XmlNode ("input", @{type = $type; name = "$type$j"}, "") $xml $label | Out-Null
                            Add-XmlNode ("span", @{class = "my-$type"}, "") $xml $label | Out-Null
                        }
                        $j++
                    }
                }
                elseif ($questionXml.TestItem.CLASS.Contains("draggy")) {
                    $nodes = (Select-Xml "//tpObject" $questionXml)
                    if ($questionXml.TestItem.Stem.indexOf("brief summary") -gt 0) {
                        for ($i = 0; $i -lt $nodes.Count - 1; $i++) {
                            $innerText = $nodes[$i].Node.InnerText
                            if (!$innerText) { continue }
                            $innerText = $innerText.Substring($innerText.IndexOf(",0,") + 3)
                            $label = Add-XmlNode ("label", @{class = "my-label"}, "") $xml $div
                            Add-XmlNode ("span", @{}, $innerText) $xml $label | Out-Null
                            Add-XmlNode ("input", @{type = $type; name = $type}, "") $xml $label | Out-Null
                            Add-XmlNode ("span", @{class = "my-$type"}, "") $xml $label | Out-Null
                        }
                        $innerText = $nodes[$i].Node.InnerText
                        $p.innerText = $innerText.Substring($innerText.IndexOf(",0,") + 3)
                    }
                    else {
                        $table = Add-XmlNode ("table", @{class="w3-border w3-bordered w3-table"}, "") $xml $div
    
                        # thead
                        $thead = Add-XmlNode ("thead", @{}, "") $xml $table
                        $tr = Add-XmlNode ("tr", @{}, "") $xml $thead
                        Add-XmlNode ("th", @{}, "") $xml $tr | Out-Null
                        for ($i = -3; $i -lt -1; $i++) {
                            $innerText = $nodes[$i].Node.InnerText
                            $innerText = $innerText.Substring($innerText.IndexOf(",0,") + 3)
                            Add-XmlNode ("th", @{}, $innerText) $xml $tr | Out-Null
                        }
    
                        # tbody
                        $tbody = Add-XmlNode ("tbody", @{}, "") $xml $table
                        for ($i = 0; $i -lt $nodes.Count - 3; $i++) {
                            $tr = Add-XmlNode ("tr", @{}, "") $xml $tbody
                            $innerText = $nodes[$i].Node.InnerText
                            $innerText = $innerText.Substring($innerText.IndexOf(",0,") + 3)
                            Add-XmlNode ("td", @{}, $innerText) $xml $tr | Out-Null
    
                            for ($j = 0; $j -lt 2; $j++) {
                                $td = Add-XmlNode ("td", @{}, "") $xml $tr
                                $label = Add-XmlNode ("label", @{class = "my-label"}, "") $xml $td
                                Add-XmlNode ("input", @{type = $type; name = "$type$i"}, "") $xml $label | Out-Null
                                Add-XmlNode ("span", @{class = "my-$type"}, "") $xml $label | Out-Null
                            }
                        }
                        $innerText = $nodes[$nodes.Count - 1].Node.InnerText
                        $p.innerText = $innerText.Substring($innerText.IndexOf(",0,") + 3)
                    }
                }
                elseif ($questionXml.TestItem.CLASS.Contains("insertText")) {
                    $p.innerText = $nodes.Node.innerText
                    for ($i = 1; $i -le 4; $i++) {
                        $label = Add-XmlNode ("label", @{class = "my-label"}, "") $xml $div
                        Add-XmlNode ("span", @{}, "$([char]($i + 64))") $xml $label | Out-Null
                        Add-XmlNode ("input", @{type = $type; name = $type}, "") $xml $label | Out-Null
                        Add-XmlNode ("span", @{class = "my-$type"}, "") $xml $label | Out-Null
                    }
                }
                else {
                    foreach ($node in $nodes) {
                        $label = Add-XmlNode ("label", @{class = "my-label"}, "") $xml $div
                        Add-XmlNode ("span", @{}, $node.Node.InnerText) $xml $label | Out-Null
                        Add-XmlNode ("input", @{type = $type; name = $type}, "") $xml $label | Out-Null
                        Add-XmlNode ("span", @{class = "my-$type"}, "") $xml $label | Out-Null
                    }
                    if($titles[1].Contains("listening") -and $false) 
                    { 
                        Add-XmlNode ("audio", @{src = $Path.Split('\\')[-1].Replace(".html", "-question$n.mp3")}, "") $xml $div | Out-Null
                        if(Test-Path $replay) {
                            Add-XmlNode ("audio", @{src = $replay.Split('\\')[-1]}, "") $xml $div | Out-Null
                        }
                    }
                }
    
                # answer
                $answer = ""
                foreach($item in $questionXml.TestItem.Key.ToCharArray()) {
                    $answer += [char]([int]$item + 16)
                }
                $p = Add-XmlNode ("p", @{}, "") $xml $div
                Add-XmlNode ("span", @{}, "Answer: ") $xml $p | Out-Null
                Add-XmlNode ("span", @{class="my-answer"}, $answer) $xml $p | Out-Null
                $n++
            }
        }

        $string = (Format-Xml $xml 2).ToString()
        $string = $string.Replace("`"|", "`"<span class=`"highlight`">").Replace("|`"", "</span>`"")
        $string = $string.Replace("$($titles[0])/","").Replace("</span><span class=`"highlight`">", "</span> <span class=`"highlight`">")
                    

        ("<!DOCTYPE html>`n" + $string) | Out-File "$Path" -Encoding "utf8"
        if ($titles[1].Contains("reading")) { Add-Highlight "$xmlPath\$prefix*Q*.xml" }
    }

    function Add-Highlight($file) {
        $flag = $false
        function Update-Content ($content) {
            $content = $content.Replace("<script src=`"/<span class=`"question$num`">initial</span>ize.js`">", "<script src=`"/initialize.js`">")
            $content.Replace("-s<span class=`"question$num`">peak</span>ing", "-speaking")
        }
        function Get-Match ($match) {
            $prefix = "(<span class=`"(highlight)? ?(question\d\d?)?`">)?"
            $pattern = "( ?(</span>)?\)?,?;?`"? ?`"?\(?$prefix)?"
            $highlight = $match.TrimEnd(".`"").Replace(",", "").Replace("`"", "").Replace(".", "\.").Replace("'", "(</span>)?'")
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
                
                $match = $_.Value.Trim("[")
                $num = [int]$item.Name.SubString($setsLength + 3, 2)
                foreach ($node in (Select-Xml "//span[@class='light']" $xml).Node) {
                    $innerText = $node.InnerXml.Replace("</span><span class=`"highlight`">", " ").Replace("<span class=`"highlight`">", "").Replace("</span>", "")
                    if ($innerText -ne $match) { continue }
                    if ($node.FirstChild.InnerText -eq $node.InnerText) {
                        $content = $content.Replace("<span class=`"light`"><span class=`"highlight`">", "<span class=`"light`">")
                        $content = $content.Replace("</span></span>", "</span>")
                        while ((Get-AllIndexesOf $content "</span>").Length -ne (Get-AllIndexesOf $content "<span").Length) {
                            $content = $content.Replace("<span class=`"highlight`"><span class=`"highlight`">", "<span class=`"light`">")
                        }

                    }
                    $content = if($innerText.Contains(" ")) { 
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
                    $nodes = (Select-Xml "//span[@class='highlight']" $xml).Node
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
                    $match = $text.Substring($text.IndexOf("[") - 10, 11 + $match.Length).Replace("[", "")
                }
                if (!$match.Contains(" ")) { 
                    Set-Content $path (Update-Content $content.Replace($match, "<span class=`"question$num`">$match</span>"))
                    continue
                }
                
                $selection = Get-Match $match
                if (!$selection) {
                    if ($flag) {
                        $match = $text.Substring($text.IndexOf("["), 11 + $temp.Length).Replace("[", "")
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

    $json = (Get-Content "Category.json" -Raw | ConvertFrom-Json).Value
    if(!$json) { $json = Get-Content "Category.json" -Raw | ConvertFrom-Json} 
    (Get-ChildItem "$xmlPath\$sets$number\$("?" * ($setsLength + 2)).xml" -Recurse -File).ForEach{
        #if($_.BaseName.Contains("S") -or $_.BaseName.Contains("W")) { return }
        $xml = [xml](Get-Content $_.FullName)
        $text = ""
        $node = (Select-Xml "//miniPassageText" $xml).Node
        if ($node) { 
            if ($_.Name -like "*S[34]*") {
                $text = "<section id=`"reading-text`"><h3>Reading Text</h3><article><h4 class=`"w3-center highlight`"><b>" + $node.ParentNode.miniPassageTitle + "</b></h4><p>" + $node.innerText + "</p></article></section>"
            }
            else {
                $text = $node.innerText.Replace("`n", "</p><p>")
                $text = "<section id=`"reading-text`"><h3>Reading Text</h3><article><p>" + $text + 
                "</p></article></section>"
            }
        }
        $node = (Select-Xml "//PassageText" $xml).Node
        if ($node) { 
            $text = $node.InnerXml
            $title = (Select-Xml "//Title" $xml).Node
            $text = "<div id=`"reading-text`"><article><h4 class=`"w3-center highlight`"><b>" + $title.InnerText + "</b></h4>" + $text + "</article></div>"
        }
        $node = (Select-Xml "//AudioText" $xml).Node
        if ($node) { 
            $audioText = $node.InnerXml
            if(!$audioText.Contains("<p>")) { $audioText = $audioText.Replace("`n","</p><p>") }
            if($audioText.StartsWith("<p>")) { $audioText = $audioText.Remove(0,3) }
            if($audioText.EndsWith("</p>")) { $audioText = $audioText.Remove($audioText.Length - 4,4) }
            $text += "<div><audio src=`"" + (ConvertTo-HtmlName $_.Name).Replace(".xml", ".mp3") + "`" controls=`"controls`"></audio></div>" + 
            "<section id=`"listening-text`"><h3>Listening Text</h3><article><p>" + $audioText + "</p></article></section>"
        }
        $node = (Select-Xml "//SampleResponse" $xml).Node
        if ($node) { 
            if($_.BaseName.Contains("S") -and $false) {
                $text += "<audio src=`"" + (ConvertTo-HtmlName $_.Name).Replace(".xml", "-question.mp3") + "`"></audio>"
                if($_.Name -like "*S[34]*") {
                    $text += "<audio src=`"" + (ConvertTo-HtmlName $_.Name).Replace(".xml", "-reading.mp3") + "`"></audio>"
                }
            }
            
            $text += "<section id=`"question`"><h4>Question</h4><p>" + $node.ParentNode.Stem + "</p></section>"
            $text += "<section id=`"sample-response`"><h4>Sample Response</h4><article><p>" + $node.innerText.Replace("`n", "</p><p>") + "</p></article></section>"
        }

        $html = ConvertTo-HtmlName $_.Name.Replace(".xml", ".html")
        $category = (Select-Xml "//Category" $xml).Node.InnerText.TrimEnd(".")
        $section = $html.split(".")[0].split("-")[1] 
        $index = $sections.IndexOf((Get-Culture).TextInfo.ToTitleCase($section.Remove($section.Length - 1, 1)))

        for ($i = 0; $i -lt $json[$index].Count; $i++) {
            if($json[$index][$i][0] -eq $category) { 
                if(!$json[$index][$i][1].Contains($html)) { 
                    $json[$index][$i][1] += "$html," 
                } 
                break
            }
        }
        if($i -eq $json[$index].Count) {
            $json[$index] += , @((Get-Culture).TextInfo.ToTitleCase($category), "$html,")
        }
        
        $path = "$htmlPath\$($_.Name.Substring(0, $setsLength).ToLower())"
        New-Item $path -ItemType "Directory" -ErrorAction SilentlyContinue | Out-Null
        $text = $text.Replace("<span id=`"arrow`"></span>", "")
        $text = $text.Replace("<p></p>", "").Replace("<span class=`"underline`">", "<span class=`"highlight`">")
        #New-Html $text "$path\$html"
    }
    Set-Content "Category.json" -Value (ConvertTo-Json $json) | Out-Null
}

function Get-Translation ($Content) {
    
    $ie = Invoke-InternetExplorer "https://translate.google.com/#zh_CN/en"
    while(!$textarea) { 
        Start-Sleep 1
        $textarea = $ie.Document.IHTMLDocument3_getElementById("source")
        if ( $ie.Document.Title.Contains("connect securely to this page") ) {
            $ie.Navigate("https://translate.google.com/#zh_CN/en")
        }
    }

    while(!$result.innerText) { 
        Start-Sleep 1
        $textarea.value = $Content
        if($ie.LocationURL -eq "https://translate.google.com/") {
            Set-Clipboard $Content
            return
        }
        $ie.Document.IHTMLDocument3_getElementById("gt-submit").click()
        $result = $ie.Document.IHTMLDocument3_getElementById("result_box")
    }
    if($ie.LocationURL.Contains("auto")) { 
        $ie.Navigate($ie.LocationURL.Replace("auto", "zh-CN")) 
        $result = $ie.Document.IHTMLDocument3_getElementById("result_box")
    }
    while($result.innerText.Contains("Translating.....")) { 
        Start-Sleep 1
        $result = $ie.Document.IHTMLDocument3_getElementById("result_box")
    }
    Update-Characters $result.innerText
}

function Test-Denpendency () {

    # Check Denpendency.Replace($selection, "<span class=`"question$num`">$selection</span>")
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

function Get-Reading() {
    $section = $MyInvocation.MyCommand.Name.Split("-")[1]
    $letter = $section.Substring(0, 1)
    $prefix = "$sets$number\$section\$sets$number$letter"
    New-Item -Path "$xmlPath\$sets$number\$section" -ItemType "Directory" -ErrorAction SilentlyContinue  | Out-Null
    
    
    $flag = $true
    $files = Get-ChildItem "$xmlPath\$sets$number\$section\$sets$number$letter*.xml"

    $type = $section.Remove($section.Length - 3, 3).ToLower()
    $html = (Invoke-WebRequest "$website/$type/$location.html")

    # Get 3 Passage question number 
    foreach ($item in $html.ParsedHtml.body.getElementsByClassName("title")) {
        if ($item.innerText -like "*$sets$([int]$number)*") { $test = $item }
    }

    # Get question number 14 14 14
    $articles = @()
    foreach ($item in $test.nextSibling.nextSibling.getElementsByClassName("total")) {
        $articles += "$($item.previousSibling.previousSibling.id.Split("-")[1]),$($item.innerText)"
    }
    
    $links = @()
    foreach ($item in $test.nextSibling.nextSibling.getElementsByClassName("btnn2")) { 
        $links += $website + $item.parentNode.href.Remove(0,12) 
    }

    $category = @()
    foreach ($item in $test.nextSibling.nextSibling.getElementsByClassName("item_img_tips")) { 
        $category += (Get-Translation $item.children[0].innerText).TrimEnd(".")
    }

    for ($i = 1; $i -le $links.Count; $i++) {
        "$sets$number$letter$i"
        $filePath = "$prefix$i"

        if (Test-Path "$xmlPath\$filePath.xml") { 
            $xml = [xml] (Get-Content "$xmlPath\$filePath.xml")
            $node = (Select-Xml "//Category" $xml).Node
            if(!$node -or !$node.innerText) {
                Add-XmlNode ("Category", @{}, $explanation) $xml (Select-Xml "//TestItem" $xml).Node | Out-Null
                New-File $xml "$xmlPath\$filePath.xml"
            }
            #continue 
        }
        $html = (Invoke-WebRequest $links[$i-1])
        $document = $html.ParsedHtml.body
        
        $questions = @()
        foreach ($item in $document.getElementsByClassName("undone")) {
            $questions += $website + $item.parentNode.href.Remove(0,12)
        }

        # Create passage xml and text
        
        $title = $document.getElementsByClassName("article_tit")[0].innerText
        $xml = Add-XmlTestItemNode @{CLASS = "view_this_passage_noquest"}
        Add-XmlChildNodes $xml @("TPPassage", "Title", "PassageText", "Category") @("$filePath.txt", $title, "", $category[$i-1])

        while (!([xml](Get-Content "$xmlPath\$filePath.xml")).InnerXml.Contains("underline")) {
            (Select-Xml "//PassageText" $xml).Node.InnerXml = (Get-Passage $links[$i-1])[1] 
            New-File $xml "$xmlPath\$filePath.xml" 
        }
        
        $text = $document.getElementsByClassName("article")[0].innerText
        $text = Format-Paragraphs $text
        $text = "}$title}`n        $text"
        $text = $text.Insert(0, " " * (60 - [int]($title.Length/2) ) )
        $text = $text.Replace("[", "(")
        $text = $text.Replace("]", ")")
        New-File $text "$xmlPath\$filePath.txt"

        for ($j = 1; $j -le $questions.Count; $j++) {

            # Add question passage text file
            if ($j -lt 10) {$k = "0$j"} else {$k = $j}
            "$sets$number$letter$($i)Q$k"
            $filePath = "$prefix$($i)Q$k"
            $names = @("TPPassage")
            $nodes = @("$filePath.txt")

            # Add scroll line element if the question number is large
            $names += "TPTopScrollLine"
            $nodes += ([int](($j - 1) * 2.5)).ToString()

            $xml = Add-XmlTestItemNode @{CLASS = "passage_ssmc"}

            # Question Text
            $html = (Invoke-WebRequest "$($questions[$j-1])")
            $document = $html.ParsedHtml.body

                        
            if (Test-Path "$xmlPath\$filePath.xml") { 
                $xml = [xml] (Get-Content "$xmlPath\$filePath.xml")
                $node = (Select-Xml "//Explanation" $xml).Node
                if(!$node -or !$node.innerText) {
                    $explanation = Get-Translation $document.getElementsByClassName("desc")[0].innerText
                    Add-XmlNode ("Explanation", @{}, $explanation) $xml (Select-Xml "//TestItem" $xml).Node | Out-Null
                    New-File $xml "$xmlPath\$filePath.xml"
                }
                continue 
            }

            $text = $document.getElementsByClassName("article")[0]
            $passageText = $text.innerText
            $passageText = Format-Paragraphs $passageText 
            $passageText = "}$title}`n        $passageText"
            $passageText = $passageText.Insert(0, " " * (60 - [int]($title.Length/2) ) )
            $passageText = $passageText.Replace("[", "(")
            $passageText = $passageText.Replace("]", ")")

            $question = $document.getElementsByClassName("left text")[0]

            # Add paragraph mark and paragraph element if question text has "(P|p)aragraph 2" or "paragraphs 3 and 4" 
            $match = ($question.innerText | Select-String "aragraphs? ?(?<Paragraph1>[0-9])( and (?<Paragraph2>[0-9]))?").Matches
            if ($match) {
                $names += "Paragraph"
                $paragraphs = $match[0].Groups["Paragraph1"].Value
                $indexes = Get-AllIndexesOf $passageText ("`n" + " " * 8)
                $passageText = $passageText.Insert($indexes[[int]$paragraphs - 1] + 1, "^6")
                $paragraph2 = $match[0].Groups["Paragraph2"].Value
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
            $draggyFlag = $questionText.Contains("points.")
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
            $answer = $document.getElementsByClassName("left correctAnswer")[0].children[0].innerText        
            $keys = ""
            foreach($item in $answer.ToCharArray()) {
                if ([int][char]$item -lt 60 -or [int][char]$item -gt 80) { 
                    $keys += "0" # Draggy Table Question Spiliter
                    # $key = keys.split("0")
                    # if ($key.Length -lt 3) {tpObjects[-3].Substring(tpObjects[-3].IndexOf(",0,") + 3)}
                    # else {tpObjects[-2].Substring(tpObjects[-2].IndexOf(",0,") + 3)}
                }
                else {
                    $keys += ([int][char]$item - 64).ToString()
                }
            }
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

            $explanation = Get-Translation $document.getElementsByClassName("desc")[0].innerText
            Add-XmlChildNodes $xml @("Explanation") @($explanation)

            New-File $xml "$xmlPath\$filePath.xml" 
            New-File $passageText "$xmlPath\$filePath.txt"
        }
        #>
    }
    
}

function Get-Listening() {
    $section = $MyInvocation.MyCommand.Name.Split("-")[1]
    $letter = $section.Substring(0, 1)

    $prefix = "$sets$number\$section\$sets$number$letter"
    New-Item -Path "$xmlPath\$sets$number\$section" -ItemType "Directory" -ErrorAction SilentlyContinue  | Out-Null
    
    $type = $section.Remove($section.Length - 3, 3).ToLower()
    $html = (Invoke-WebRequest "$website/$type/$location.html")

    foreach ($item in $html.ParsedHtml.body.getElementsByClassName("title")) {
        if ($item.innerText -like "*$sets$([int]$number)*") { $test = $item }
    }

    $articles = @()
    foreach ($item in $test.nextSibling.nextSibling.getElementsByClassName("total")) {
        $articles += "$($item.previousSibling.previousSibling.id.Split("-")[1])"
    }

    $links = @()
    foreach ($item in $test.nextSibling.nextSibling.getElementsByClassName("btnn2 aspan")) { 
        $links += $website + $item.parentNode.href.Remove(0,12) 
    }

    $titles = @() 
    foreach ($item in $test.nextSibling.nextSibling.getElementsByClassName("item_text_en")) { 
        $titles += $item.innerText
    }
    
    $category = @()
    foreach ($item in $test.nextSibling.nextSibling.getElementsByClassName("item_img_tips")) { 
        $category += (Get-Translation $item.children[0].innerText.split("-")[1]).TrimEnd(".")
    }

    for ($i = 1; $i -le $links.Count; $i++) {
        "$sets$number$letter$i"
        $filePath = "$prefix$i"

        if (Test-Path "$xmlPath\$filePath.xml") { 
            $xml = [xml] (Get-Content "$xmlPath\$filePath.xml")
            $node = (Select-Xml "//Category" $xml).Node
            Add-XmlNode ("Title", @{}, $titles[$i-1]) $xml (Select-Xml "//TestItem" $xml).Node | Out-Null
            if(!$node -or !$node.innerText) {
                Add-XmlNode ("Category", @{}, $category[$i-1]) $xml (Select-Xml "//TestItem" $xml).Node | Out-Null
            }
            New-File $xml "$xmlPath\$filePath.xml"
            #continue 
        }
        $html = (Invoke-WebRequest $links[$i-1])
        $document = $html.ParsedHtml.body
        
        $questions = @()
        foreach ($item in $document.getElementsByClassName("undone")) {
            $questions += "$website$($item.parentNode.href.Remove(0,12))"
        }

        # Create passage xml
        $xml = Add-XmlTestItemNode @{CLASS = "lecture"}
        $names = "LecturePicture", "LectureSound", "LecturePicture", "Title", "AudioText", "Category"
        $nodes = "$filePath.jpg", "$filePath.wav", "Sampler\GetReady.gif", $titles[$i-1], "", $category[$i-1]
        Add-XmlChildNodes $xml $names $nodes
        
        Get-Audio $links[$i-1] "$xmlPath\$filePath.mp3"
        
        while (!([xml](Get-Content "$xmlPath\$filePath.xml")).InnerXml.Contains("underline")) {
            (Select-Xml "//AudioText" $xml).Node.InnerXml = (Get-Passage $links[$i-1])[1]             
            New-File $xml "$xmlPath\$filePath.xml"
        }
        
        $article = $articles[$i-1]
        for ($j = 1; $j -le $questions.Count; $j++) {
          
            "$sets$number$letter$($i)Q$j"
            $filePath = "$prefix$($i)Q$j"

            $xml = Add-XmlTestItemNode @{CLASS = "ssmc_simple"}
            
            # question Text
            $html = (Invoke-WebRequest "$($questions[$j-1])")
            $document = $html.ParsedHtml.body
            $questionText = $document.getElementsByClassName("left text")[0].innerText
            $names = "Stem", "StemWav"
            $nodes = (Remove-Characters $questionText), "$filePath.wav"
            Add-XmlChildNodes $xml $names $nodes
            
            if (Test-Path "$xmlPath\$filePath.xml") { 
                $explanation = Get-Translation $document.getElementsByClassName("desc")[0].innerText
                $xml = [xml] (Get-Content "$xmlPath\$filePath.xml")
                $node = (Select-Xml "//Explanation" $xml).Node
                if(!$node -or !$node.innerText) {
                    Add-XmlNode ("Explanation", @{}, $explanation) $xml (Select-Xml "//TestItem" $xml).Node | Out-Null
                    New-File $xml "$xmlPath\$filePath.xml"
                }
                continue 
            }
            
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

            $explanation = Get-Translation $document.getElementsByClassName("desc")[0].innerText
            Add-XmlChildNodes $xml @("Explanation") @($explanation)
            
            New-File $xml "$xmlPath\$filePath.xml" 
        }
        #>
    }

}

function Get-Speaking() {
    $section = $MyInvocation.MyCommand.Name.Split("-")[1]
    $letter = $section.Substring(0, 1)

    $prefix = "$sets$number\$section\$sets$number$letter"
    New-Item -Path "$xmlPath\$sets$number\$section" -ItemType "Directory" -ErrorAction SilentlyContinue  | Out-Null

    $flag = $true
    $files = Get-ChildItem "$xmlPath\$sets$number\$section\$sets$number$letter*.xml"
    foreach($file in $files) {
        $xml = [xml] (Get-Content $file)
        $innerText = (Select-Xml "//Category" $xml).Node.InnerText
        if(!$innerText) { $flag = $false }
    }
    if($flag) { return }

    $type = $section.Remove($section.Length - 3, 3).ToLower()
    $html = (Invoke-WebRequest "$website/$type/$location.html")

    # Get 3 Passage question number 
    foreach ($item in $html.ParsedHtml.body.getElementsByClassName("title")) {
        if ($item.innerText -like "*$sets$([int]$number)*") { $test = $item }
    }

    $articles = @()
    foreach ($item in $test.nextSibling.nextSibling.getElementsByClassName("tpo_talking_item")) { $articles += $item.id.Split("-")[1] }

    $links = @()
    foreach ($item in $test.nextSibling.nextSibling.getElementsByClassName("btnn blue")) { 
        $links += $website + $item.href.Remove(0,12) }

    $category = @()
    foreach ($item in $test.nextSibling.nextSibling.getElementsByClassName("text_tit")) { 
        $category += (Get-Translation $item.innerText).TrimEnd(".")
    }

    for ($i = 1; $i -le $links.Count; $i++) {
        "$sets$number$letter$i"
        $filePath = "$prefix$i"
        
        if (Test-Path "$xmlPath\$filePath.xml") { 
            $xml = [xml] (Get-Content "$xmlPath\$filePath.xml")
            $node = (Select-Xml "//Category" $xml).Node
            if(!$node -or !$node.innerText) {
                Add-XmlNode ("Category", @{}, $category[$i-1]) $xml (Select-Xml "//TestItem" $xml).Node | Out-Null
                New-File $xml "$xmlPath\$filePath.xml"
            }
            continue 
        }
        #>
        $html = (Invoke-WebRequest $links[$i-1])
        $document = $html.ParsedHtml.body
        
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

        $names = "Stem", "StemWav", "SampleResponse", "Subject"
        $nodes = `
        @( 
            (Update-Characters $text),
            "$($filePath)Q.wav",
            (Update-Characters $sampleText),
            $category[$i-1]
        )
        Add-XmlChildNodes $xml $names $nodes 

        New-File $xml "$xmlPath\$filePath.xml"
    }
}

function Get-Writing () {
    $section = $MyInvocation.MyCommand.Name.Split("-")[1]
    $letter = $section.Substring(0, 1)
    $prefix = "$sets$number\$section\$sets$number$letter"
    New-Item -Path "$xmlPath\$sets$number\$section" -ItemType "Directory" -ErrorAction SilentlyContinue  | Out-Null

    $flag = $true
    $files = Get-ChildItem "$xmlPath\$sets$number\$section\$sets$number$letter*.xml"
    foreach($file in $files) {
        $xml = [xml] (Get-Content $file)
        $innerText = (Select-Xml "//Category" $xml).Node.InnerText
        if(!$innerText) { $flag = $false }
    }
    if($flag) { return }

    $html = (Invoke-WebRequest "$website/write/$location.html")

    # Get 3 Passage question number 
    foreach ($item in $html.ParsedHtml.body.getElementsByClassName("title")) {
        if ($item.innerText -like "*$sets$([int]$number)*") { $test = $item }
    }

    $links = @()
    foreach ($item in $test.nextSibling.nextSibling.getElementsByClassName("btnn blue")) { 
        $links += $website + $item.href.Remove(0,12) }

    $category = @()
    foreach ($item in $test.nextSibling.nextSibling.getElementsByClassName("text_tit")) { 
        $category += (Get-Translation $item.innerText).TrimEnd(".")
    }

    for ($i = 1; $i -le $links.Count; $i++) {
        "$sets$number$letter$i"
        $filePath = "$prefix$i"
        
        if (Test-Path "$xmlPath\$filePath.xml") { 
            $xml = [xml] (Get-Content "$xmlPath\$filePath.xml")
            $node = (Select-Xml "//Category" $xml).Node
            if(!$node -or !$node.innerText) {
                Add-XmlNode ("Category", @{}, $category[$i-1]) $xml (Select-Xml "//TestItem" $xml).Node | Out-Null
                New-File $xml "$xmlPath\$filePath.xml"
            }
            continue 
        }
        #>
        $html = (Invoke-WebRequest $links[$i-1])
        $document = $html.ParsedHtml.body

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
                "Summarize the points made in the lecture, being sure to explain how they oppose specific points made in the reading passage.",
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
        $names += "SampleResponse", "Subject"
        $nodes += (Update-Characters $sampleText), $category[$i-1]
        Add-XmlChildNodes $xml $names $nodes

        New-File $xml "$xmlPath\$filePath.xml"
    }
}


function Update-SamplerXml () 
{
    
    $path = "$($xmlPath.Substring(0, $xmlPath.Length - 7))\sampler.xml"
    $content = Get-Content $path
    $content = $content -replace "$sets[0-9]*", "$sets$number"
    [xml]$xml = $content

    foreach ($section in $sections[0..1]) {
        $xmlPrefix = "$xmlPath\$sets$number\$section\$sets$number$($section.Chars(0))"
        $nodes = Select-Xml -Xml $xml -XPath "/TestItem/TESTLET[@LABEL=`"$section`" and @NUMBQUESTS]"
        for ($i = 1; $i -le $nodes.Count; $i++) {
            $count = (Get-ChildItem "$xmlPrefix$($i)Q*.xml").Count
            $node = $nodes[$i - 1].Node
            if ($section -eq "Reading") { $node.NUMBQUESTS = $count.ToString() }
            else {
                if ($i -lt 4) { $question = "123" }
                else { $question = "456" }
                $node.NUMBQUESTS = (Get-ChildItem "$xmlPrefix[$question]Q*.xml").Count.ToString()
            }
            if ($node.QUESTBEGIN) {
                $length = $nodes[$i - 2].Node.TestItemName.Count
                if ($i -eq 3 -or $i -eq 6) { $length += $nodes[$i - 3].Node.TestItemName.Count - 1 }
                $node.QUESTBEGIN = ($length).ToString()
            }
            while ($node.TestItemName.Count - 1 -lt $count) { 
                Add-XmlNodes $xml $node `
                @{
                    Name = "TestItemName"; 
                    innerText = "$sets$number\$section\$sets$number$($section.Chars(0))$($i)Q$($node.TestItemName.Count).xml"
                }
            }
            while ($node.TestItemName.Count - 1 -gt $count) { $node.RemoveChild($node.LastChild) }
        }
    }
    New-File $xml "$($xmlPath.Substring(0, $xmlPath.Length - 7))\sampler.xml" 
}

function Update-Audio ($test) {
    $xmlFiles = Get-ChildItem "$xmlPath\$sets$number\*.xml" -Recurse
    foreach ($xmlFile in $xmlFiles) {
        [xml]$xml = Get-Content $xmlFile
        $node = (Select-Xml "/TestItem[@CLASS!='ssmc_simple']//LectureSound" $xml).Node
        if ($node) { 
            if ($test) { $node.innerText = "Sampler\RLWlistn.wav" }
            else { $node.innerText = $xmlFile.FullName.Substring(60, $xmlFile.FullName.Length - 64) + ".wav" }
        }

        $node = (Select-Xml "/TestItem[@CLASS='speaking_paced']" $xml).Node
        if ($node) {
            if ($test) { 
                $node.Attributes["TIMELIMIT"].Value = 2
                $node.Attributes["PREPLIMIT"].Value = 2
            }
            else {
                $num = [int]$xmlFile.Name.Substring(6,1)
                $node.Attributes["TIMELIMIT"].Value = $time[0][[Math]::Ceiling($num / 2) - 1]
                $node.Attributes["PREPLIMIT"].Value = $time[1][[Math]::Ceiling($num / 2) - 1]
            }
        }

        $node = (Select-Xml "/TestItem[@CLASS='writelisten_paced']//miniPassageDuration" $xml).Node
        if ($node) { 
            if ($test) { $node.innerText = "2" }
            else { $node.innerText = "180" }
        }
        $xml.Save($xmlFile.FullName) 
    }
}

function Get-Score () 
{
    <#
    $scores = @(
        @(23, 23, 24, 25, 26, 26, 26, 27, 27, 28, 28, 29, 29, 30, 30, 30),
        @()
    )#>
    $keys = 
    @(
        @(
            @(1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 1, 123),
            @(1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 1, 123),
            @(1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 1, 123)
        ),
        @(
            @(1, 2, 3, 4, 1),
            @(1, 2, 3, 4, 1, 2),
            @(1, 2, 3, 4, 1, 2),
            @(1, 2, 3, 4, 1),
            @(1, 2, 3, 4, 1, 2),
            @(1, 2, 3, 4, 1, 2)
        )
    )

    $totalPoints = @(45, 34)
    for ($i = 0; $i -lt $keys.Count; $i++) {
        for ($j = 1; $j -le $keys[$i].Count; $j++) {
            for ($k = 1; $k -le $keys[$i][$j - 1].Count; $k++) {
                if ($k -lt 10 -and $i -eq 0) { $l = "0$k" }
                else {$l = $k}
                [xml]$xml = Get-Content "$xmlPath\$sets$number\$($sections[$i])\$sets$number$($sections[$i].Chars(0))$($j)Q$l.xml"
                
                if ($xml.TestItem.Key -ne $keys[$i][$j - 1][$k - 1]) {
                    $totalPoints[$i]--
                    if ($k -eq 14) {
                        $string = $xml.TestItem.Key
                        $point = -3
                        foreach ($character in $string.ToCharArray()) {
                            if (($keys[$i][$j - 1][$k - 1]).ToString().ToCharArray() -contains $character) { $point++ }
                        }
                        $totalPoints[$i] += $point 
                    }
                    Write-Host "$($sections[$i]) passage $j question $k"
                    Write-Host "Correct answer is: $($xml.TestItem.Key)"
                    Write-Host "Your Answer is: $($keys[$i][$j-1][$k-1])"
                }
            }
        }
        Write-Host "$($sections[$i]) raw points: $($totalPoints[$i])"
    }
}



$global:website = "https://top.zhan.com/toefl"
$global:sections = "Reading", "Listening", "Speaking", "Writing"
$global:time = @("45", "60", "60"), @("15", "30", "20")
$global:sets = "TPO"
$global:setsLength = if ($sets -eq "OG") {3} else {5}

$global:xmlPath = "$env:USERPROFILE\Downloads\ETS\TOEFL Programs\Sampler\forml1"
$global:htmlPath = "C:\github\toefl\$($sets.ToLower())"
$global:idmExe = "C:\Program Files (x86)\Internet Download Manager\IDMan.exe"
$global:switchExe = "C:\Program Files (x86)\NCH Software\Switch\switch.exe"

Test-Denpendency

for ($n = 11; $n -le 53; $n++) 
{
    $global:number = $n
    $global:tpos = if ($number % 4 -eq 0) { "$number" } else {"$($number - $number % 4 + 4)"}
    $location = if ($sets -eq "TPO") { "alltpo$tpos" } else { $sets.ToLower()}
    if ($number -lt 10 -and $sets -eq "TPO") {$number = "0$number"}
    New-Item -Path "$xmlPath\$sets$number\" -ItemType "Directory" -ErrorAction SilentlyContinue | Out-Null
    Write-Host "$sets$number"
    Get-Reading
    Get-Listening 
    Get-Speaking 
    Get-Writing
    #New-TPOHtml
}

#Update-SamplerXml 
#Update-Audio #"test"