
. "$PSScriptRoot\Utility.ps1"



function Add-XmlNodes ($xml, $parentNode, $nodes) {
    foreach ($node in $nodes) {
        $xmlElement = $xml.CreateElement($node.Name)
        $xmlElement.innerText = $node.innerText
        try {
            foreach ($attribute in $node.attributes.GetEnumerator()){ $xmlElement.SetAttribute($attribute.Name, $attribute.Value) }
        }
        catch {}
        $parentNode.AppendChild($xmlElement)
        $xmlElement
    }
}

function Add-XmlTestItemNode($attributes) {
    $xml = ConvertTo-Xml -InputObject $xml
    $xml.RemoveAll()

    $node = @{ Name = "TestItem"; Attributes = $attributes }
    Add-XmlNodes $xml $xml $node | Out-Null
    $xml
}

function Add-XmlChildNodes($xml, $names, $innerTexts, $type) {
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
        if($_.Substring(0,1) -eq $type) { 
            $Name = $Name.Replace($type, "-$_").ToLower()
        }
    }
    $Name -creplace "q", "-question" -creplace "p\.", "-reading." -creplace "r\.", "-replay."
}

function New-File($file, $path) {
    New-Item $path -ErrorAction SilentlyContinue | Out-Null
    if ($file.GetType().Name -eq "XmlDocument") {$file = Format-Xml $file}
    Set-Content -Value $file -Path $path
}

function Update-Characters($string) {
    # unicode-table.com
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
    $string = [regex]::Replace($string, "\u9898", "%E9%A2%98") # CJK Unified Ideographs - question
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
    $string = [regex]::Replace($string, "\u8BB2", "%E8%AE%B2") # CJK Unified Ideographs - talk
    $string = [regex]::Replace($string, "\u5EA7", "%E5%BA%A7") # CJK Unified Ideographs - base
    $string
}

function Format-Paragraphs($string) {
    $string = $string -replace "\s*`r`n\s*", "`r"
    $string = $string -replace "`r`n`r`n", "`r"
    while($string.Contains("  ")) { $string = $string.Replace("  ", " ") }
    $string = $string.Replace("`r", "`n" + " " * 8)
    Update-Characters $string
}

function Add-Shading($text, $highlight) {

    $sentenceIndex = $text.IndexOf($highlight.parentNode.innerText)
    $selectionIndex = $highlight.parentNode.innerHTML.IndexOf('<span class="light">')

    # if innerText has img tag
    if($highlight.parentNode.firstChild.tagName -eq "img") {
        $imgLength = $highlight.parentNode.firstChild.outerHTML.Length
        $selectionIndex -= $imgLength
    }

    # if innerText has insert-area tag
    $index = $highlight.parentNode.innerHTML.IndexOf("data-answer=") + 23
    if($index -ne 22 -and $selectionIndex -gt $index) { $selectionIndex -= $index }

    $selection = $highlight.innerText
    $text = $text.Insert($selectionIndex + $sentenceIndex, "[")
    $startIndex = $selectionIndex + $sentenceIndex + $selection.Length + 1
    if($selection.Substring($selection.Length - 1, 1) -eq " ") { $startIndex-- }
    $text = $text.Insert($startIndex, "[")
    $text
}

