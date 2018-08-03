. $PSScriptRoot\Utility.ps1
$set = "kap"
$name = "$set-reading-example"
$type = "xml"
$content = Get-Content "C:\github\blog\text\gre\$set\$name.$type" -Raw -Encoding UTF8
$path = "C:\github\gre\$set\$name.html"

function ConvertFrom-Kap ($content, $path) {
    $content = $content -replace " xmlns=`".*?`"" -replace " id=`".*?`"" 
    $content = $content -replace " style=`".*?`"" -replace " data-uuid=`".*?`""
    $content = $content -replace "<hr.*?/>" -replace "\s+<a></a>" -replace "`r`n\s+<i", " <i"
    $content = $content -replace "`r`n\s+<span class=`"blank-s`"></span>", " ________"
    $content = $content -replace "(\s+)?</span>" -replace "`r`n\s+<span class=`"no-break`">", " "
    Set-Content -Path "C:\github\gre\notes\test.html" -Value $content

    $xml = [xml]($content)
    $html = [xml](Get-Content "C:\github\blog\text\gre\vocabulary.html")
    $questions = (Select-Xml "//div[@id=`"questions`"]" $html).Node
    $questions.InnerXml = ""

    # questions
    (Select-Xml "//li[@class=`"ktp-question`"]" $xml).Node.ForEach{
        $node = $_
        if($node.InnerXml.Contains("ktp-feedback")) { # explanation
            $question = (Select-Xml "//div[@id=`"question$($node.value)`"]" $html).Node
            if($question."data-choice-type" -ne "select") { 
                $answer = $node.ChildNodes[0].InnerXml.Replace(", ", "") 
                $text = $node.ChildNodes[1].InnerXml
            }
            else {
                $answer = $node.ChildNodes[0].ChildNodes[0].InnerText
                $text = $node.ChildNodes[0].InnerXml
            }
            $answer = Add-XmlNode ("div", @{class="answer"; "data-answer"=$answer}, "") $html $question
            $explanation = Add-XmlNode ("div", @{class="explanation"}, "") $html $answer
            $explanation.InnerXml = $text -replace "i>", "b>"
        }
        else { # question
            if($node.InnerXml.Contains("list-lower-alpha")) { $type = "checkbox" }
            else {$type = "radio"}
            $question = Add-XmlNode ("div", @{id="question$($node.value)";"data-choice-type"=$type}, "") $html $questions
            Add-XmlNode ("div", @{class="question"}, $node.ChildNodes[0].InnerXml) $html $question | Out-Null
            
            # choice
            
            $choices = (Select-Xml "//li[@value=`"$($node.value)`"]//ol[contains(@class,'ktp-answer-set')]" $xml).Node
            if(!$choices) { 
                $question.'data-choice-type' = "select" 
                return
            }
            if($node.InnerXml.Contains("blank-")) { # multiple blank
                $choices.ForEach{
                    $question.InnerXml += $_.OuterXml -replace "li>", "p>" -replace "ol", "div" -replace "ktp-answer-set.*?`"", "choices`""
                }
            }
            else {
                $question.InnerXml += $choices.OuterXml -replace "li>", "p>" -replace "ol", "div" -replace "ktp-answer-set.*?`"", "choices`""
            }
        }
    }

    # passages
    $nodes = (Select-Xml "//li[@class=`"ktp-stimulus`"]" $xml).Node
    for ($i = 1; $i -le $nodes.Count; $i++) {

        $passage = Add-XmlNode ("div", @{id="passage$i";class="passage"}, "") $html $questions
        $passage.InnerXml = $nodes[$i-1].InnerXml
        $nodes[$i-1].PreviousSibling.InnerText.Split(" ")[1] -split "\u2013"
        $start = [int]($nodes[$i-1].PreviousSibling.InnerText.Split(" ")[1] -split "\u2013")[0]
        $end = [int]($nodes[$i-1].PreviousSibling.InnerText.Split(" ")[1] -split "\u2013")[1]
        for ($j = $start; $j -le $end; $j++) {
            $question = (Select-Xml "//div[@id=`"question$j`"]" $html).Node
            if($question.'data-choice-type' -eq "select") {
                $sentences = $passage.InnerText -split "[?.!] "
                $index = $sentences.indexOf($question.ChildNodes[2]."data-answer".TrimEnd("`r`n ."))
                $question.ChildNodes[2].SetAttribute("data-answer", $index+1)
            }
            $question.SetAttribute("data-passage", "passage$i")
        }
    }

    Set-Content -Path $path -Value $html.OuterXml.Replace("html[]", "html") -Encoding UTF8
}

