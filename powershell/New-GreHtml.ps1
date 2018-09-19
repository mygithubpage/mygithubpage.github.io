. $PSScriptRoot\Utility.ps1

$set = "mp"
$name = "$set-reading"
$type = "html"
$content = Get-Content "C:\github\gre\notes\gre\$set\$name.$type" -Raw -Encoding UTF8 
$path = "C:\github\gre\$set\$name.html"
$global:prepositions = "(at|in|on|for|by|after|to|over|from|under|along|around|across|through|into|toward|onto|off|up|down|with|of)"

function ConvertFrom-MH ($content, $path) {
    $content = $content -replace " style=`".*?`"" -replace " xmlns(:epub)?=`".*?`"" -replace " epub:type=`".*?`"" 
    Set-Content "C:\github\gre\notes\test.html" $content -Encoding UTF8

    # questions
    $xml = [xml]($content)
    $html = [xml](Get-Content "C:\github\gre\notes\gre\vocabulary.html")
    $questions = (Select-Xml "//div[@id=`"questions`"]" $html).Node
    #$questions.InnerXml = ""

    foreach ($node in (Select-Xml "//p[contains(@class,'ques')]" $xml).Node) {

        if ($node.InnerXml.Contains("Select the sentence")) { $type = "select" }
        elseif ($node.NextSibling.InnerXml.Contains("box")) {$type = "checkbox"}
        else {$type = "radio"}
        
        $question = Add-XmlNode ("div", @{id = "question$($node.ChildNodes[0].InnerText)"; "data-choice-type" = $type}) $questions
        Add-XmlNode ("div", @{class = "question"}, $node.InnerText) $question | Out-Null
        
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
    $nodes = (Select-Xml "//p[@class=`"noindenttb`"]" $xml).Node.Where{$_.InnerText -cmatch "Question"}
    for ($i = 1; $i -le $nodes.Count; $i++) {

        $passage = Add-XmlNode ("div", @{id = "passage$i"; class = "passage"}) $questions
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

    Set-Content "C:\github\gre\notes\test.html" $html.OuterXml.Replace("html[]", "html") -Encoding UTF8
    #Set-Content $path $html.OuterXml.Replace("html[]", "html") -Encoding UTF8
}

function ConvertFrom-Kap ($content, $path) {
    $content = $content -replace " xmlns=`".*?`"" -replace " id=`".*?`"" 
    $content = $content -replace " style=`".*?`"" -replace " data-uuid=`".*?`""
    $content = $content -replace "<hr.*?/>" -replace "\s+<a>(\s+`r`n\s+)*</a>" -replace "`r`n\s+<i", " <i"
    $content = $content -replace "(`r`n)?\s+<span class=`"blank-s`"></span>", " ________"

    $regex = "(`r`n)?\s+<span class=`"no-break`">(`r`n\s+)?(?<word>.*?)(`r`n\s+)?</span>"
    foreach ($match in ($content | Select-String $regex -AllMatches -CaseSensitive).Matches) {
        $content = $content.Replace($match.Value, (" " + $match.Groups["word"].Value))
    }
    #Set-Content "C:\github\gre\notes\test.html" $content -Encoding UTF8
    Set-Content $path $content -Encoding UTF8

    $xml = [xml]($content)
    $html = [xml](Get-Content "C:\github\gre\notes\gre\vocabulary.html")
    $questions = (Select-Xml "//div[@id=`"questions`"]" $html).Node
    #$questions.InnerXml = ""

    # questions
    $nodes = (Select-Xml "//li[@class=`"ktp-question`"]" $xml).Node
    if ($nodes.Count) {
        $nodes.ForEach{
            $node = $_
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
            else {
                # question
                if ($node.InnerXml.Contains("list-lower-alpha")) { $type = "checkbox" }
                else {$type = "radio"}
                $question = Add-XmlNode ("div", @{id = "question$($node.value)"; "data-choice-type" = $type}) $questions
                Add-XmlNode ("div", @{class = "question"}, $node.ChildNodes[0].InnerXml) $question | Out-Null
                
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
            }
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
        $question = Add-XmlNode ("div", @{id="question$($i+1)";"data-choice-type"=$type}) $questions
        Add-XmlNode ("div", @{class="question"}, $node.ChildNodes[0].InnerXml) $question | Out-Null
        if (!$node.value) { $node.SetAttribute("value", $i + 1) }
        # choice
        $choices = (Select-Xml "//li[@value=`"$($node.value)`"]//ol[contains(@class,'ktp-answer-set')]" $xml).Node
        if (!$choices) { 
            $question.'data-choice-type' = "select" 
            $answer = Add-XmlNode ("div", @{class="answer"; "data-answer"=""}) $question
            $explanation = Add-XmlNode ("div", @{class="explanation"}) $answer
            $explanation.InnerXml = $node.ParentNode.ParentNode.NextSibling.OuterXml
            if ($i -gt 4) { $explanation.InnerXml = (Select-Xml "//section[@class=`"ktp-feedback`"]" $xml).Node[$i-5].InnerXml}
            continue
        }
        if ($node.InnerXml.Contains("blank-")) { # multiple blank
            $choices.ForEach{
                $question.InnerXml += $_.OuterXml -replace "li>", "p>" -replace "ol", "div" -replace "ktp-answer-set.*?`"", "choices`""
            }
        }
        else {
            $question.InnerXml += $choices.OuterXml -replace "li>", "p>" -replace "ol", "div" -replace "ktp-answer-set.*?`"", "choices`""
        }
        
        $answer = Add-XmlNode ("div", @{class="answer"; "data-answer"=""}) $question
        $explanation = Add-XmlNode ("div", @{class="explanation"}) $answer
        $explanation.InnerXml = $node.ParentNode.ParentNode.NextSibling.OuterXml
        if ($i -gt 4) { $explanation.InnerXml = (Select-Xml "//section[@class=`"ktp-feedback`"]" $xml).Node[$i-5].InnerXml}
    }

    $nodes = (Select-Xml "//section[@class=`"ktp-passage`"]" $xml).Node
    for ($i = 1; $i -le $nodes.Count; $i++) {
        $passage = Add-XmlNode ("div", @{id="passage$i";class="passage"}) $questions
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

        $passage = Add-XmlNode ("div", @{id = "passage$i"; class = "passage"}, $nodes[$i - 1].InnerXml) $questions
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

    Set-Content $path $html.OuterXml.Replace("html[]", "html") -Encoding UTF8
}

function ConvertFrom-PR ($content, $path) {
    $content = $content -replace " style=`".*?`"" -replace " xmlns(:epub)?=`".*?`"" -replace " epub:type=`".*?`"" 
    Set-Content "C:\github\gre\notes\test.html" $content -Encoding UTF8

    $xml = [xml]($content)
    $html = [xml](Get-Content "C:\github\gre\notes\gre\vocabulary.html")
    $questions = (Select-Xml "//div[@id=`"questions`"]" $html).Node
    #$questions.InnerXml = ""

    # questions
    $nodes = (Select-Xml "//p[contains(@class,'Test_sample')]" $xml).Node.Where{$_.PreviousSibling.class -match "Test_sample2l" -or $_.PreviousSibling.PreviousSibling.class -match "Test_sample2l" -and $_.NextSibling.class -match "block_|square|circle" -or ($_.PreviousSibling.class -match "Test_sample2l" -and $_.InnerText -match "Select the sentence")}

    for ($k = 0; $k -lt $nodes.Count; $k++) {
        $node = $nodes[$k]
        if ($node.InnerXml.Contains("Select the sentence")) { $type = "select" }
        elseif ($node.NextSibling.InnerXml.Contains("_sq_")) {$type = "checkbox"}
        else {$type = "radio"}
        
        $question = Add-XmlNode ("div", @{id = "question$($k+1)"; "data-choice-type" = $type}) $questions
        Add-XmlNode ("div", @{class = "question"}, ($node.OuterXml -replace "<p.*?`">", "<p>")) $question | Out-Null
        
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
                    for ($i = 0; $i -lt 3; $i++) {
                        $choices = Add-XmlNode ("div", @{class = "choices"}) $question
                        for ($j = 0; $j -lt 3; $j++) {
                            Add-XmlNode ("p", $options[$i + 1 + $j * 3]) $choices | Out-Null
                        }
                    }
                }
                elseif ($options.length -gt 6) {
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

        if ($node.class -eq "Test_sample" -or $node.class -eq "Test_samplet") {
            $answer = Add-XmlNode ("div", @{class = "answer"; "data-answer" = ""}) $question
            $content = ""
            $explanation = $node.NextSibling.NextSibling
            while ($explanation.id -match "p\d{2,3}") {
                $content += $explanation.OuterXml -replace "<hr.*>" -replace "<span.*</span>" -replace "<p.*`">", "<p>"
                $explanation = $explanation.NextSibling
            }
            $explanation = Add-XmlNode ("div", @{class = "explanation"}, ($content -replace "<span.*/>")) $answer
            #$explanation.InnerXml = $content -replace "<span.*/>"
        }
        else {
            if ($node.PreviousSibling.ChildNodes[0].href) {
                $id = $node.PreviousSibling.ChildNodes[0].href.Split("#")[1]
            }
            else {
                $id = $node.PreviousSibling.PreviousSibling.ChildNodes[0].href.Split("#")[1]
            }
        
            $content = Get-Content "C:\github\gre\notes\gre\pr\pr-answer.html"
            $content = $content -replace " style=`".*?`"" -replace " xmlns(:epub)?=`".*?`"" -replace " epub:type=`".*?`"" 
            $answers = [xml]($content)

            $node = (Select-Xml "//a[@id=`"$id`"]" $answers).Node
            $content = $node.ParentNode.ParentNode.InnerText
            $regex = if ($type -eq "select") {"\d{1,2}"} else {"[A-I]"}
            $answer = ($content | Select-String $regex -AllMatches -CaseSensitive).Matches.Value -join ""
            $answer = Add-XmlNode ("div", @{class = "answer"; "data-answer" = $answer}) $question
            $explanation = Add-XmlNode ("div", @{class = "explanation"}) $answer
            
            $content = $node.ParentNode.ParentNode.InnerText -creplace "([A-F])", " `$1 "
            $content = "<strong>$content</strong>. " + $node.ParentNode.ParentNode.NextSibling.InnerXml
            $explanation.InnerXml = "<p>" + ($content -replace "strong>", "b>") + "</p>"
        }
        
    }
    
    # passages
    $nodes = (Select-Xml "//p[@class=`"Test_samplen`"]" $xml).Node.Where{$_.InnerText -cmatch "Question"}
    for ($i = 1; $i -le $nodes.Count; $i++) {

        $passage = Add-XmlNode ("div", @{id = "passage$i"; class = "passage"}) $questions
        $text = $nodes[$i - 1].NextSibling
        $content = ""
        while ($text.class -match "Test_samplei") {
            $content += $text.OuterXml -replace "<p.*?`">", "<p>"
            $text = $text.NextSibling
        }

        $passage.InnerXml = $content
        $range = $nodes[$i - 1].InnerText -replace "\u2013", " to "
        $start = [int]$range.Split(" ")[1]
        $end = if ($range -match "Questions") { [int]$range.Split(" ")[3] } else { $start }
        for ($j = $start; $j -le $end; $j++) {
            $question = (Select-Xml "//div[@id=`"question$j`"]" $html).Node
            $question.SetAttribute("data-passage", "passage$i")
            if ($question.InnerXml -match "gray|highlighted") {
                $question.InnerXml = $question.InnerXml -replace "gray", "highlight"
                $passage.InnerXml = $passage.InnerXml -replace "class=`"gray`"", "data-question=`"$j`""
            }
        }
    }

    #Set-Content "C:\github\gre\notes\test.html" $html.OuterXml.Replace("html[]", "html") -Encoding UTF8
    Set-Content $path $html.OuterXml.Replace("html[]", "html") -Encoding UTF8
}

function ConvertFrom-MP ($content, $path) {
    $content = $content -replace " style=`".*?`"" -replace " xmlns(:epub)?=`".*?`"" -replace " epub:type=`".*?`"" 
    Set-Content "C:\github\gre\notes\test.html" $content -Encoding UTF8

    $xml = [xml]($content)
    $html = [xml](Get-Content "C:\github\gre\notes\gre\vocabulary.html")
    $questions = (Select-Xml "//div[@id=`"questions`"]" $html).Node
    #$questions.InnerXml = ""

    # questions
    $nodes = (Select-Xml "//p[contains(@class,'hang')]" $xml).Node.Where{$_.NextSibling.Name -match "table" -or $_.NextSibling.InnerXml -match "sq.jpg" -or $_.InnerXml -match "Select the sentence" -or ($_.class -match "hang-num" -and $_.NextSibling.class -match "alpha-list-h")}
    $answers = (Select-Xml "//p[contains(@class,'body-text')]" $xml).Node.Where{$_.b -match "\d{1,2}\." -or $_.InnerXml -match "\d{1,2}\.\s<b>" -or $_.PreviousSibling.class -match "alpha-list-h|hang-nss" -or $_.PreviousSibling.InnerXml -match "Select the sentence" -or ($_.PreviousSibling.PreviousSibling.class -match "alpha-list-h|hang-nss" -and $_.PreviousSibling.id -match "page") -and ( $_.InnerText.Length -gt 100 -or $_.b -match "Step \d:")}
    if ($path -match "reading") { $nodes = $answers}
    $count = 0; # passagw count

    for ($k = 0; $k -lt $nodes.Count; $k++) {
        $node = $nodes[$k]
        if ($path -match "reading") {
            $node = $nodes[$k].PreviousSibling
            while ($node.class -match "alpha-list-h|hang-nss" -or $node.id -match "page") {
                $node = $node.PreviousSibling
            }
        }
        if ($node.InnerXml -match "Select the sentence") { $type = "select" }
        elseif ($node.NextSibling.InnerXml -match "([abc]|sq).jpg|hang-nss") {$type = "checkbox"}
        else {$type = "radio"}
        
        $question = Add-XmlNode ("div", @{id = "question$($k+1)"; "data-choice-type" = $type}) $questions
        Add-XmlNode ("div", @{class = "question"}, ($node.OuterXml -replace "<p.*?`">", "<p>")) $question | Out-Null
        
        # choice
        if ($type -eq "radio" -and $path -notmatch "reading") {
            $options = $node.NextSibling.tr
            if ($options.InnerXml -match "Blank") { 
                for ($i = 0; $i -lt $options[0].td.Count; $i++) {
                    $choices = Add-XmlNode ("div", @{class = "choices"}) $question
                    for ($j = 0; $j -lt 3; $j++) {
                        if ($options[$j + 1].td[$i].InnerText) { Add-XmlNode ("p", $options[$j + 1].td[$i].InnerText) $choices | Out-Null 
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

        # answers
        if ($path -match "reading") { 
            $content = ""
            $explanation = $answers[$k]
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
                $passage = Add-XmlNode ("div", @{id = "passage$count"; class = "passage"}, $text) $questions
                #$passage.InnerXml = $text
            }
            $question.SetAttribute("data-passage", "passage$count")
        }
        else {
            $string = if ($answers[$k].b.Count -gt 1) {$answers[$k].b[0]} else {$answers[$k].b}
            $answer = ( $string | Select-String "\b[^\d]\w+\b" -AllMatches -CaseSensitive).Matches.Value
            $key = ""
            $choices = ($question.div.Where{ $_.class -eq "choices" }).p
            $answer.ForEach{  $key += [char](65 + $choices.IndexOf(($choices -match $_)[0])) }
            
            $answer = Add-XmlNode ("div", @{class = "answer"; "data-answer" = $key}) $question

            $explanation = Add-XmlNode ("div", @{class = "explanation"}) $answer
            $content = $answers[$k].OuterXml
            if ($answers[$k].b -notmatch "\d") { $content += $answers[$k].NextSibling.OuterXml }
            $explanation.InnerXml = $content -replace "i>", "b>" -replace "<a.*?/>"
        }
        
    }

    Set-Content "C:\github\gre\notes\test.html" $html.OuterXml.Replace("html[]", "html") -Encoding UTF8
    Set-Content $path $html.OuterXml.Replace("html[]", "html") -Encoding UTF8
}


function New-GreHtml ($content, $path) {
    function Remove-FootNote ($text) {
        $text = $text -replace "CHAPTER.*\r\n" # page footnote
        $text = $text -replace "\d{1,3}\r\n" # page number
        $text = $text -replace "GRE Verbal Reasoning Practice Questions\r\n" # page footnote
        $text = $text -replace "Question Type.*\r\n" # page footnote
        $text = $text -replace "\d{2,3} PART .*\r\n" # page footnote
        $text
    }
    
    function Update-Text($regex, $oldText, $newText) {
        foreach ($match in ($text | Select-String $regex -AllMatches -CaseSensitive).Matches) {
            $text = $text -replace (Invoke-Expression $oldText), (Invoke-Expression $newText)
        }
        $text
    }

    $beginning = "<div id=`"passage`" class=`"passage`"><p>"
    $end = "</p></div><div class=`"answer`" data-answer=`"`"><div class=`"explanation`"><p></p></div></div></div>"
    $start = "<div id=`"question`" data-choice-type=`"`"><div class=`"question`"><p>"
    $text = $content

    # remove extra text
    $text = $text -replace "PRACTICE( )?SET.*\r\n" # set title
    $text = $text -replace "SET.*\r\n" # question set easy medium hard title
    $text = $text -replace "For Questions.*(text|meaning)\." # question introduction
    $text = $text -replace "For each of.*instructed\.\r\n1\. ", $end + $start # text completion introduction
    $text = $text -replace "For each of.*\." # text completion introduction
    $text = $text -replace "For (the following|this question).*(apply|choices|meaning)\.\r\n" # question introduction
    $text = $text -replace "(L|l)ine \d" # passage line number
    $text = $text -replace "\. \. \. ", "&#8230; " # ellipse
    $text = $text -replace "This passage is adapted.*?\." # sentence euivalence introduction
    $text = Remove-FootNote $text
    Set-Content "C:\github\gre\notes\test.html" $text

    # add passage start then add question start to first question of each passage
    $text = $text -replace "Questions ", $end + $beginning + "Questions "
    $text = $text -replace "Question ", $end + $beginning + "Question "
    if ($text.Substring($end.length + $beginning.length, 20) -like "*Question*1*") {
        $text = $text.Substring($end.length + $text.IndexOf($end), $text.length - 1 - $end.length - $text.IndexOf($end))
    }
    
    $regex = "<p>Question(s)?\s(?<question>\d+?)\s" 
    $oldText = "`"(\u201D)?[(\r\n)| ]`$(`$match.Value.Trim(`"<p>Questions `"))\. `""
    $text = Update-Text $regex $oldText "`"</p></div>`$start`""

    # remove extra text again
    $text = $text -replace "Question(s)? .* passage(\.|:)"
    $text = $text -replace "(\r\n)*Blank \(i*\)"

    # add question 
    $text = $text -replace "(\u0002)?( |\r\n)A ", "</p></div><div class=`"choices`"><p>A " # add choice start
    Set-Content "C:\github\gre\notes\test.html" $text

    $prefixes = "[A-F]", "[0-9]."
    # remove chocie start in the middle, like remove E(start)A -> E A
    # remove chocie start in the start, like remove 6. (start)A book -> 6. A book
    $oldText = "`$match.Value"
    $newText = "`"`$(`$match.Value.Replace('</p></div><div class=`"choices`"><p>', ' '))`""
    
    foreach ($prefix in $prefixes) {
        $regex = "$prefix</p></div><div class=`"choices`"><p>A"
        $text = Update-Text $regex $oldText $newText
    }
    $text = $text -replace "class=`"passage`"><p></p></div><div class=`"choices`"><p>", "class=`"passage`"><p>"

    Set-Content "C:\github\gre\notes\test.html" $text

    foreach ($character in "BCDEFGHI".ToCharArray()) {
        $text = $text -replace " $character ", "</p><p>$character "
        if ( $character -eq 'I' ) {
            # remove I word not the I choice, well,</p><p>I -> well, I 
            $regex = "[^\w]</p><p>I " 
            $newText = "`"`$(`$match.Value.Replace('</p><p>', ' '))`""
            $text = Update-Text $regex $oldText $newText
        }
    }
    Set-Content "C:\github\gre\notes\test.html" $text

    $text = $text -replace "[(\r\n)| ]1\. ", $start # add question start and choice end
    $text = $text -replace "[(\r\n)| ]\d{1,2}\. ", $end + $start # add question start and choice end
    $text = $text -replace "\.\s+\r\n", "." # remove extra newline
    $text = $text -replace "(\r)?(\n)?" # remove extra newline
    $text = "<div id=`"questions`">$text$end</div>"
    Set-Content "C:\github\gre\notes\test.html" $text

    Set-Content $path $text.replace(" & ", " and ") -Encoding UTF8
    $xml = [xml] (Get-Content $path)
    $questions = Select-Xml "//div[@id=`"question`"]" $xml

    # traverse questions
    for ($i = 0; $i -lt $questions.Count; $i++) {
        $question = $questions[$i]
        $question.Node.SetAttribute("id", "question$($i+1)") # add question id
        $questionText = $question.Node.ChildNodes[0].InnerText

        # decide choice type
        if ($questionText.Contains("ii")) {
            # text-completetion 2 or 3 blanks
            $question.Node.SetAttribute("data-choice-type", "radio")
            function Set-Swap ([ref]$value1, [ref]$value2) {
                $temp = $value1.Value.InnerText
                $value1.Value.InnerText = $value2.Value.InnerText
                $value2.Value.InnerText = $temp
            }
            $choices = $question.Node.ChildNodes[1].ChildNodes

            # chonge choice order
            if ($choices.Count -eq 6) {
                #2 blanks
                Set-Swap ([ref]$choices[1]) ([ref]$choices[2]) # A DB ECF -> A BD ECF
                Set-Swap ([ref]$choices[3]) ([ref]$choices[4]) # ABD EC F -> ABD CE F
                Set-Swap ([ref]$choices[2]) ([ref]$choices[3]) # AB DC EF -> AB CD EF
                $question.Node.InnerXml = $question.Node.InnerXml.Replace("</p><p>D", "</p></div><div class=`"choices`"><p>D")
            }
            else {
                # 3 blanks
                Set-Swap ([ref]$choices[1]) ([ref]$choices[3]) # 1(4)7(2)58369 -> 1(2)7(4)58369
                Set-Swap ([ref]$choices[2]) ([ref]$choices[6]) # 12(7)458(3)69 -> 12(3)458(7)69
                Set-Swap ([ref]$choices[5]) ([ref]$choices[7]) # 12345(8)7(6)9 -> 12345(6)7(8)9
                $question.Node.InnerXml = $question.Node.InnerXml.Replace("</p><p>D", "</p></div><div class=`"choices`"><p>D")
                $question.Node.InnerXml = $question.Node.InnerXml.Replace("</p><p>G", "</p></div><div class=`"choices`"><p>G")
            }
        }
        elseif ($question.Node.ChildNodes[1].ChildNodes.Count -eq 6 -or $question.Node.ChildNodes[1].ChildNodes.Count -eq 3) { $question.Node.SetAttribute("data-choice-type", "checkbox") }
        elseif ($question.Node.ChildNodes[1].ChildNodes.Count -eq 5) { $question.Node.SetAttribute("data-choice-type", "radio") }
        else {
            $question.Node.SetAttribute("data-choice-type", "select")
        }

        # single question passage
        if (!$questionText.Contains("_") -and !$questionText.Contains("ii") -and $questionText.Contains(".") -and $questionText.Length -gt 300) {
            $passage = $questionText.Substring(0, (Get-AllIndexesOf $questionText ".")[-1] + 1)
            $passageNode = $xml.CreateElement("div")
            $passageNode.InnerXml = "<p>$passage</p>"
            $passageNode.SetAttribute("id", "passage")
            $passageNode.SetAttribute("class", "passage")

            $question.Node.AppendChild($passageNode) | Out-Null
            $question.Node.ChildNodes[0].InnerText = $questionText.Substring((Get-AllIndexesOf $questionText ".")[-1] + 2, $questionText.Length - (Get-AllIndexesOf $questionText ".")[-1] - 2)
        }
        $question.Node.ChildNodes[0].InnerText = [regex]::Replace($questionText, " \(.*?\)") # remove extra newline
    }
    Set-Content "C:\github\gre\notes\test.html" $xml.OuterXml
    $passages = Select-Xml "//div[@id=`"passage`"]" $xml
    for ($i = 0; $i -lt $passages.Count; $i++) {
        $passage = $passages[$i]
        $passage.Node.SetAttribute("id", "passage$($i+1)") # add question id

        if ($passage.Node.ParentNode.id -ne "questions") {
            # add single question passage id
            $passage.Node.ParentNode.SetAttribute("data-passage", $passage.Node.id)
        }

        for ($j = 0; $j -lt $xml.div.ChildNodes.Count; $j++) {
            $div = $xml.div.ChildNodes[$j];
            if ($div.id.Contains("passage")) {
                for ($k = $j + 1; $k -lt $xml.div.ChildNodes.Count; $k++) {
                    $node = $xml.div.ChildNodes[$k]
                    if ($node.id.Contains("passage") -or $node.InnerXml.Contains("id=`"passage")) { break }
                    else { $node.SetAttribute("data-passage", $div.id) }
                }
            }
        }
    }
    $html = "<!DOCTYPE html><html lang=`"en`"><head><title></title><script src=`"/index.js`"></script></head><body><main class=`"w3-container`">" + $xml.OuterXml + "</main></body></html>"
    #New-Item -Path $path -value $html -ErrorAction SilentlyContinue | Out-Null
    
    Set-Content $path $html -Encoding UTF8
}