function Remove-Characters($string) {
    <#
    if ($type -eq "selection") {$digit = "0-9"}
    $character = "[^A-za-z$digit!#$%&'()*+,./:;<=>?@\^_`{}~-]"
    while ($string -and $string.Substring(0, 1) -match $character) { $string = $string.Remove(0, 1) } 
    while ($string -and $string.Substring($string.Length - 1, 1) -match $character) { $string = $string.Remove($string.Length - 1, 1) } 
    if ($type -eq "question") { while ($string.Substring(0, 1) -match "[^A-Za-z]") { $string = $string.Remove(0, 1) } }
    while($string.Contains("  ")) { $string = $string.Replace("  ", " ") }
    #>
    while ($string.Substring(0, 1) -eq " ") { $string = $string.Remove(0, 1) } 
    while ($string.Substring($string.Length - 1, 1) -eq " ") { $string = $string.Remove($string.Length - 1, 1) } 
    while ($string.Contains("  ")) { $string = $string.Replace("  ", " ") }

    $string = [regex]::Replace($string, "\u2587", "") # Block Elements - Lower Seven Eighths Block
    $string = [regex]::Replace($string, "\u25A0", "") # Geometric Shapes - Black Square
    #>
    Update-Characters $string.Replace("&nbsp;", "") 
}

