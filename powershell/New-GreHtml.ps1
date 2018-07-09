. .\Utility.ps1
$name = "pt1-verbal1"
$explanation = "C:\github\blog\text\$name-exp.html"
$content = Get-Content "C:\github\blog\text\$name.html" -Raw -Encoding UTF8
$path = "C:\github\gre\og\$name.html"
# Set-Content -Path "C:\github\gre\og\test.html" -Value $text

function New-Og ($content, $path) {
    $beginning = "<div id=`"passage`" class=`"passage`"><p>"
    $end = "</p></div><div class=`"answer`" data-answer=`"`"><div class=`"explanation`"><p></p></div></div></div>"
    $start = "<div id=`"question`" data-choice-type=`"`"><div class=`"question`"><p>"
    $text = $content

    # remove extra text
    $text = [regex]::Replace($text, "SET.*\r\n", "") # question set easy medium hard title
    $text = [regex]::Replace($text, "For Questions.*text\.", "") # text completion introduction
    $text = [regex]::Replace($text, "For each of.*instructed\.\r\n1\. ", $end + $start) # text completion introduction
    $text = [regex]::Replace($text, "For each of.*instructed\.", "") # text completion introduction
    $text = [regex]::Replace($text, "For the following .*that apply.\r\n", "") # multi select passage question
    $text = [regex]::Replace($text, "For Questions.*in meaning\.", "") # sentence euivalence introduction
    $text = [regex]::Replace($text, "line \d", "") # passage line number
    $text = [regex]::Replace($text, "\d{2,3}\r\n", "") # page number
    $text = [regex]::Replace($text, "GRE Verbal Reasoning Practice Questions\r\n", "") # page footnote
    $text = [regex]::Replace($text, "\. \. \. ", "&#8230; ") # ellipse

    # add passage start then add question start to first question of each passage
    $text = [regex]::Replace($text, "Questions ", $end + $beginning + "Questions ")
    $regex = "\nQuestions\s(?<questionID>\d+?)\s" 
    foreach ($match in ($content | Select-String $regex -AllMatches).Matches) {
        $text = [regex]::Replace($text, "\.(\u201D)*\r\n$($match.Value.Trim("`nQuestions ")). ", ".</p></div>$start")
    }

    # remove extra text again
    $text = [regex]::Replace($text, "Questions .* passage.\r\n", "")
    $text = [regex]::Replace($text, "(\r\n)*Blank \(i*\)", "")

    # add question 
    $text = [regex]::Replace($text, "\u0002 A", "</p></div><div class=`"choices`"><p>A") # add choice start
    $text = [regex]::Replace($text, " \u0002 ", "</p><p>") # replace choice middle
    $text = [regex]::Replace($text, "\r\n1\. ", $start) # add question start and choice end
    $text = [regex]::Replace($text, "\r\n\d. ", $end + $start) # add question start and choice end
    $text = [regex]::Replace($text, "\.\s+\r\n", ".") # remove extra newline
    $text = [regex]::Replace($text, "\r\n</p>", "</p>") # remove extra newline
    $text = "<div id=`"questions`">$text$end</div>"

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
        if (!$questionText.Contains("_") -and $questionText.Contains(".") -and $questionText.Length -gt 300) {
            $passage = $questionText.Substring(0, (Get-AllIndexesOf $questionText ".")[-1] + 1)
            $passageNode = $xml.CreateElement("div")
            $passageNode.innerXml = "<p>$passage</p>"
            $passageNode.SetAttribute("id", "passage")
            $passageNode.SetAttribute("class", "passage")

            $question.Node.AppendChild($passageNode) | Out-Null
            $question.Node.ChildNodes[0].InnerText = $questionText.Substring((Get-AllIndexesOf $questionText ".")[-1] + 2, $questionText.Length - (Get-AllIndexesOf $questionText ".")[-1] - 2)
        }
    }

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

function Get-OgAnswer ($explanation, $path) {
    $content = Get-Content $explanation -Encoding UTF8
    $xml = [xml] (Get-Content $path)
    $answers = Select-Xml "//div[@class=`"answer`"]" $xml
    $count = 0
    $choice = ($content[-1] | Select-String "(?<questionID>.):" -AllMatches).Matches
    $number = 0
    foreach($line in $content) {
        if ($line.Contains("Explanation ")) {
            $answer = ""
            foreach ($match in ($line | Select-String "\(Choice\s(?<questionID>.)" -AllMatches).Matches) {
                $answer+=$match.Value.Replace("(Choice ","")
            }
            if(!$answer) { 
                $answer += $choice[$number++].Value[0] 
                if($content[-1][$choice[$number].Index - 13] -eq ";") {
                    $answer += $choice[$number++].Value[0] 
                }
            }
            $answers[$count].Node.SetAttribute("data-answer",$answer)
            $answers[$count].Node.ChildNodes[0].InnerXml = "<p>"+$line.Replace("Explanation ", "")+"</p>"
            $count++
        }
    }

    New-Item -Path $path -value $xml.OuterXml -ErrorAction SilentlyContinue | Out-Null
    Set-Content -Path $path -Value $xml.OuterXml -Encoding UTF8
}

New-Og $content $path
Get-OgAnswer $explanation $path
