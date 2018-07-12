. .\Utility.ps1
$set = "mh"
$name = "mh-sentence-es1"
#$explanation = "C:\github\blog\text\$name-exp.html"
$content = Get-Content "C:\github\blog\text\gre\$set\$name.html" -Raw -Encoding UTF8
$splitIndex = $content.IndexOf("Answers")
$question = $content.Substring(0, $splitIndex)
$explanation = $content.Substring($splitIndex + 7, $content.Length - $splitIndex - 7) 
$path = "C:\github\gre\$set\$name.html"
# Set-Content -Path "C:\github\gre\og\test.html" -Value $text

function Remove-FootNote ($text) {
    $text = [regex]::Replace($text, "CHAPTER.*\r\n", "") # page footnote
    $text = [regex]::Replace($text, "\d{2,3}\r\n", "") # page number
    $text = [regex]::Replace($text, "GRE Verbal Reasoning Practice Questions\r\n", "") # page footnote
    $text = [regex]::Replace($text, "Question Type.*\r\n", "") # page footnote
    $text = [regex]::Replace($text, "\d{2,3} PART .*\r\n", "") # page footnote
    $text
}

function New-GreHtml ($content, $path) {
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
    $text = [regex]::Replace($text, "For the following .*(apply|choices|meaning)\.\r\n", "") # question introduction
    $text = [regex]::Replace($text, "(L|l)ine \d", "") # passage line number
    $text = [regex]::Replace($text, "\. \. \. ", "&#8230; ") # ellipse
    $text = [regex]::Replace($text, "This passage is adapted.*?\.", "") # sentence euivalence introduction
    $text = Remove-FootNote $text
    Set-Content -Path "C:\github\gre\og\test.html" -Value $text

    # add passage start then add question start to first question of each passage
    $text = [regex]::Replace($text, "Questions ", $end + $beginning + "Questions ")
    $text = [regex]::Replace($text, "Question ", $end + $beginning + "Question ")
    if ($text.Substring($end.length + $beginning.length,20) -like "*Question*1*") {
        $text = $text.Substring($end.length,$text.length - $end.length - 1)
    }
    $regex = "\nQuestion(s)?\s(?<question>\d+?)\s" 
    foreach ($match in ($content | Select-String $regex -AllMatches).Matches) {
        $text = [regex]::Replace($text, "(\u201D)?[(\r\n)| ]$($match.Value.Trim("`nQuestions "))\. ", "</p></div>$start")
    }

    # remove extra text again
    $text = [regex]::Replace($text, "Question(s)? .* passage\.", "")
    $text = [regex]::Replace($text, "(\r\n)*Blank \(i*\)", "")

    # add question 
    $text = [regex]::Replace($text, "(\u0002)?( |\r\n)A ", "</p></div><div class=`"choices`"><p>A ") # add choice start
    Set-Content -Path "C:\github\gre\og\test.html" -Value $text

    # remove chocie start in the middle, like remove E(start)A -> E A
    $regex = "[A-F]</p></div><div class=`"choices`"><p>A" 
    foreach ($match in ($text | Select-String $regex -AllMatches -CaseSensitive).Matches) {
        $text = [regex]::Replace($text, "$($match.Value)", "$($match.Value.Replace('</p></div><div class="choices"><p>', ' '))")
    }

    # remove chocie start in the start, like remove 6. (start)A book -> 6. A book
    $regex = "[0-9].</p></div><div class=`"choices`"><p>A" 
    foreach ($match in ($text | Select-String $regex -AllMatches -CaseSensitive).Matches) {
        $text = [regex]::Replace($text, "$($match.Value)", "$($match.Value.Replace('</p></div><div class="choices"><p>', ' '))")
    }
    Set-Content -Path "C:\github\gre\og\test.html" -Value $text

    foreach ($character in "BCDEFGHI".ToCharArray()) {
        $text = [regex]::Replace($text, " $character ", "</p><p>$character ")
        if( $character -eq 'I' ) {
            # remove I word not the I choice, well,</p><p>I -> well, I 
            $regex = "[^\w]</p><p>I " 
            foreach ($match in ($text | Select-String $regex -AllMatches).Matches) {
                $text = [regex]::Replace($text, "$($match.Value)", "$($match.Value.Replace('</p><p>', ' '))")
            }
        }
    }
    Set-Content -Path "C:\github\gre\og\test.html" -Value $text

    $text = [regex]::Replace($text, "[(\r\n)| ]1\. ", $start) # add question start and choice end
    $text = [regex]::Replace($text, "[(\r\n)| ]\d{1,2}\. ", $end + $start) # add question start and choice end
    $text = [regex]::Replace($text, "\.\s+\r\n", ".") # remove extra newline
    $text = [regex]::Replace($text, "(\r)?(\n)?", "") # remove extra newline
    $text = "<div id=`"questions`">$text$end</div>"
    Set-Content -Path "C:\github\gre\og\test.html" -Value $text

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
    #$html = $xml.OuterXml
    New-Item -Path $path -value $html -ErrorAction SilentlyContinue | Out-Null
    Set-Content -Path $path -Value $html -Encoding UTF8
}

function Get-Answer ($explanation, $path) {

    $xml = [xml] (Get-Content $path)
    $answers = Select-Xml "//div[@class=`"answer`"]" $xml

    if($path.Contains("\og\")) {
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
        $choices = ( $explanation | Select-String "\d{1,2}\. [A-F]" -AllMatches).Matches
        for ($i = 0; $i -lt $choices.Count; $i++) {
            $start = $explanation.IndexOf($choices[$i].Value)

            # answer
            $answer = $choices[$i].Value[-1]
            
            $string = $explanation.substring($start + $choices[$i].Value.Length, 2)
            if ($string -eq " a") {
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
    Set-Content -Path $path -Value $xml.OuterXml.Remove("html[]", "html") -Encoding UTF8
}

New-GreHtml $question $path
Get-Answer $explanation $path

<#
(Get-ChildItem "C:\github\blog\text\pq-reading-*.html").ForEach{
    Copy-Item $_ ($_.PSPath -Replace "reading" , "text")
    Copy-Item $_ ($_.PSPath -Replace "reading" , "sentence")
}#>