function Get-Audio ($Link, $Path) {
    $global:flag = $false
    $audioName = $Path.Split("\")[-1]
    # Download mp3
    $mp3 = "$htmlPath\$(($sets + $number).ToLower())\" + (ConvertTo-HtmlName $audioName)
    if (Test-Path $mp3) { Write-Host "$mp3 Exist" }
    else {
        
        $file = "$sets$number.html"
        if(!(Test-Path $file)) { Invoke-WebRequest $Link -OutFile $file }

        $html = Get-Content $file -Encoding UTF8
        foreach($line in $html) {
            # Listen again to part of the conversation.
            if($line.IndexOf("Listen again to part of the conversation.") -gt 0) { $global:flag = $true } 
            $end = $line.IndexOf(".mp3") + 4
            $start = $line.IndexOf("https://")
            if($end -ne 3 -and $start -ne -1 -and $line.IndexOf("speaking_beep_prepare") -eq -1) {
                $audioLink = Update-Characters $line.Substring($start, $end - $start)
            }
        }
        Remove-Item $file
        if($flag) { 
            $audioName = $audioName.Insert($audioName.Length - 4, "R") 
            $mp3 = $mp3.Insert($mp3.Length - 4, "-replay") 
            $Path = $Path.Insert($Path.Length - 4, "R") 
        }

        Write-Host "Downloading" $audioName
        & $idmExe /n /d $audioLink -p "$htmlPath\$(($sets + $number).ToLower())\" -f (ConvertTo-HtmlName $audioName)
        while (!(Test-Path $mp3)) {} # Wait for downloading completed
    }

    # Convert mp3
    $wav = $Path.Replace(".mp3", ".wav")
    if ((Test-Path $mp3.Replace(".mp3", ".wav")) -or (Test-Path $wav)) { Write-Host "$($mp3.Replace(".mp3", ".wav")) Exist" }
    else {
        Write-Host "Converting" $mp3.Split("\")[-1]
        & $switchExe -convert $mp3 -overwrite always -hide -format .wav -settings .wav PCM16 22050 2
        while (!(Test-Path $mp3.Replace(".mp3", ".wav"))) {} # Wait for converting completed
    }

    if(!(Test-Path $wav)) { 
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

        foreach($item in $ie.Document.IHTMLDocument3_getElementsByTagName("span")){
            if ($item.className -ne "text" -or $item.tagName -ne "span") { continue }
            if($item.firstChild.tagName -eq "img") {
                $item.removeChild($item.firstChild)
                $passageHtml = "<span id=`"arrow`"></span>"
            }
            if($item.previousSibling.className -eq "time") {
                $passageHtml += $item.previousSibling.outerHTML
            }
            $passageHtml += $item.innerHTML
            if($item.parentNode.nextSibling.tagName -eq "br") { 
                $passageHtml += "</p><p>"
            }
        }
        $passageHtml = $passageHtml.Replace("</span><span class=`"underline`">", "</span> <span class=`"underline`">")
        "<p>$passageHtml".Remove($passageHtml.Length, 3).Replace("<br>", "")
    } -Arg $Uri

    Wait-Job $job
    $result = Receive-Job $job 
    Remove-Job $job
    if ($result.Count -gt 1) { $result = $result[1] }
    Remove-Characters $result
}

function New-Html ($Content, $Path) {

    $xml = ConvertTo-Xml -InputObject $xml
    $xml.RemoveAll()

    # Create html Node and Set Attribute lang="en" <html lang="en"></html>
    $htmlNode = $xml.CreateElement("html")
    $htmlNode.innerText = ""
    $htmlNode.SetAttribute("lang", "en")
    $htmlNode = $xml.AppendChild($htmlNode)

    # Create head Node
    $headNode = $xml.CreateElement("head")
    $headNode.innerText = ""
    $htmlNode.AppendChild($headNode) | Out-Null
 
    # Create title Node and Add title
    $titleNode = $xml.CreateElement("title")
    $title = $Path.Split('\\')[-1].TrimEnd('.html').Split('-')
    $titleNode.InnerText = $title[0].ToUpper() + " " + ($title[1].Substring(0,1).ToUpper() + 
    $title[1].Substring(1,$title[1].length - 1)).insert($title[1].length - 1, " ")
    $headNode.AppendChild($titleNode) | Out-Null

    # Create Script Element
    $scriptNode = $xml.CreateElement("script")
    $scriptNode.SetAttribute("src", "/initialize.js") 
    $scriptNode.InnerText = ""
    $headNode.AppendChild($scriptNode) | Out-Null


    # Create body Node
    $bodyNode = $xml.CreateElement("body") 
    $bodyNode.InnerText = ""
    $htmlNode.AppendChild($bodyNode) | Out-Null

    # Create body Node
    $mainNode = $xml.CreateElement("main") 
    $mainNode.SetAttribute("class", "w3-container") 
    $mainNode.InnerText = ""
    $bodyNode.AppendChild($mainNode) | Out-Null

    # Add Content
    $cdata = $xml.CreateCDataSection($Content)
    $mainNode.AppendChild($cdata) | Out-Null
    $xml.InnerXml = $xml.InnerXml.Replace("<![CDATA[", "").Replace("]]>", "")

    $file = "$htmlPath\$($sets.ToLower()).html"
    # Add Navigation
    $node = (Select-Xml "//div[@id='$($title[0])']" ([xml](Get-Content $file))).Node
    $div = $xml.CreateElement("div")
    $div.SetAttribute("class", "w3-bar w3-margin-bottom")
    $div.SetAttribute("id", $title[0])
    $div.InnerXml = $node.InnerXml
    $div.RemoveChild($div.FirstChild) | Out-Null
    (Select-Xml "//main" $xml).Node.InsertBefore($div, (Select-Xml "//main" $xml).Node.FirstChild) | Out-Null
    
    # Add Previous Next Button
    
    $htmls = Get-ChildItem "$htmlPath\$($title[0])\*.html" | ForEach-Object {$_.Name}
    $index = $htmls.IndexOf($Path.Split('\\')[-1])
    
    $div = $xml.CreateElement("div")
    $div.SetAttribute("class", "w3-bar w3-margin-top")
    
    $a = $xml.CreateElement("a")
    $a.SetAttribute("href", $htmls[$index - 1])
    $a.SetAttribute("class", "w3-btn w3-left my-color")
    $a.InnerText = "Previous"
    $div.AppendChild($a) | Out-Null

    if($index -eq $htmls.Count - 1) { $index = -1 }
    $a = $xml.CreateElement("a")
    $a.SetAttribute("href", $htmls[$index + 1])
    $a.SetAttribute("class", "w3-btn w3-right my-color")
    $a.InnerText = "Next"
    $div.AppendChild($a) | Out-Null
    (Select-Xml "//main" $xml).Node.AppendChild($div) | Out-Null

    $string = (Format-Xml $xml 2).ToString()
    $string = $string.Replace("$($title[0])/","").Replace("</span><span class=`"underline`">", "</span> <span class=`"underline`">")
    ("<!DOCTYPE html>`n" + $string) | Out-File $Path -Encoding "utf8"
}

function New-TPOHtml() {
    
    (Get-ChildItem "$xmlPath\$sets$number\$("?" * ($setsLength + 2)).xml" -Recurse -File).ForEach{
        $xml = [xml](Get-Content $_.FullName)
        $text = ""
        $node = (Select-Xml "//miniPassageText" $xml).Node
        if ($node) { 
            if ($_.Name -like "*S[34]*") {
                $text = "<section id=`"reading-text`"><h3>Reading Text</h3><article><h4 class=`"w3-center`">" + $node.ParentNode.miniPassageTitle + "</h4>" + $node.innerText + "</article></section><hr/>"
            }
            else {
                $text = $node.innerText
                $text = "<section id=`"reading-text`"><h3>Reading Text</h3><article>" + $text + 
                "</article></section><hr/>"
            }
        }
        $node = (Select-Xml "//PassageText" $xml).Node
        if ($node) { 
            $text = $node.InnerXml
            $title = (Select-Xml "//Title" $xml).Node
            $text = "<div id=`"reading-text`"><article><h4 class=`"w3-center`"><b>" + $title.InnerText + "</b></h4>" + $text + "</article></div>"
        }
        $node = (Select-Xml "//AudioText" $xml).Node
        if ($node) { 
            $audioText = $node.InnerXml
            
            $text += "<div><audio src=`"" + (ConvertTo-HtmlName $_.Name).Replace(".xml", ".mp3") + "`" controls=`"controls`"></audio></div>" + 
            "<section id=`"listening-text`"><h3>Listening Text</h3><article>" + $audioText + "</article></section>"
        }
        $node = (Select-Xml "//SampleResponse" $xml).Node
        if ($node) { 
            if ($_.Name -like "*S[12]*" -or $_.Name -like "*W[12]*") {
                $text += "<hr/><section id=`"question`"><h4>Question</h4>" + $node.ParentNode.Stem + "</section>"
            }
            $text += "<hr/><section id=`"sample-response`"><h4>Sample Response</h4><article>" + $node.innerText + "</article></section>"
        }

        $path = "$htmlPath\$($_.Name.Substring(0, $setsLength).ToLower())"
        New-Item $path -ItemType "Directory" -ErrorAction SilentlyContinue | Out-Null
        New-Html $text "$path\$(ConvertTo-HtmlName $_.Name.Replace(".xml", ".html"))"
    }
    
}

function Test-Denpendency () {

    # Check Denpendency
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
    
    $type = $section.Remove($section.Length - 3, 3).ToLower()
    $html = (Invoke-WebRequest "$website/$type/$location.html")

    # Get 3 Passage question number 
    foreach ($item in $html.ParsedHtml.body.getElementsByClassName("title")) {
        if($item.innerText -like "*$sets$([int]$number)*") { $test = $item }
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

    for ($i = 1; $i -le $links.Count; $i++) {
        "$sets$number$letter$i"
        $filePath = "$prefix$i"

        #if (Test-Path "$xmlPath\$filePath.xml") { continue }

        $html = (Invoke-WebRequest $links[$i-1])
        $document = $html.ParsedHtml.body
        
        $questions = @()
        foreach ($item in $document.getElementsByClassName("undone")) {
            $questions += "$website$($item.parentNode.href.Remove(0,12))"
        }

        # Create passage xml and text
        
        $title = $document.getElementsByClassName("article_tit")[0].innerText
        $xml = Add-XmlTestItemNode @{CLASS = "view_this_passage_noquest"}
        Add-XmlChildNodes $xml @("TPPassage", "Title", "PassageText") @("$filePath.txt", $title, "")

        (Select-Xml "//PassageText" $xml).Node.InnerXml = (Get-Passage $links[$i-1])[1]
        New-File $xml "$xmlPath\$filePath.xml"

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
            $index = $questionText.IndexOf("[")
            if ($index -ne -1) {
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
                    $category = if($index -ne -1) { $category[0..($index-1)] }
                    
                    $index = $questionText.IndexOf($category[1].Split(" ")[0].ToLower())
                    if($index -eq -1) { $index = $questionText.IndexOf($category[1].Split(" ")[0]) }
                    if($questionText.Substring(0, $index).Contains("two")) {
                    
                        [Array]::Reverse($category)
                    }
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
                if([int][char]$item -lt 60 -or [int][char]$item -gt 80) { 
                    $keys += "0" # Draggy Table Question Spiliter
                    # $key = keys.split("0")
                    # if($key.Length -lt 3) {tpObjects[-3].Substring(tpObjects[-3].IndexOf(",0,") + 3)}
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
                        if($pair.Length -lt 3) {
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
        if($item.innerText -like "*$sets$([int]$number)*") { $test = $item }
    }

    $articles = @()
    foreach ($item in $test.nextSibling.nextSibling.getElementsByClassName("total")) {
        $articles += "$($item.previousSibling.previousSibling.id.Split("-")[1])"
    }

    $links = @()
    foreach ($item in $test.nextSibling.nextSibling.getElementsByClassName("btnn2 aspan")) { 
        $links += $website + $item.parentNode.href.Remove(0,12) }

    for ($i = 6; $i -le $links.Count; $i++) {
        "$sets$number$letter$i"
        $filePath = "$prefix$i"
        
        
        # if (Test-Path "$xmlPath\$filePath.xml") { continue }

        $html = (Invoke-WebRequest $links[$i-1])
        $document = $html.ParsedHtml.body
        
        $questions = @()
        foreach ($item in $document.getElementsByClassName("undone")) {
            $questions += "$website$($item.parentNode.href.Remove(0,12))"
        }

        # Create passage xml
        $xml = Add-XmlTestItemNode @{CLASS = "lecture"}
        $names = "LecturePicture", "LectureSound", "LecturePicture", "AudioText"
        $nodes = "$filePath.jpg", "$filePath.wav", "Sampler\GetReady.gif", ""
        Add-XmlChildNodes $xml $names $nodes
        (Select-Xml "//AudioText" $xml).Node.InnerXml = (Get-Passage $links[$i-1])[1]

        Get-Audio $links[$i-1] "$xmlPath\$filePath.mp3"

        New-File $xml "$xmlPath\$filePath.xml"
        
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
            if($keys.Length -gt 2) {
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
            if($flag) {
                Get-Audio "$website/$type/answer.html?step=2&article_id=$article&seqno=$j"  "$xmlPath\$prefix$($i)Q$j.mp3"
                "$sets$number$letter$($i)Q$($j)R"
                $names = "LecturePicture", "LectureSound"
                $nodes = "Sampler\RplayLec.gif", "$($filePath)R.wav"
                Add-XmlChildNodes $xml $names $nodes "miniLecture"

            }

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

    $type = $section.Remove($section.Length - 3, 3).ToLower()
    $html = (Invoke-WebRequest "$website/$type/$location.html")

    # Get 3 Passage question number 
    foreach ($item in $html.ParsedHtml.body.getElementsByClassName("title")) {
        if($item.innerText -like "*$sets$([int]$number)*") { $test = $item }
    }

    $articles = @()
    foreach ($item in $test.nextSibling.nextSibling.getElementsByClassName("tpo_talking_item")) { $articles += $item.id.Split("-")[1] }

    $links = @()
    foreach ($item in $test.nextSibling.nextSibling.getElementsByClassName("btnn blue")) { 
        $links += $website + $item.href.Remove(0,12) }

    for ($i = 1; $i -le $links.Count; $i++) {
        "$sets$number$letter$i"
        $filePath = "$prefix$i"

        #if (Test-Path "$xmlPath\$filePath.xml") { continue }

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
                innerText = Remove-Characters $document.getElementsByClassName("audio_topic")[0].innerText
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

        $names = "Stem", "StemWav", "SampleResponse"
        $nodes = `
        @( 
            (Remove-Characters $text),
            "$($filePath)Q.wav",
            (Remove-Characters $sampleText)
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

    $html = (Invoke-WebRequest "$website/write/$location.html")

    # Get 3 Passage question number 
    foreach ($item in $html.ParsedHtml.body.getElementsByClassName("title")) {
        if($item.innerText -like "*$sets$([int]$number)*") { $test = $item }
    }

    $links = @()
    foreach ($item in $test.nextSibling.nextSibling.getElementsByClassName("btnn blue")) { 
        $links += $website + $item.href.Remove(0,12) }

    for ($i = 1; $i -le $links.Count; $i++) {
        "$sets$number$letter$i"
        $filePath = "$prefix$i"

        #if (Test-Path "$xmlPath\$filePath.xml") { continue }

        $html = (Invoke-WebRequest $links[$i-1])
        $document = $html.ParsedHtml.body

        if ($i -eq 1) { # Integrated Writing 
            # miniPassage
            $xml = Add-XmlTestItemNode @{CLASS = "writelisten_paced"; TIMELIMIT = "20"; SHOWDIRECTIONS = "FALSE"} 
            $text = $document.getElementsByClassName("article")[0].innerText 
            if (!$text) { $text = $document.getElementsByClassName("article")[0].nextSibling.innerText }
            $names = "miniPassageDuration", "miniPassageText"
            $nodes = 180, (Format-Paragraphs $text)
            Add-XmlChildNodes $xml $names $nodes "miniPassage"

            # "LecturePicture", "LectureSound"
            $names = "LecturePicture", "LectureSound", "LecturePicture"
            $nodes = "$filePath.jpg", "$filePath.wav", "Sampler\WGetReady.gif"
            Add-XmlChildNodes $xml $names $nodes "miniLecture"
        
            # "AudioText", "Stem", "StemWav"
            $names = "AudioText", "Stem", "StemWav"
            $nodes = `
            @(
                (Remove-Characters $document.getElementsByClassName("audio_topic")[0].innerText),
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
            $nodes = @($questionText) 
        }

        # sample Text
        $sampleText = $document.getElementsByClassName("noedit fanwen")[0].innerText
        $names += "SampleResponse"
        $nodes += Format-Paragraphs $sampleText
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
            while ($node.TestItemName.Count - 1 -gt $count){ $node.RemoveChild($node.LastChild) }
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
        if ($node){
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
$global:sets = "OG"
$global:setsLength = if($sets -eq "OG") {3} else {5}

$global:xmlPath = "$env:USERPROFILE\Downloads\ETS\TOEFL Programs\Sampler\forml1"
$global:htmlPath = "C:\github\toefl\$($sets.ToLower())"
$global:idmExe = "C:\Program Files (x86)\Internet Download Manager\IDMan.exe"
$global:switchExe = "C:\Program Files (x86)\NCH Software\Switch\switch.exe"

Test-Denpendency

for ($n = 1; $n -le 3; $n++) 
{
    $global:number = $n
    $global:tpos = if($number % 4 -eq 0) {"$number"} 
    else {"$($number - $number % 4 + 4)"}
    if ($sets -eq "TPO") { $location = "alltpo$tpos" } else { $location = $sets.ToLower()}
    if ($number -lt 10 -and $sets -eq "TPO") {$number = "0$number"}
    New-Item -Path "$xmlPath\$sets$number\" -ItemType "Directory" -ErrorAction SilentlyContinue | Out-Null

    #Get-Reading
    #Get-Listening 
    #Get-Speaking 
    #Get-Writing
    New-TPOHtml
    #Update-SamplerXml 
    #Update-Audio #"test"
    
}
 