<#
. $PSScriptRoot\Utility.ps1
$number = 4
$content = Get-Content "$PSScriptRoot\..\rp$number.html" -Encoding UTF8 -Raw
$path = "C:\github\toefl\notes\reading-practice$number.html"
$xml = [xml] (Get-Content $path -Encoding UTF8)
$article = (Select-Xml "//article" $xml).Node
$questionsDiv = (Select-Xml "//div[@id='question']" $xml).Node

$lines = Get-Content "$PSScriptRoot\..\rp$number.html" -Encoding UTF8
Add-XmlNode ("h4", @{class = "w3-center"}, $lines[0]) $xml $article | Out-Null
$text = $content.Substring($lines[0].Length, $content.indexOf("`nParagraph ") - $lines[0].Length)
$text = $text.Replace("`r`n", "</p><p>")

$article.InnerXml += "<p>$text</p>" -replace "<p></p>"
$innerXml = $article.InnerXml

$content = Update-Characters $content
$content = [regex]::Replace($content, "\u25CB", "@")
$content = [regex]::Replace($content, "\u25A0", "<7> ")

for($j = 1; $j -le 14; $j++) {
    $match = ($content | Select-String "`n$j.*`n").Matches
    if(!$match) { continue }
    if($match[0].Value -match "Directions") {
        $prefix = $content.indexOf("Answer Choices") + "Answer Choices".Length
        $content = $content.Substring($prefix, $content.Length - $prefix)
            
    }
    if($match[0].Value -match "squares") {
        $content = $content.Replace(($content | Select-String "\[.*\]").Matches[0].Value, "<7>")
        $insertions = ($content | Select-String "<7>.*?\." -AllMatches).Matches
        for($i = 0; $i -lt 4; $i++) {
            $insertion = $insertions[$i].Value.Substring(4, $insertions[$i].Value.Length - 4)
            $innerXml = $innerXml.Replace($insertion, "<span class=`"insert-area`" data-answer=`"" + [char]($i+65) + "`"></span> " + $insertion)
        }
        $start = $content.IndexOf($match[0].Value) + $match[0].Value.Length
        $end = $content.IndexOf("`nWhere would the sentence best fit?")
        $match = $content.Substring($start, $end - $start)
        $prefix = $content.indexOf($match) + $match.Length
        $content = $content.Substring($end, $content.Length - $end)
        $matchXml = $match
    }
    else {
        if($match) { $match = $match[0].Value }
        
        $highlight = ($match | Select-String "`".*`"").Matches
        if($highlight) { 
            if((Get-AllIndexesOf $innerXml $highlight[0].Value.Trim("`"")).Count -lt 2) {
                $innerXml = $innerXml.Replace($highlight[0].Value.Trim("`""), "<span class=`"question$j`">" + $highlight[0].Value.Trim("`"") + "</span>")
            }
            else { 
            Write-Host "Mutilple Ocurrence Question $j" } 
            $matchXml = $match.Replace($highlight[0].Value.Trim("`""), "<span class=`"highlight`">" + $highlight[0].Value.Trim("`"") + "</span>")
            $matchXml = $matchXml.Split(".")[1]
        }
        else {
            $matchXml = $match.Split(".")[1]
        }
        
    }
    $matchXml = $matchXml.TrimStart(" ").TrimEnd("`r`n")
    if($matchXml.Contains("highlighted")) { Write-Host "Highlighted Sentence $j" }
    $questionDiv = Add-XmlNode ("div", @{id = "question$j"}, "") $xml $questionsDiv
    $div = Add-XmlNode ("div", @{}, "") $xml $questionDiv
    $p = Add-XmlNode ("p", @{}, $matchXml) $xml $div
    $type = if ($false) { "checkbox" } else { "radio" }
    $option = $match
    if($match -notmatch "Directions") {
        for($i = 1; $i -le 4; $i++) {

        if($match -match "[1-9].*") {
            $prefix = $content.indexOf($option) + $option.Length
            $content = $content.Substring($prefix, $content.Length - $prefix)
            $option = ($content | Select-String "@.*`n").Matches[0].Value
            $option = $option.TrimStart("@").Substring(0,1).ToUpper() + $option.Substring(2,$option.Length - 2)
        }
        else { 
            $option = ([char]($i+64)).ToString()
        }

        $label = Add-XmlNode ("label", @{class = "my-label"}, "") $xml $div
        Add-XmlNode ("span", @{}, $option.TrimEnd("`r`n")) $xml $label | Out-Null
        Add-XmlNode ("input", @{type = $type; name = $type}, "") $xml $label | Out-Null
        Add-XmlNode ("span", @{class = "my-$type"}, "") $xml $label | Out-Null
    }
    }
    else {
        $type = "checkbox" 
        $table = Add-XmlNode ("table", @{class="w3-border w3-bordered w3-table"}, "") $xml $div
    
        # thead
        $thead = Add-XmlNode ("thead", @{}, "") $xml $table
        $tr = Add-XmlNode ("tr", @{}, "") $xml $thead
        Add-XmlNode ("th", @{}, "") $xml $tr | Out-Null
        for($i = 1; $i -le 2; $i++) {
            Add-XmlNode ("th", @{}, "") $xml $tr | Out-Null
        }
    
        # tbody
        $tbody = Add-XmlNode ("tbody", @{}, "") $xml $table
        $length = (Get-AllIndexesOf $content "`n@").Count
        for($i = 1; $i -le $length; $i++) {

            $prefix = $content.indexOf($option) + $option.Length
            $content = $content.Substring($prefix, $content.Length - $prefix)
            $option = ($content | Select-String "@.*`n").Matches[0].Value
            $option = $option.TrimStart("@").Substring(0,1).ToUpper() + $option.Substring(2,$option.Length - 2)

            $tr = Add-XmlNode ("tr", @{}, "") $xml $tbody
            Add-XmlNode ("td", @{}, $option.TrimEnd("`r`n")) $xml $tr | Out-Null
    
            for($k = 1; $k -le 2; $k++) {
                $td = Add-XmlNode ("td", @{}, "") $xml $tr
                $label = Add-XmlNode ("label", @{class = "my-label"}, "") $xml $td
                Add-XmlNode ("input", @{type = $type; name = "$type$i"}, "") $xml $label | Out-Null
                Add-XmlNode ("span", @{class = "my-$type"}, "") $xml $label | Out-Null
            }
           
        }
    }
    $match = ($content | Select-String "`n$j.*`n").Matches[0].Value
    $answer = ($match.Split("@")[1] | Select-String "[1-4]").Matches[0].Value
    $value = ($content | Select-String ($match + ".*`n") ).Matches[0].Value
    $explanation = $value.Substring($match.Length, $value.Length - $match.Length)

    $div = Add-XmlNode ("div", @{}, "") $xml $questionDiv
    $p = Add-XmlNode ("p", @{}, "") $xml $div
    Add-XmlNode ("span", @{}, "Answer: ") $xml $p | Out-Null
    Add-XmlNode ("span", @{class="answer"}, ([char]([int]$answer+64)).ToString()) $xml $p | Out-Null
    Add-XmlNode ("div", @{class="explanation"}, $explanation.TrimEnd("`r`n")) $xml $div | Out-Null
}
(Select-Xml "//article" $xml).Node.InnerXml = $innerXml
Set-Content $path (Format-Xml $xml.OuterXml -Indent 2).Replace("html", "html") -Encoding UTF8

#>
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
        Add-XmlNode ("title", @{}, "") $xml $head | Out-Null
    
        # Create Script Element
        Add-XmlNode ("script", @{src = "/initialize.js"}, "") $xml $head | Out-Null
    
        # Create body Node
        $body = Add-XmlNode ("body", @{class = "w3-light-gray"}, "") $xml $html
        # Create body Node
        $main = Add-XmlNode ("main", @{class = "w3-container"}, $Content) $xml $body

        # Add Select Question 
        if ($Path -match ".*reading|listening.*" ) {
            $match = ($Path | Select-String "[1-9]").Matches[0].value
            $n = 1
            $questionsDiv = Add-XmlNode ("div", @{id = "question"}, "") $xml $main
            foreach ($item in Get-ChildItem "$xmlPath\$prefix*Q*.xml" -include "SAL$match*.xml") {
                if($item.Name.Contains("00")) { continue }
                Write-Host $item.BaseName
                $questionXml = [xml] (Get-Content $item.FullName)
                $questionDiv = Add-XmlNode ("div", @{id = "question$n"}, "") $xml $questionsDiv
                $div = Add-XmlNode ("div", @{}, "") $xml $questionDiv

                $replay = ConvertTo-HtmlName $item.Name
                $replay = $Path.Replace($Path.Split("\")[-1], "") + $replay.insert($replay.length - 4, "-replay").replace("xml", "mp3")
                if (Test-Path $replay) {  $div.SetAttribute("class", "replay")  }

                $p = Add-XmlNode ("p", @{}, $questionXml.TestItem.Stem) $xml $div
                $nodes = (Select-Xml "//Distractor" $questionXml)
                $type = if ($questionXml.TestItem.Key.Trim(" ").Length -gt 1) { "checkbox" } else { "radio" }
    
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
                    if ($questionXml.TestItem.Stem.Contains("brief summary")) {
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
                }
    
                # answer
                $answer = ""
                foreach($item in $questionXml.TestItem.Key.Trim(" ").ToCharArray()) {
                    $answer += [char]([int]$item + 16)
                }
                $div = Add-XmlNode ("div", @{}, "") $xml $questionDiv
                $p = Add-XmlNode ("p", @{}, "") $xml $div
                Add-XmlNode ("span", @{}, "Answer: ") $xml $p | Out-Null
                Add-XmlNode ("span", @{class="answer"}, $answer) $xml $p | Out-Null

                #$explanation = $questionXml.TestItem.Explanation.InnerXml
                Add-XmlNode ("div", @{class="my-explanation"}, "") $xml $div | Out-Null
                $n++
            }
        }

        $string = (Format-Xml $xml 2).ToString()
        $string = $string.Replace(" |", " <span class=`"highlight`">").Replace("| ", "</span> ").Replace("|", "</span> ")
        #$string = $string.Replace("</span><span class=`"highlight`">", "</span> <span class=`"highlight`">")
                    

        ("<!DOCTYPE html>`n" + $string) | Out-File "$Path" -Encoding "utf8"
        if ($Path.Contains("reading")) { Add-Highlight "$xmlPath\$prefix*.xml" $Path }
    }

    function Add-Highlight($file, $path) {
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
            if($item.Name.Contains("00")) { continue }
            $num = $item.Name.Substring($setsLength + 1, 1)
            #$path = $Path.Split("\")[-1]
            $content = Get-Content $path -Raw
            $xml = [xml]$content
            
            $flag = $false
            if(!$content.Contains("insert-area")) {
                (Select-String "\].*?\].*?\." $item.FullName -AllMatches).Matches.ForEach{
                
                    #$selection = Get-Match ($_.Value -replace "\s{1,}", " ").TrimStart("|] ")

                    $content = $content.Replace(($_.Value -replace "\s{1,}", " ").TrimStart("|] "), "<span class=`"insert-area`" data-answer=`" `"></span> " + ($_.Value -replace "\s{1,}", " ").TrimStart("|] "))
                    Set-Content $path (Update-Content $content)
                
                }
            }

            (Select-String "\[.*?\[" $item.FullName).Matches.ForEach{
                
                $match = $_.Value.Trim("[")
                $num = [int]$item.Name.SubString($setsLength + 3, 2)
                foreach ($node in (Select-Xml "//article/p/span[@class='light']" $xml).Node) {
                    $innerText = $node.InnerXml.Replace("</span><span class=`"highlight`">", " ").Replace("<span class=`"highlight`">", "").Replace("</span>", "")
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
                    $match = $text.Substring($text.IndexOf("[") - 10, 11 + $match.Length).Replace("[", "")
                }
                if (!$match.Contains(" ")) { 
                    $content = $content.Replace($match, "<span class=`"question$num`">$match</span>")
                    Set-Content $path (Update-Content $content)
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

    #$json = (Get-Content "category.json" -Raw | ConvertFrom-Json).Value
    #if (!$json) { $json = Get-Content "category.json" -Raw | ConvertFrom-Json} 
    
    (Get-ChildItem "$xmlPath\$prefix.xml" -Recurse -File).ForEach{
        #if ($_.BaseName.Contains("S") -or $_.BaseName.Contains("W")) { return }
        $xml = [xml](Get-Content $_.FullName)
        $text = ""
        $node = (Select-Xml "//miniPassageText" $xml).Node
        if ($node) { 
            if ($_.Name -like "*S[34]*") {
                $text = "<section id=`"reading-text`" class=`"w3-section w3-padding w3-white w3-card`"><h3>Reading Text</h3><article><h4 class=`"w3-center highlight`"><b>" + $node.ParentNode.miniPassageTitle + "</b></h4><p>" + $node.innerText + "</p></article></section>"
            }
            else {
                $text = $node.innerText.Replace("`n", "</p><p>")
                $text = "<section id=`"reading-text`"><h3>Reading Text</h3><article><p>" + $text + 
                "</p></article></section>"
                $w++
                $name = "writing$w.html"
            }
        }
        $node = (Select-Xml "//PassageText" $xml).Node
        $node = (Select-Xml "//TPPassage" $xml).Node
        if ($node) { 
            $content = (Get-Content ($_.Directory.FullName + "\" + $node.InnerText) -Raw)
            #$text = $node.InnerXml
            #$title = (Select-Xml "//Title" $xml).Node
            $match = $content | Select-String "}.*}"
            $title = $match.Matches[0].Value.Trim("}")
            $start = $content.IndexOf("}") + 1
            $end = $content.IndexOf("}", $start )
            $title = $content.Substring($start, $end - $start)
            $text = $content.Substring($end + 3, $content.Length - $end - 3).Replace("`r`n       ","</p>`n<p>")
            $text = "<div class=`"w3-section w3-padding w3-white w3-card`"><div id=`"reading-text`"><article><h4 class=`"w3-center`">" + $title + "</h4><p>" + $text + "</p></article></div></div>"
        }
        $node = (Select-Xml "//audio_text" $xml).Node
        if ($node) { 
            $audioText = $node.InnerXml
            if (!$audioText.Contains("<p>")) { $audioText = $audioText.Replace("`n","</p><p>") }
            if ($audioText.StartsWith("<p>")) { $audioText = $audioText.Remove(0,3) }
            if ($audioText.EndsWith("</p>")) { $audioText = $audioText.Remove($audioText.Length - 4,4) }
            $text += "<section id=`"listening-text`" class=`"w3-padding w3-white w3-card`"><h3>Listening Text</h3><audio src=`"" + $_.Name.Replace("SAS", "sample-speaking").Replace(".xml", ".mp3") + "`" controls=`"controls`"></audio><article><p>" + $audioText + "</p></article></section>"
            
        }
        $node = (Select-Xml "//SampleResponse" $xml).Node
        
        if ($node -or $true) { 
            if ($_.BaseName.Contains("S") -and $false) {
                $text += "<audio src=`"" + (ConvertTo-HtmlName $_.Name).Replace(".xml", "-question.mp3") + "`"></audio>"
                if ($_.Name -like "*S[34]*") {
                    $text += "<audio src=`"" + (ConvertTo-HtmlName $_.Name).Replace(".xml", "-reading.mp3") + "`"></audio>"
                }
            }
            $node = $xml.FirstChild.LastChild
            $text += "<section id=`"question`" class=`"w3-section w3-padding w3-white w3-card`"><h4>Question</h4><p>" + $node.ParentNode.Stem + "</p></section>"
            $content = Get-Content ("$PSScriptRoot\..\blog\" + $_.Name -replace "SAS", "sr" -replace "x", "ht")
            
            $text += "<section id=`"sample-response`" class=`"w3-section w3-padding w3-white w3-card`"><h4>Sample Response</h4><audio src=`"" + $_.Name.Replace("SAS", "sample-speaking").Replace(".xml", "-response.mp3") + "`" controls=`"controls`"></audio><article><p>$content</p></article><div>$(Get-Content ("$xmlPath\Sampler\Speaking\" + $_.BaseName + "_annot.txt"))</div></section>"
        }

        #$html = ConvertTo-HtmlName $_.Name.Replace(".xml", ".html")
        
        $name = $_.Name -replace "SAS", "sample-speaking" -replace ".xml", ".html"
        #$name = "sample-listening1.html"
        #New-Item $path -ItemType "Directory" -ErrorAction SilentlyContinue | Out-Null
        $text = $text.Replace("<span id=`"arrow`"></span>", "")
        $text = $text.Replace("<span class=`"underline`">", "<span class=`"highlight`">") -replace "<p></p>"
        New-Html $text "$htmlPath\$name"
    }
    
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
. $PSScriptRoot\Utility.ps1

$global:website = "https://top.zhan.com/toefl"
$global:sections = "Reading", "Listening", "Speaking", "Writing"
$global:time = @("45", "60", "60"), @("15", "30", "20")
$global:sets = "TPO"
$global:setsLength = if ($sets -eq "OG") {3} else {5}
$setsLength = 3
$global:xmlPath = "$env:USERPROFILE\Downloads\ETS\TOEFL Programs\Sampler\forml1"
$global:htmlPath = "C:\github\toefl\notes"
$global:prefix = "Sampler\Speaking\SAS?"
function ConvertTo-XmlName ($Name) {
    $Name = $Name.Remove(4,1) -replace "SA01", "SAR" -replace "SA02", "SAL" -replace "SA03", "SAS" -replace "SA04", "SAW" -replace "00"
    if($Name.Contains("R") -and $Name.Length -gt 4) { $Name = $Name.Insert(4,"Q") }
    elseif($Name.Contains("L") -and $Name.Length -gt 4) { $Name = $Name.Insert(4,"Q") -replace "0" }
    $Name
}

function ConvertTo-HtmlName ($Name) {
    
    $type = $Name.Substring($setsLength, 1)
    $sections.ForEach{
        if ($_.Substring(0,1) -eq $type) { 
            $Name = $Name.Replace($type, "-$_").ToLower()
        }
    }
    $Name -creplace "Q", "-question" -creplace "P\.", "-reading." -creplace "_samp", "-response" -creplace "SAL", "sample-Listeing" -creplace "_a1"
}
(Get-ChildItem "C:\Users\decisactor\Documents\Sound recordings\*.mp3").ForEach{
    #Rename-Item -Path $_.FullName (ConvertTo-HtmlName $_.Name)
    #Rename-Item -Path $_.FullName $_.FullName.Replace("listeing", "listening")
    
}

New-TPOHtml

<#
$explanations = Get-Content "$PSScriptRoot\..\test.html"
$files = Get-ChildItem "$xmlPath\$prefix*Q*.xml"
$files.forEach{
    $xml = [xml](Get-Content $_)
    $element = Select-Xml "//TestItem" $xml
    $nodes = (Select-Xml "//Explanation" $xml).Node
    $nodes.parentNode.RemoveChild($nodes) | Out-Null
    if($files.indexOf($_) -eq $files.Count - 1) { 
        $explanation = ""
        foreach($line in $explanations[[int]$_.BaseName.Substring(5,2)..($explanations.Count - 1)] ) {
            $explanation += "$line`n"
        }
        $explanation = $explanation.TrimEnd("`r`n")
    } else { $explanation = $explanations[[int]$_.BaseName.Substring(5,2)] }
    $explanation = $explanation -replace "`n", "</p>`n<p>"
    #Add-XmlNode ("Explanation", @{}, "<p>$explanation</p>") $Xml $element.Node | Out-Null
    Set-Content (Format-Xml $xml.OuterXml) -Path $_.FullName
}
#>
for ($i = 1; $i -le -5; $i++) {
    $xml = [xml](Get-Content "C:\github\toefl\notes\listening-practice$i.html")
    $content = Get-Content "C:\github\blog\lp$i.html"
    for ($j = 1; $j -le 6; $j++) {
        if(!$xml.OuterXml.Contains("question$j")) {continue}
        $node = (Select-Xml "//div[@id='question$j']" $xml).Node.ChildNodes[1].ChildNodes[1]
        if($i -lt 4) {
            if($false -and !$xml.OuterXml.Contains("question$($j+1)")) {
                $explanation = ""
                foreach($line in $content[$j..($content.Count - 1)] ) {
                    $explanation += "$line`n"
                }
                $explanation = $explanation.TrimEnd("`r`n")
            }
            else {
                $explanation = $content[$j]
            }
            
            $node.InnerXml = ("<p>" + $explanation + "</p>") -replace "`n", "</p>`n<p>"
        }
        $node.SetAttribute("class", "explanation")
    }
    $text = (Format-Xml $xml 2).ToString().Replace("</span><span class=`"highlight`">", "</span> <span class=`"highlight`">")
    Set-Content $text.Replace("html", "html") -Path "C:\github\toefl\notes\listening-practice$i.html"
    return
}
#>