function Get-Answer ($explanation, $path) {

    $xml = [xml] (Get-Content $path)
    $answers = Select-Xml "//div[@class=`"answer`"]" $xml

    if ($path.Contains("\notes\")) {
        Set-Content $explanation (Remove-FootNote (Get-Content $explanation -Encoding UTF8 -Raw)) -Encoding UTF8
        $content = Get-Content $explanation -Encoding UTF8
        $count = 0
        $choice = ($content[0] | Select-String "(?<questionID>.):" -AllMatches).Matches
        $number = 0
        foreach ($line in $content) {
            if ($line.Contains("Explanation ")) {
                $answer = ""
                $answer += $choice[$number++].Value[0] 
                while ($content[0][$choice[$number].Index - 13] -eq ";" -or $content[0][$choice[$number].Index - 12] -eq ";" -or $content[0][$choice[$number].Index - 8] -eq ";") { 
                    $answer += $choice[$number++].Value[0] 
                    #if ($number -eq $choice.Length) {break}
                }
                $answers[$count].Node.SetAttribute("data-answer", $answer)
                $answers[$count].Node.ChildNodes[0].InnerXml = "<p>" + $line.Replace("Explanation ") + "</p>"
                $count++
            }
        }
    }
    else {
        $explanation = Remove-FootNote $explanation
        $choices = ( $explanation | Select-String "\d{1,2}\. ([A-F]|\d{1,2})" -AllMatches).Matches
        for ($i = 0; $i -lt $choices.Count; $i++) {
            $start = $explanation.IndexOf($choices[$i].Value)

            # answer
            $answer = $choices[$i].Value[-1]
            
            $string = $explanation.substring($start + $choices[$i].Value.Length, 4)
            if ($string -eq " and") {
                $answer += $explanation.substring($start + $choices[$i].Value.Length + 5, 1)
            }
            elseif ($string -eq ", ") {
                $answer += $explanation.substring($start + $choices[$i].Value.Length + 2, 1)
                $answer += $explanation.substring($start + $choices[$i].Value.Length + 9, 1)
            }
            $answers[$i].Node.SetAttribute("data-answer", $answer)

            # explanation 
            $end = if ($i -eq $choices.Count - 1) {$explanation.Length - 1} else {$explanation.IndexOf($choices[$i + 1].Value)}
            
            $answers[$i].Node.ChildNodes[0].InnerXml = "<p>" + $explanation.substring($start, $end - $start) + "</p>"
        }
    }


    #New-Item -Path $path -value $xml.OuterXml -ErrorAction SilentlyContinue | Out-Null
    Set-Content $path $xml.OuterXml.Replace("html[]", "html") -Encoding UTF8
}

if ($type -eq "txt") {
    $splitIndex = $content.IndexOf("Answers")
    $question = $content.Substring(0, $splitIndex)
    $explanation = $content.Substring($splitIndex + 7, $content.Length - $splitIndex - 7) 
    New-GreHtml $question $path
    Get-Answer $explanation $path
}
else {
    Invoke-Expression "ConvertFrom-$set `$content `$path"
}

<#
. $PSScriptRoot\Utility.ps1
$condition = "`$flag = `$ie.Document.IHTMLDocument3_getElementById(`"MainContent_tblUserCabinet`")"
$ie = Invoke-InternetExplorer "https://onlineocr.net/documents" $condition
$ie.Visible = $true
$index = 1
$table = $ie.Document.IHTMLDocument3_getElementById("MainContent_tblUserCabinet")
$tr = $table.getElementsByTagName("tr")[$index]
do {
    $index += 2
    $tr.getElementsByTagName("a")[1].Click()
    while ($true) { 
        Start-Sleep 1 
        if($ie.Document.IHTMLDocument3_getElementById("fileuploadex")) { break }
    }
    $ie.Document.IHTMLDocument3_getElementById("MainContent_btnOCRConvert").Click()
    $count = 0
    while ($true -and $count -lt 5) { $count++ }
    $ie.Navigate("https://onlineocr.net/documents")
    while ($true) { 
        Start-Sleep 1 
        if($ie.Document.IHTMLDocument3_getElementById("MainContent_tblUserCabinet")) { break }
    }
    $table = $ie.Document.IHTMLDocument3_getElementById("MainContent_tblUserCabinet")
    while ($true) { 
        Start-Sleep 1 
        if($table.getElementsByTagName("tr")[$index]) { break }
    }
    $tr = $table.getElementsByTagName("tr")[$index]
} until ($tr.getElementsByTagName("td")[1].innerText)

(Get-ChildItem C:\Users\decisactor\Downloads\*.txt -Recurse).ForEach{
    Rename-Item $_ -NewName ($_.FullName -replace "\\\d{3}_","\")
}

#>