function Remove-FootNote ($text) {
    $text = [regex]::Replace($text, "CHAPTER.*\r\n", "") # page footnote
    $text = [regex]::Replace($text, "\d{1,3}\r\n", "") # page number
    $text = [regex]::Replace($text, "GRE Verbal Reasoning Practice Questions\r\n", "") # page footnote
    $text = [regex]::Replace($text, "Question Type.*\r\n", "") # page footnote
    $text = [regex]::Replace($text, "\d{2,3} PART .*\r\n", "") # page footnote
    $text
}

function New-GreHtml ($content, $path) {
    
    function Update-Text($regex, $oldText, $newText) {
        foreach ($match in ($text | Select-String $regex -AllMatches -CaseSensitive).Matches) {
            $text = [regex]::Replace($text, (Invoke-Expression $oldText), (Invoke-Expression $newText))
        }
        $text
    }

    $beginning = "<div id=`"passage`" class=`"passage`"><p>"
    $end = "</p></div><div class=`"answer`" data-answer=`"`"><div class=`"explanation`"><p></p></div></div></div>"
    $start = "<div id=`"question`" data-choice-type=`"`"><div class=`"question`"><p>"
    $text = $content

    # remove extra text
    $text = [regex]::Replace($text, "PRACTICE( )?SET.*\r\n", "") # set title
    $text = [regex]::Replace($text, "SET.*\r\n", "") # question set easy medium hard title
    $text = [regex]::Replace($text, "For Questions.*(text|meaning)\.", "") # question introduction
    $text = [regex]::Replace($text, "For each of.*instructed\.\r\n1\. ", $end + $start) # text completion introduction
    $text = [regex]::Replace($text, "For each of.*\.", "") # text completion introduction
    $text = [regex]::Replace($text, "For (the following|this question).*(apply|choices|meaning)\.\r\n", "") # question introduction
    $text = [regex]::Replace($text, "(L|l)ine \d", "") # passage line number
    $text = [regex]::Replace($text, "\. \. \. ", "&#8230; ") # ellipse
    $text = [regex]::Replace($text, "This passage is adapted.*?\.", "") # sentence euivalence introduction
    $text = Remove-FootNote $text
    Set-Content -Path "C:\github\gre\notes\test.html" -Value $text

    # add passage start then add question start to first question of each passage
    $text = [regex]::Replace($text, "Questions ", $end + $beginning + "Questions ")
    $text = [regex]::Replace($text, "Question ", $end + $beginning + "Question ")
    if ($text.Substring($end.length + $beginning.length,20) -like "*Question*1*") {
        $text = $text.Substring($end.length + $text.IndexOf($end), $text.length - 1 - $end.length - $text.IndexOf($end))
    }
    
    $regex = "<p>Question(s)?\s(?<question>\d+?)\s" 
    $oldText = "`"(\u201D)?[(\r\n)| ]`$(`$match.Value.Trim(`"<p>Questions `"))\. `""
    $text = Update-Text $regex $oldText "`"</p></div>`$start`""

    # remove extra text again
    $text = [regex]::Replace($text, "Question(s)? .* passage(\.|:)", "")
    $text = [regex]::Replace($text, "(\r\n)*Blank \(i*\)", "")

    # add question 
    $text = [regex]::Replace($text, "(\u0002)?( |\r\n)A ", "</p></div><div class=`"choices`"><p>A ") # add choice start
    Set-Content -Path "C:\github\gre\notes\test.html" -Value $text

    $prefixes = "[A-F]", "[0-9]."
    # remove chocie start in the middle, like remove E(start)A -> E A
    # remove chocie start in the start, like remove 6. (start)A book -> 6. A book
    $oldText = "`$match.Value"
    $newText = "`"`$(`$match.Value.Replace('</p></div><div class=`"choices`"><p>', ' '))`""
    
    foreach ($prefix in $prefixes) {
        $regex = "$prefix</p></div><div class=`"choices`"><p>A"
        $text = Update-Text $regex $oldText $newText
    }
    $text = [regex]::Replace($text, "class=`"passage`"><p></p></div><div class=`"choices`"><p>", "class=`"passage`"><p>")

    Set-Content -Path "C:\github\gre\notes\test.html" -Value $text

    foreach ($character in "BCDEFGHI".ToCharArray()) {
        $text = [regex]::Replace($text, " $character ", "</p><p>$character ")
        if( $character -eq 'I' ) {
            # remove I word not the I choice, well,</p><p>I -> well, I 
            $regex = "[^\w]</p><p>I " 
            $newText = "`"`$(`$match.Value.Replace('</p><p>', ' '))`""
            $text = Update-Text $regex $oldText $newText
        }
    }
    Set-Content -Path "C:\github\gre\notes\test.html" -Value $text

    $text = [regex]::Replace($text, "[(\r\n)| ]1\. ", $start) # add question start and choice end
    $text = [regex]::Replace($text, "[(\r\n)| ]\d{1,2}\. ", $end + $start) # add question start and choice end
    $text = [regex]::Replace($text, "\.\s+\r\n", ".") # remove extra newline
    $text = [regex]::Replace($text, "(\r)?(\n)?", "") # remove extra newline
    $text = "<div id=`"questions`">$text$end</div>"
    Set-Content -Path "C:\github\gre\notes\test.html" -Value $text

    Set-Content -Path $path -Value $text.replace(" & ", " and ") -Encoding UTF8
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
            $passageNode.innerXml = "<p>$passage</p>"
            $passageNode.SetAttribute("id", "passage")
            $passageNode.SetAttribute("class", "passage")

            $question.Node.AppendChild($passageNode) | Out-Null
            $question.Node.ChildNodes[0].InnerText = $questionText.Substring((Get-AllIndexesOf $questionText ".")[-1] + 2, $questionText.Length - (Get-AllIndexesOf $questionText ".")[-1] - 2)
        }
        $question.Node.ChildNodes[0].InnerText = [regex]::Replace($questionText, " \(.*?\)", "") # remove extra newline
    }
    Set-Content -Path "C:\github\gre\notes\test.html" -Value $xml.OuterXml
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
                    if ($node.id.Contains("passage") -or $node.innerXml.Contains("id=`"passage")) { break }
                    else { $node.SetAttribute("data-passage", $div.id) }
                }
            }
        }
    }
    $html = "<!DOCTYPE html><html lang=`"en`"><head><title></title><script src=`"/initialize.js`"></script></head><body><main class=`"w3-container`">" + $xml.OuterXml + "</main></body></html>"
    New-Item -Path $path -value $html -ErrorAction SilentlyContinue | Out-Null
    Set-Content -Path $path -Value $html -Encoding UTF8
}

