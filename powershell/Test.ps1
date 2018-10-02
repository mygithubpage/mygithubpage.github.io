. $PSScriptRoot\Utility.ps1
$content = Get-Content "C:\github\temp\files\test.html" -Encoding UTF8
$content = $content -replace "<hr.*>" -replace "div.*>", "ol>"
$content = $content -replace "strong>", "b>" -replace "<span.*?/span>"
$content = $content -replace "p.*?`">", "li>" -replace "p>", "li>"
#Set-Clipboard $content


function ConvertFrom-MH ($content, $path) {

    {
        # explanation
        $id = $node.ChildNodes[0].href.Split("#")[1]
        $node = (Select-Xml "//a[@id=`"$id`"]" $xml).Node
        $content = $node.ParentNode."#text"
        $regex = if ($type -eq "select") {"\d{1,2}"} else {"[A-F]"}
        $answer = ($content | Select-String $regex -AllMatches -CaseSensitive).Matches.Value -join ""
        $answer = Add-XmlNode ("div", @{class = "answer"; "data-answer" = $answer}) $question
        $explanation = Add-XmlNode ("div", @{class = "explanation"}) $answer
        $content = $node.ParentNode.ParentNode.InnerXml -replace $node.ParentNode.ParentNode.ChildNodes[0].OuterXml
        $explanation.InnerXml = $content -replace "strong>", "b>"
    }
        
    # passage 
    $nodes = (Select-Xml "//p[@class=`"noindenttb`"]" $xml).Node.Where{$_.InnerText -cmatch "Question"}
    for ($i = 1; $i -le $nodes.Count; $i++) {
        $passage = Add-XmlNode ("div", @{id = "passage$i"; class = "passage"}) $questionsDiv
        $text = $nodes[$i - 1].NextSibling
        $content = ""
        while ($text.class -match "nums|noindent") {
            if ($text.class -eq "nums-1") { $content += "</p><p>"}
            $content += $text.InnerText -replace "(\d{1,2})?\u00A0{1,}", " "
            $text = $text.NextSibling
        }

        $passage.InnerXml = "<p>$content</p>" -replace "<p></p>"
        $range = $nodes[$i - 1].InnerText -replace "\u2013", " to "
        $start = [int]$range.Split(" ")[1]
        $end = if ($range -match "Questions") { [int]$range.Split(" ")[3] } else { $start }
        for ($j = $start; $j -le $end; $j++) {
            $question = (Select-Xml "//div[@id=`"question$j`"]" $html).Node
            $question.SetAttribute("data-passage", "passage$i")
        }
    }

}

function ConvertFrom-Kap ($content, $path) {

    {
        if ($node.InnerXml.Contains("ktp-feedback")) {
            # explanation
            $question = (Select-Xml "//div[@id=`"question$($node.value)`"]" $html).Node
            if ($question."data-choice-type" -ne "select") { 
                $answer = $node.ChildNodes[0].InnerXml.Replace(", ") 
                $text = $node.ChildNodes[1].InnerXml
            }
            else {
                $answer = $node.ChildNodes[0].ChildNodes[0].InnerText
                $text = $node.ChildNodes[0].InnerXml
            }
            $answer = Add-XmlNode ("div", @{class = "answer"; "data-answer" = $answer}) $question
            $explanation = Add-XmlNode ("div", @{class = "explanation"}) $answer
            $explanation.InnerXml = $text -replace "i>", "b>"
        }

    }

    
    <#
    Sample Questions
    (Select-Xml "//li[@class=`"sample-question`"]" $xml).Node.class += " counter-reset-1"
    # sample question
    $nodes = (Select-Xml "//li[ @class=`"ktp-question`" or contains(@class,'counter-reset')]" $xml).Node
    for ($i = 0; $i -lt $nodes.Count; $i++) {
        $node = $nodes[$i]
        if ($node.OuterXml.Contains(" no-number")) { $type = "radio" }
        else {$type = "checkbox"}
        if ($node.InnerXml.Contains("list-lower-alpha")) { $type = "checkbox" }
        else {$type = "radio"}
        $question = Add-XmlNode ("div", @{id="question$($i+1)";"data-choice-type"=$type}) $questionsDiv
        Add-XmlNode ("div", @{class="question"}, $node.ChildNodes[0].InnerXml) $question | Out-Null
        if (!$node.value) { $node.SetAttribute("value", $i + 1) }
        # choice
        $choicesDiv = (Select-Xml "//li[@value=`"$($node.value)`"]//ol[contains(@class,'ktp-answer-set')]" $xml).Node
        if (!$choicesDiv) { 
            $question.'data-choice-type' = "select" 
            $answer = Add-XmlNode ("div", @{class="answer"; "data-answer"=""}) $question
            $explanation = Add-XmlNode ("div", @{class="explanation"}) $answer
            $explanation.InnerXml = $node.ParentNode.ParentNode.NextSibling.OuterXml
            if ($i -gt 4) { $explanation.InnerXml = (Select-Xml "//section[@class=`"ktp-feedback`"]" $xml).Node[$i-5].InnerXml}
            continue
        }
        if ($node.InnerXml.Contains("blank-")) { # multiple blank
            $choicesDiv.ForEach{
                $question.InnerXml += $_.OuterXml -replace "li>", "p>" -replace "ol", "div" -replace "ktp-answer-set.*?`"", "choices`""
            }
        }
        else {
            $question.InnerXml += $choicesDiv.OuterXml -replace "li>", "p>" -replace "ol", "div" -replace "ktp-answer-set.*?`"", "choices`""
        }
        
        $answer = Add-XmlNode ("div", @{class="answer"; "data-answer"=""}) $question
        $explanation = Add-XmlNode ("div", @{class="explanation"}) $answer
        $explanation.InnerXml = $node.ParentNode.ParentNode.NextSibling.OuterXml
        if ($i -gt 4) { $explanation.InnerXml = (Select-Xml "//section[@class=`"ktp-feedback`"]" $xml).Node[$i-5].InnerXml}
    }

    $nodes = (Select-Xml "//section[@class=`"ktp-passage`"]" $xml).Node
    for ($i = 1; $i -le $nodes.Count; $i++) {
        $passage = Add-XmlNode ("div", @{id="passage$i";class="passage"}) $questionsDiv
        $passage.InnerXml = $nodes[$i-1].InnerXml
        $start = [int]$nodes[$i-1].ParentNode.PreviousSibling.InnerText.Split(" ")[1]
        $end = [int]$nodes[$i-1].ParentNode.PreviousSibling.InnerText.Split(" ")[3]
        for ($j = $start; $j -le $end; $j++) {
            $question = (Select-Xml "//div[@id=`"question$j`"]" $html).Node
            if ($question.'data-choice-type' -eq "select") {
                $sentences = $passage.InnerText -split "[?.!] "
                $index = $sentences.indexOf($question.ChildNodes[2]."data-answer".TrimEnd("`r`n ."))
                $question.ChildNodes[2].SetAttribute("data-answer", $index+1)
            }
            $question.SetAttribute("data-passage", "passage$i")
        }
    }

    #>

    # passages
    $nodes = (Select-Xml "//li[@class=`"ktp-stimulus`"]" $xml).Node
    for ($i = 1; $i -le $nodes.Count; $i++) {

        $passage = Add-XmlNode ("div", @{id = "passage$i"; class = "passage"}, $nodes[$i - 1].InnerXml) $questionsDiv
        #$passage.InnerXml = $nodes[$i - 1].InnerXml
        $range = $nodes[$i - 1].PreviousSibling.InnerText -replace "\u2013", " to "
        $start = [int]$range.Split(" ")[1]
        $end = [int]$range.Split(" ")[3]
        for ($j = $start; $j -le $end; $j++) {
            $question = (Select-Xml "//div[@id=`"question$j`"]" $html).Node
            if ($question.'data-choice-type' -eq "select") {
                $sentences = $passage.InnerText -split "[?.!] "
                $index = $sentences.indexOf($question.ChildNodes[2]."data-answer".TrimEnd("`r`n ."))
                $question.ChildNodes[2].SetAttribute("data-answer", $index + 1)
            }
            $question.SetAttribute("data-passage", "passage$i")
        }
    }

    
}

function ConvertFrom-PR ($content, $path) {
    {
        # expplantion
        if ($node.class -eq "Test_sample" -or $node.class -eq "Test_samplet") {
            
        }
        
    }
    # passages
    
}

function ConvertFrom-MP ($content, $path) {

    {

        # answers
        if ($path -match "reading") { 
            $content = ""
            $explanation = $answers[$i]
            while ($explanation.class -match "body-text" -or $explanation.id -match "page") {
                $content += $explanation.OuterXml
                $explanation = $explanation.NextSibling
            }
            $answer = ""
            if ($type -ne "select") {
                $answer = ($content | Select-String "(?<=<b>\()\w(?=\) CORRECT)" -AllMatches).Matches.Value -join ""
            }
            $answer = Add-XmlNode ("div", @{class = "answer"; "data-answer" = $answer}) $question
            $explanation = Add-XmlNode ("div", @{class = "explanation"}, ($content -replace "i>", "b>")) $answer
            #$explanation.InnerXml = $content -replace "i>", "b>"
    
            # passages
            if ($node.InnerXml -match "1\." -or $node.InnerXml -notmatch "\d") {
                $text = ""
                $paragraph = $node.PreviousSibling
                while ($paragraph.class -notmatch "indent|hang-nums") { $paragraph = $paragraph.PreviousSibling }
                while ($paragraph.class -match "indent|hang-nums") {
                    $text += $paragraph.OuterXml
                    $paragraph = $paragraph.PreviousSibling
                }
                
                $count++
                $passage = Add-XmlNode ("div", @{id = "passage$count"; class = "passage"}, $text) $questionsDiv
                #$passage.InnerXml = $text
            }
            $question.SetAttribute("data-passage", "passage$count")
        }
        else {
            $string = if ($answers[$i].b.Count -gt 1) {$answers[$i].b[0]} else {$answers[$i].b}
            $answer = ( $string | Select-String "\b[^\d]\w+\b" -AllMatches -CaseSensitive).Matches.Value
            $iey = ""
            $choicesDiv = ($question.div.Where{ $_.class -eq "choices" }).p
            $answer.ForEach{  $iey += [char](65 + $choicesDiv.IndexOf(($choicesDiv -match $_)[0])) }
            
            $answer = Add-XmlNode ("div", @{class = "answer"; "data-answer" = $iey}) $question
    
            $explanation = Add-XmlNode ("div", @{class = "explanation"}) $answer
            $content = $answers[$i].OuterXml
            if ($answers[$i].b -notmatch "\d") { $content += $answers[$i].NextSibling.OuterXml }
            $explanation.InnerXml = $content -replace "i>", "b>" -replace "<a.*?/>"
        }
        
    }
    
}

# choice
if ($type -ne "select") {
    $choice = $node.NextSibling
    if ($choice.ChildNodes[0].src -match "box.*|round.*") { 
        $choices = Add-XmlNode ("div", @{class = "choices"}) $question 
        while ($choice.ChildNodes[0].src -match "box.*|round.*") {
            Add-XmlNode ("p", ($choice.InnerText -replace "\u00A0")) $choices | Out-Null
            $choice = $choice.NextSibling
        }
    }
    else {
        $name = $choice.ChildNodes[0].src -replace "jpg|png", "txt"
        Write-Host $name
        $content = Get-Content "C:\github\gre\notes\gre\$set\*$name" -Raw

        $options = ($content | Select-String "(?<!\()\w{3,}\s?[a-z]{2,5}?\b" -AllMatches -CaseSensitive).Matches.Value | Get-Unique
        #$options.ForEach{ if($_ -match "\s") {$_.Split(" ")[1] }}  
        if ($content -like "*iii*") {
            for ($i = 0; $i -lt 3; $i++) {
                $choices = Add-XmlNode ("div", @{class = "choices"}) $question
                for ($j = 0; $j -lt 3; $j++) {
                    Add-XmlNode ("p", $options[$i + 1 + $j * 3]) $choices | Out-Null
                }
            }
        }
        elseif ($content -like "*ii*") {
            for ($i = 0; $i -lt 2; $i++) {
                $choices = Add-XmlNode ("div", @{class = "choices"}) $question
                for ($j = 0; $j -lt 3; $j++) {
                    Add-XmlNode ("p", $options[$i + 1 + $j * 2]) $choices | Out-Null
                }
            }
        }
        else {
            $choices = Add-XmlNode ("div", @{class = "choices"}) $question
            foreach ($option in $options) {
                Add-XmlNode ("p", $option) $choices | Out-Null
            }
        }

        
    }
}

# choice
$choices = (Select-Xml "//li[@value=`"$($node.value)`"]//ol[contains(@class,'ktp-answer-set')]" $xml).Node
if (!$choices) { 
    $question.'data-choice-type' = "select" 
    return
}
if ($node.InnerXml.Contains("blank-")) {
    # multiple blank
    $choices.ForEach{
        $question.InnerXml += $_.OuterXml -replace "li>", "p>" -replace "ol>", "div>" -replace "ktp-answer-set.*?`"", "choices`""
    }
}
else {
    $question.InnerXml += $choices.OuterXml -replace "li>", "p>" -replace "ol", "div" -replace "ktp-answer-set.*?`"", "choices`""
}

# choice
if ($type -ne "select") {
    $choice = $node.NextSibling
    if ($choice.ChildNodes[0].InnerXml -match "_sq_|_circle_") { 
        $choices = Add-XmlNode ("div", @{class = "choices"}) $question 
        $choice.ChildNodes[0].ChildNodes.ForEach{ Add-XmlNode ("p", $_.InnerText) $choices | Out-Null }
    }
    else {
        $name = $choice.ChildNodes[0].ChildNodes[0].src -replace "jpg|png", "txt" -replace "images/"
        Write-Host $name
        $content = Get-Content "C:\github\gre\notes\gre\$set\*$name" -Raw
        $regex = "(?<!\()(a(n)?\s)?\w{3,}(\s\w{3,})?\s?$prepositions" + "?"
        $options = ($content | Select-String $regex -AllMatches -CaseSensitive).Matches.Value | Get-Unique
        if ($options.length -gt 9) {
            for ($j = 0; $j -lt 3; $j++) {
                $choices = Add-XmlNode ("div", @{class = "choices"}) $question
                for ($k = 0; $k -lt 3; $k++) {
                    Add-XmlNode ("p", $options[$j + 1 + $k * 3]) $choices | Out-Null
                }
            }
        }
        elseif ($options.length -gt 6) {
            for ($j = 0; $j -lt 2; $j++) {
                $choices = Add-XmlNode ("div", @{class = "choices"}) $question
                for ($k = 0; $k -lt 3; $k++) {
                    Add-XmlNode ("p", $options[$j + 1 + $k * 2]) $choices | Out-Null
                }
            }
        }
        else {
            $choices = Add-XmlNode ("div", @{class = "choices"}) $question
            foreach ($option in $options) {
                Add-XmlNode ("p", $option) $choices | Out-Null
            }
        }
    }
}
    
# choice
if ($type -eq "radio" -and $path -notmatch "reading") {
    $options = $node.NextSibling.tr
    if ($options.InnerXml -match "Blank") { 
        for ($j = 0; $j -lt $options[0].td.Count; $j++) {
            $choices = Add-XmlNode ("div", @{class = "choices"}) $question
            for ($k = 0; $k -lt 3; $k++) {
                if ($options[$k + 1].td[$j].InnerText) {
                    Add-XmlNode ("p", $options[$k + 1].td[$j].InnerText) $choices | Out-Null 
                }
            }
        }
    }
    else {
        $choices = Add-XmlNode ("div", @{class = "choices"}) $question
        foreach ($option in $options) {
            Add-XmlNode ("p", $option.td[1].InnerText) $choices | Out-Null
        }
    }
}
elseif ($type -eq "checkbox" -or $path -match "reading") {
    if ($type -ne "select") {
        $choice = $node.NextSibling
        $choices = Add-XmlNode ("div", @{class = "choices"}) $question 
        while ($choice.InnerXml -match "([abc]|sq).jpg" -or $choice.OuterXml -match "alpha-list-h|hang-nss") { 
            Add-XmlNode ("p", ($choice.InnerText -replace "\u00a0")) $choices | Out-Null
            $choice = $choice.NextSibling
        }
    }
}
#>