function Get-Answer ($explanation, $path) {

    $xml = [xml] (Get-Content $path)
    $answers = Select-Xml "//div[@class=`"answer`"]" $xml

    if($path.Contains("\notes\")) {
        Set-Content $explanation (Remove-FootNote (Get-Content $explanation -Encoding UTF8 -Raw)) -Encoding UTF8
        $content = Get-Content $explanation -Encoding UTF8
        $count = 0
        $choice = ($content[0] | Select-String "(?<questionID>.):" -AllMatches).Matches
        $number = 0
        foreach($line in $content) {
            if ($line.Contains("Explanation ")) {
                $answer = ""
                $answer += $choice[$number++].Value[0] 
                while($content[0][$choice[$number].Index - 13] -eq ";" -or $content[0][$choice[$number].Index - 12] -eq ";" -or $content[0][$choice[$number].Index - 8] -eq ";") { 
                    $answer += $choice[$number++].Value[0] 
                    #if($number -eq $choice.Length) {break}
                }
                $answers[$count].Node.SetAttribute("data-answer",$answer)
                $answers[$count].Node.ChildNodes[0].InnerXml = "<p>"+$line.Replace("Explanation ", "")+"</p>"
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
            $end = if($i -eq $choices.Count - 1) {$explanation.Length - 1} else {$explanation.IndexOf($choices[$i+1].Value)}
            
            $answers[$i].Node.ChildNodes[0].InnerXml = "<p>"+$explanation.substring($start, $end - $start)+"</p>"
        }
    }


    New-Item -Path $path -value $xml.OuterXml -ErrorAction SilentlyContinue | Out-Null
    Set-Content -Path $path -Value $xml.OuterXml.Replace("html[]", "html") -Encoding UTF8
}

if ($type -eq "txt") {
    $splitIndex = $content.IndexOf("Answers")
    $question = $content.Substring(0, $splitIndex)
    $explanation = $content.Substring($splitIndex + 7, $content.Length - $splitIndex - 7) 
    New-GreHtml $question $path
    Get-Answer $explanation $path
}
else {
    ConvertFrom-Kap $content $path
}

<#
(Get-ChildItem "C:\github\blog\text\pq-reading-*.html").ForEach{
    Copy-Item $_ ($_.PSPath -Replace "reading" , "text")
    Copy-Item $_ ($_.PSPath -Replace "reading" , "sentence")
}#>