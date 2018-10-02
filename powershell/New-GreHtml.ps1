. $PSScriptRoot\Utility.ps1
$setNum = 0
$content = ""
$set = "pr"
$name = "$set-pd-verbal"
$type = "html"
$ebooks = "C:\github\temp\ebooks"
$testHtml = "C:\github\temp\files\test.html"
$path = "C:\github\gre\$set\$name.html"
$prepositions = "\b(about|across|after|against|along|and|around|at|between|by|down|for|from|in|into|of|off|on|onto|over|through|to|toward|under|up|with)\b"

function Get-ImageText ($path, $scale = 100) {
    <#
    $length = 3
    $options = @()
    for ($i = 0; $i -lt $length; $i++) {
        $width = $img.Width * $scale / 100 / $length
        $height = $img.Height * $scale / 100
        $rect = New-Object System.Drawing.Rectangle ($width * $i),0,$width,$height
        $text = Export-ImageText $path.Replace("_r1","") $rect
        $text = $text -replace "^.*?\n" -replace "\n+", "`n"
        $words = ($text | Select-String $regex -AllMatches).Matches.Value
        if ($words.Length -gt 3) {
            for ($j = 0; $j -lt $words.Count; $j+=2) {
                $options += $words[$j] + " " + $words[$j+1]
            }
        }
        else {  $words.ForEach{ $options += $_ } }
    }
    #>
    #Load required assemblies and get object reference 
    if (!$wordApp) {
        $word = Get-Process "winword" -ErrorAction SilentlyContinue
        if ($word) { Stop-Process $word }
        $wordApp = New-Object -ComObject Word.Application 
        $wordApp.Documents.Add() | Out-Null
    }
    [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    $i = new-object System.Drawing.Bitmap($path)
    $path = $path -replace "\.(\w+)$", ".jpg"
    #Save with the image in the desired format 
    While(!(Test-Path $path)) {
        $i.Save($path,"jpeg")
    } 
    Resize-Image $path $path.Replace("_r1","") -Scale $scale
    $text = Export-ImageText $path.Replace("_r1","")
    Remove-Item $path.Replace("_r1","")
    $text -replace "(\w)\|(\w)", "`$1l`$2"
}

function Get-EpubHtml {
# Get Epub
    if ($name -match "-drill") {
        $start = 2; $end = 27
        $ebook = "1,014 GRE Practice Questions, 3rd Edition\OEBPS"
        $files = Get-ChildItem "$ebooks\$ebook\Revi_9780307945396_epub_c02_s*"
        Import-Module "PSImaging"
    }
    elseif ($name -match "-pd") {
        $start = 2; $end = 5
        $ebook = "Verbal Workout for the GRE, 6th Edition\OEBPS"
        $files = Get-ChildItem "$ebooks\$ebook\Prin_9781524710323_epub3_c0*"
    }
    for ($i = $start; $i -lt $end; $i++) {
        $content += Get-Content $files[$i] -Encoding UTF8
    }
    "<b>$content</b>"
}

function Get-Questions ($xml) {

    if ($set -match "mh") {
        $questions = (Select-Xml "//p[contains(@class,'ques')]" $xml).Node
    }
    elseif ($set -match "kap") {
        $questions = (Select-Xml "//li[@class=`"ktp-question`"]" $xml).Node
    }
    elseif ($set -match "pri") {
        <#$questions = (Select-Xml "//p[contains(@class,'Test_sample')]" $xml).Node.Where{$_.PreviousSibling.class -match "Test_sample2l" -or $_.PreviousSibling.PreviousSibling.class -match "Test_sample2l" -and $_.NextSibling.class -match "block_|square|circle" -or ($_.PreviousSibling.class -match "Test_sample2l" -and $_.InnerText -match "Select the sentence")}#>
    }
    elseif ($name -match "\-drill") {
        $questions = (Select-Xml "//a" $xml).Node.Where{$_.href -match "#QST\d+a$"}.ParentNode.NextSibling
        $explanations = (Select-Xml "//a" $xml).Node.Where{$_.href -match "#QST\d+$" -and $_.ParentNode.OuterXml -match "<strong>"}.ParentNode
    }
    elseif ($name -match "pd") { 
        $questions = (Select-Xml "//a" $xml).Node.Where{$_.href -match "c0([45]\-ans|3\-drl)\d+a$"}.ParentNode.ParentNode
        $explanations = (Select-Xml "//a" $xml).Node.Where{$_.id -match "c0([45]\-ans|3\-drl)\d+a$"}.ParentNode.ParentNode
    }
    elseif ($set -match "mp") {
        $questions = (Select-Xml "//p[contains(@class,'hang')]" $xml).Node.Where{$_.NextSibling.Name -match "table" -or $_.NextSibling.InnerXml -match "sq.jpg" -or $_.InnerXml -match "Select the sentence" -or ($_.class -match "hang-num" -and $_.NextSibling.class -match "alpha-list-h")}

        $answers = (Select-Xml "//p[contains(@class,'body-text')]" $xml).Node.Where{$_.b -match "\d{1,2}\." -or $_.InnerXml -match "\d{1,2}\. <b>" -or $_.PreviousSibling.class -match "alpha-list-h|hang-nss" -or $_.PreviousSibling.InnerXml -match "Select the sentence" -or ($_.PreviousSibling.PreviousSibling.class -match "alpha-list-h|hang-nss" -and $_.PreviousSibling.id -match "page") -and ( $_.InnerText.Length -gt 100 -or $_.b -match "Step \d:")}

        if ($path -match "reading") { $questions = $answers}
        $count = 0; # passagw count
    }

}

function ConvertFrom-Epub ($path) {
    
    function Get-QuestionsDiv ([ref]$setNum, [ref]$path, [ref]$html) {

        $setNum.Value += 1
        $path.Value = $path.Value -replace "\d*\-verbal", "$($setNum.Value)-verbal"
        if (Test-Path $path.Value) { 
            $html.Value = [xml](Get-Content $path.Value)
            $questionsDiv = (Select-Xml "//div[@id='questions']" $html.Value).Node
        }
        else {
            $html.Value = [xml](Get-Content "C:\github\gre\gre.html")
            $questionsDiv = Add-XmlNode ("div", @{id = "questions"}) (Select-Xml "//main" $html.Value).Node
        }
        $questionsDiv
    }       
    
    function Remove-TagContent ($content) {
        $content 
    }

    $content = Get-EpubHtml 

    # Get xml
    if ($set -match "kap") {
        $content = $content -replace " xmlns=`".*?`"" -replace " id=`".*?`"" 
        $content = $content -replace " style=`".*?`"" -replace " data-uuid=`".*?`""
        $content = $content -replace "<hr.*?/>" -replace " +<a>( +`r`n +)*</a>" -replace "`r`n +<i", " <i"
        $content = $content -replace "(`r`n)? +<span class=`"blank-s`"></span>", " ________"

        $regex = "(`r`n)? +<span class=`"no-break`">(`r`n +)?(?<word>.*?)(`r`n +)?</span>"
        foreach ($match in ($content | Select-String $regex -AllMatches -CaseSensitive).Matches) {
            $content = $content.Replace($match.Value, (" " + $match.Groups["word"].Value))
        }
    }
    $content = $content -replace " xmlns(:epub)?=`".*?`"" -replace " epub:type=`".*?`"" #-replace " style=`".*?`"" 
    Set-Content $testHtml $content -Encoding UTF8
    $xml = [xml]($content)

    for ($i = 0; $i -lt $questions.Count; $i++) {
        $question = $questions[$i]
        if ($question.InnerXml -match "select all that apply" -and $question.NextSibling.InnerXml -notmatch "src=") {
            $question = $question.NextSibling}
        # Question Type
        if ($question.InnerXml.Contains("Select the sentence")) { $type = "select" }
        else {$type = "radio"}

        #region Question Text
        if ($set -match "mh") {
            $id = $question.ChildNodes[0].InnerText
            $InnerXml = $question.InnerXml
        }
        elseif ($set -match "kap") {
            $id = $question.value
            $InnerXml = $question.ChildNodes[0].InnerXml
        }
        elseif ($set -match "pr") {
            $InnerXml = $question.OuterXml -replace "<p.*?>", "<p>"
            
            if ($name -match "\-drill") { 
                $explanation = $explanations[$i].ParentNode
                $InnerXml = "<p>" + $question.p."#text" + "</p>"
            }
            elseif ($name -match "pd") { 
                $explanation = $explanations[$i]
                $InnerXml = $question.OuterXml -replace "<p.*?>(.*)</p>", "<p>`$1</p>"
            }
        }
        elseif ($set -match "mp") {
            $id = $i + 1
            $InnerXml = $question.OuterXml -replace "<p.*?`">", "<p>"
        }

        #endregion

        #region Explanation
        
        $num = ($explanation.InnerText | Select-String "\b\d\b").Matches.Value
        $content = (Select-Xml ".//strong" $explanation).Node.InnerText
        if ($type -eq "select") {
            $answers = $content -replace "^\d+\.|\s{2,}|\.\.\."
        }
        else {
            $answers = ( $content | Select-String "$regex|\b[A-F]\b" -AllMatches).Matches.Value
        }
        $content = ""
        do { # $explanation.id -match "p\d{2,3}"
            $content += $explanation.OuterXml -replace "<a.*?/a?>|<span.*?/(span)?>" -replace "<p.*?>", "<p>"
            $explanation = $explanation.NextSibling
        } while ($explanation -and $explanation.OuterXml -notmatch "<a.*href")
        $explanation = $content
        #endregion

        if ($num -eq "1") { 
            $questionsDiv = Get-QuestionsDiv ([ref]$setNum) ([ref]$path) ([ref]$html)
        }

        if ((Select-Xml "//div[contains(@id,'question')]" $questionsDiv)) {
            $id = (Select-Xml "//div[contains(@id,'question')]" $questionsDiv).Node.Count
            if (!$id) { $id = 1}
        }
        
        Write-Host "Question $id"
        $questionDiv = Add-XmlNode ("div", @{id = "question$id"; "data-choice-type" = $type}) $questionsDiv
        Add-XmlNode ("div", @{class = "question"}, $InnerXml) $questionDiv | Out-Null

        #endregion

        #region Choices
        if ($type -ne "select") {
            $choice = $question.NextSibling
            if ($choice.InnerXml -match "_sq_|_circle_") { 
                $choicesDiv = Add-XmlNode ("div", @{class = "choices"}) $question 
                $choice.ChildNodes[0].ChildNodes.ForEach{ Add-XmlNode ("p", $_.InnerText) $choicesDiv | Out-Null }
            }
            elseif ($choice.OuterXml -match "table>" -or (Select-Xml "*/img" $question).Count -eq 1 ) {#-or (Select-Xml "*/img" $choice).Count -eq 1) {
                if ($choice.OuterXml -match "table>") {
                    $options = (Select-Xml "table//td" $choice).Node.InnerText.Where{$_ -notmatch "blank "} 
                } 
                elseif ((Select-Xml "*/img" $question).Count -eq 1) { # Convert image to Choice
                    $words = ($explanation | Select-String "(?<=<em>).*?(?=</em)" -AllMatches).Matches.Value -replace "\W"
                    if ($InnerXml -match "i{3}") {
                        $length = 9
                        $scale =  4; $step =  25; $threshold =  500 
                    } 
                    else {
                        $length = if ($InnerXml -match "i{2}"){ 6 } else {5}
                        $scale =  2 ; $step =  50; $threshold =  200 
                    }

                    $choices = @()
                    for ($j = 0; $j -lt $length; $j++) { $choices += "" }

                    do {
                        if ($scale * $step -gt $threshold) { 
                            $step -= 10
                            if ($step -eq 0) { $step = 25; $threshold = 500 }
                            $scale = [Math]::Floor(100 / $step)
                        } 
                        if ($step -lt 0 ) {
                            $choices.ForEach{
                                if ($wordApp.GetSpellingSuggestions($_) | Select-Object) {
                                    $_ = ( $wordApp.GetSpellingSuggestions($_) | ForEach-Object {$_.Name})[0]
                                }
                            }
                        }
                        # get option text
                        $content = Get-ImageText "$ebooks\$ebook\$($question.p.img.src)" ($scale*$step)
                        $options = if ($InnerXml -match "i{2,3}") { $content[1] -replace "^.*?\n"} else {$content[1]}
                        $options = ($options | Select-String $regex -AllMatches).Matches.Value
                        $options = $options.Where{$_ -match "\w+" -and $_ -notmatch "Blank|i{2,3}"}

                        # set chioce text
                        for ($j = 0; $j -lt $options.Count -and $options.Count -eq $length; $j++) {
                            if ($options[$j] -in $words -or ($wordApp.CheckSpelling($options[$j]) -and 
                            !($wordApp.GetSpellingSuggestions($options[$j]) | Select-Object) -and 
                            $options[$j] -cnotmatch "[A-Z]|\d" -and $options[$j] -ne $choices[$j]) -or 
                            $explanation -match ($options[$j] -replace " +$prepositions|^an? ")) {
                                if ($options[$j] -eq "accolades") { $options[$j] = "approbation"}
                                if ($options[$j] -eq "epitome") { $options[$j] = "esoteric"}
                                $choices[$j] = $options[$j]
                            }
                        }
                        $flag = [int]$choices.Where{$_ -eq ""}.Count -ne 0 -or 
                        [int]$answers.Where{($choices -join "") -notmatch $_}.Where{$_ -cnotmatch "[A-E]"}.Count -ne 0 
                        if ($options.Count -gt 15) { 
                            $flag = $false; $choices = @("") }
                    } while ( $choices.Length -eq 0 -or $flag -and $scale++)

                    $options = $choices
                }
                
                # Rearrange Choice
                if ($options.Count -ge 9) {
                    for ($j = 0; $j -lt 3; $j++) {
                        $choicesDiv = Add-XmlNode ("div", @{class = "choices"}) $questionDiv
                        for ($k = 0; $k -lt 3; $k++) {
                            Add-XmlNode ("p", $options[$j + $k * 3]) $choicesDiv | Out-Null
                        }
                    }
                }
                elseif ($options.Count -ge 6) {
                    for ($j = 0; $j -lt 2; $j++) {
                        $choicesDiv = Add-XmlNode ("div", @{class = "choices"}) $questionDiv
                        for ($k = 0; $k -lt 3; $k++) {
                            Add-XmlNode ("p", $options[$j + $k * 2]) $choicesDiv | Out-Null
                        }
                    }
                }
                else {
                    $choicesDiv = Add-XmlNode ("div", @{class = "choices"}) $questionDiv
                    $options.ForEach{ Add-XmlNode ("p", $_) $choicesDiv | Out-Null }
                }
            }
            elseif ((Select-Xml "*/img" $choice).Count -gt 1) { # Choice enclose by div
                $choice = $choice.InnerXml -replace "<p.*?>", "<p>" -replace "<img.*?>"
                $choicesDiv = Add-XmlNode ("div", @{class = "choices"}, $choice) $questionDiv
            }
            elseif ($choice.InnerXml -match "src=`".*?.jpg`"") {
                $choicesDiv = Add-XmlNode ("div", @{class = "choices"}) $questionDiv
                while ($choice.InnerXml -match "src=`".*?.jpg`"") {
                    Add-XmlNode ("p", ($choice.InnerText -replace "\u00A0")) $choicesDiv | Out-Null
                    $choice = $choice.NextSibling
                }
            }
        }
        #endregion

        #region Answer

        for ($j = 0; $j -lt $answers.Count -and $type -ne "select"; $j++) {
            if($answers[$j].length -ne 1) {
                $options = (Select-Xml "div[@class='choices']/p" $questionDiv).Node.InnerText
                $answers[$j] = "$([char]($options.IndexOf( $options.Where{ $_ -match $answers[$j] }[0] ) + 65))"
            }
        }
        
        #endregion
        
        $explanation = Add-XmlNode ("div", @{class = "explanation"; "data-answer" = ($answers -join "")}, $explanation) $questionDiv
        if ((Select-Xml "div[@class='choices']/p" $questionDiv).Count -eq 3 -or 
        ($InnerXml -notmatch "i{2,3}" -and $answers.Count -eq 2)) { 
            $questionDiv.SetAttribute("data-choice-type", "checkbox") 
        }

        if($num -ne 1) {
            $html.InnerXml = $html.InnerXml -replace "</div></main>", "$($questionDiv.OuterXml)</div></main>"
        }

        $html.InnerXml = $html.InnerXml -replace " {2,}", " "
        $content = (Format-Html $html.OuterXml).Replace("html[]", "html")
        Set-Content $testHtml $content -Encoding UTF8 
        Set-Content $path $content -Encoding UTF8
    }

    #region Passage 
    if ($name -match "pd") {
        $nodes = (Select-Xml "//div[@class=`"dis_img2`"]" $xml).Node.PreviousSibling
        Import-Module "PSImaging"
        $folder = "$ebooks\Verbal Workout for the GRE, 6th Edition\OEBPS\"
    }
    else {
        if ($name -match "\-drill") {
            $nodes = (Select-Xml "//div[contains(@class,'block_rc')]" $xml).Node
        }
        elseif ($name -match "kap") {
            $nodes = (Select-Xml "//p[@class=`"Test_samplen`"]" $xml).Node.Where{$_.InnerText -cmatch "Question"}
        }
    }

    $setNum = 0

    for ($i = 0; $i -lt $nodes.Count; $i++) {

        #region Range

        if ($name -match "pd") { 
            $src = $jpg.Replace($folder, "")
            for ($j = 1; $j -le $questions.Count; $j++) {
                $question = $questions[$j-1].ParentNode.PreviousSibling
                while ($question.InnerXml -notmatch "_\d+_r1.jpg") {
                    $question = $question.PreviousSibling
                }
                if ($question.InnerXml.Contains($src)) {
                    (Select-Xml "//div[@id=`"question$j`"]" $html).Node.SetAttribute("data-passage", "passage$id")
                }
            }
        }
        else {
            if ($name -match "\-drill") { 
                $range = $nodes[$i].PreviousSibling.InnerText
            }
            else { 
                $range = $nodes[$i].InnerText -replace "\u2013", " to "
            }
            $ranges = ($range | Select-String "\d+" -AllMatches).Matches.Value
            $start = [int]$ranges[0]
            $end = if ($ranges[1]) { [int]$ranges[1] } else { $start }
            if ($start -eq 1) { $id = 1}
            Write-Host "Passage $id"

            if ($id -eq "1") {$questionsDiv = Get-QuestionsDiv ([ref]$setNum) ([ref]$path) ([ref]$html) }

            $questions = (Select-Xml "//div[@id=`"questions`"]" $html).Node.div.Where{$_.InnerXml -notmatch "_"}
            for ($j = $start; $j -le $end; $j++) {
                $question = $questions[$j - 1]
                $question.SetAttribute("data-passage", "passage$id")
                if ($question.InnerXml -match "gray|highlighted") {
                    $question.InnerXml = $question.InnerXml -replace "gray", "highlight"
                    $passage.InnerXml = $passage.InnerXml -replace "class=`"gray`"", "data-question=`"$j`""
                }
            }
        
        }
    
        #endregion

        #region Passage

        if ($name -match "pd") {
            $text = $nodes[$i].NextSibling
            $content = ""
            while ($text.class -match "Test_samplei" -or $text.InnerXml -match "_\d+_r1.jpg") {
                if ($name -match "pd") { 
                    $jpg = $folder + ($text.InnerXml | Select-String "(?<=src=`").*?(?=`")").Matches.Value
                    $content += (Export-ImageText $jpg) -creplace "`nL.ne |\(\d+\) " -replace "\.`n", ".</p><p>" -replace "`n+", " " -replace "l<", "k"
                }
                else {
                    $content += $text.OuterXml -replace "<p.*?`">", "<p>"
                }
                $text = $text.NextSibling
            }
            $content = if ($name -match "pd") { "<p>$content</p>" } else {$content}
        }
        elseif ($name -match "\-drill") { # Passage enclose by div
            $content = $nodes[$i].InnerXml -replace "<p.*?>", "<p>"
        }

        $passage = Add-XmlNode ("div", @{id = "passage$id"; class = "passage"}, $content) $questionsDiv
        
        #endregion

        if($id -ne 1) {
            $html.InnerXml = $html.InnerXml -replace "</div></main>", "$($passage.OuterXml)</div></main>"
        }
        
        $html.InnerXml = $html.InnerXml -replace " {2,}", " "
        $content = (Format-Html $html.OuterXml).Replace("html[]", "html")

        Set-Content $testHtml $content -Encoding UTF8
        Set-Content $path $content -Encoding UTF8
        $id++
    }

    #endregion
    
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
    Set-Content $testHtml $text

    # add passage start then add question start to first question of each passage
    $text = $text -replace "Questions ", $end + $beginning + "Questions "
    $text = $text -replace "Question ", $end + $beginning + "Question "
    if ($text.Substring($end.length + $beginning.length, 20) -like "*Question*1*") {
        $text = $text.Substring($end.length + $text.IndexOf($end), $text.length - 1 - $end.length - $text.IndexOf($end))
    }
    
    $regex = "<p>Question(s)? (?<question>\d+?) " 
    $oldText = "`"(\u201D)?[(\r\n)| ]`$(`$match.Value.Trim(`"<p>Questions `"))\. `""
    $text = Update-Text $regex $oldText "`"</p></div>`$start`""

    # remove extra text again
    $text = $text -replace "Question(s)? .* passage(\.|:)"
    $text = $text -replace "(\r\n)*Blank \(i*\)"

    # add question 
    $text = $text -replace "(\u0002)?( |\r\n)A ", "</p></div><div class=`"choices`"><p>A " # add choice start
    Set-Content $testHtml $text

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

    Set-Content $testHtml $text

    foreach ($character in "BCDEFGHI".ToCharArray()) {
        $text = $text -replace " $character ", "</p><p>$character "
        if ( $character -eq 'I' ) {
            # remove I word not the I choice, well,</p><p>I -> well, I 
            $regex = "[^\w]</p><p>I " 
            $newText = "`"`$(`$match.Value.Replace('</p><p>', ' '))`""
            $text = Update-Text $regex $oldText $newText
        }
    }
    Set-Content $testHtml $text

    $text = $text -replace "[(\r\n)| ]1\. ", $start # add question start and choice end
    $text = $text -replace "[(\r\n)| ]\d{1,2}\. ", $end + $start # add question start and choice end
    $text = $text -replace "\. +\r\n", "." # remove extra newline
    $text = $text -replace "(\r)?(\n)?" # remove extra newline
    $text = "<div id=`"questions`">$text$end</div>"
    Set-Content $testHtml $text

    Set-Content $path $text.replace(" & ", " and ") -Encoding UTF8
    $xml = [xml] (Get-Content $path)
    $questionsDiv = Select-Xml "//div[@id=`"question`"]" $xml

    # traverse questions
    for ($i = 0; $i -lt $questionsDiv.Count; $i++) {
        $question = $questionsDiv[$i]
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
            $choicesDiv = $question.Node.ChildNodes[1].ChildNodes

            # chonge choice order
            if ($choicesDiv.Count -eq 6) {
                #2 blanks
                Set-Swap ([ref]$choicesDiv[1]) ([ref]$choicesDiv[2]) # A DB ECF -> A BD ECF
                Set-Swap ([ref]$choicesDiv[3]) ([ref]$choicesDiv[4]) # ABD EC F -> ABD CE F
                Set-Swap ([ref]$choicesDiv[2]) ([ref]$choicesDiv[3]) # AB DC EF -> AB CD EF
                $question.Node.InnerXml = $question.Node.InnerXml.Replace("</p><p>D", "</p></div><div class=`"choices`"><p>D")
            }
            else {
                # 3 blanks
                Set-Swap ([ref]$choicesDiv[1]) ([ref]$choicesDiv[3]) # 1(4)7(2)58369 -> 1(2)7(4)58369
                Set-Swap ([ref]$choicesDiv[2]) ([ref]$choicesDiv[6]) # 12(7)458(3)69 -> 12(3)458(7)69
                Set-Swap ([ref]$choicesDiv[5]) ([ref]$choicesDiv[7]) # 12345(8)7(6)9 -> 12345(6)7(8)9
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
    Set-Content $testHtml $xml.OuterXml
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
        $choicesDiv = ( $explanation | Select-String "\d{1,2}\. ([A-F]|\d{1,2})" -AllMatches).Matches
        for ($i = 0; $i -lt $choicesDiv.Count; $i++) {
            $start = $explanation.IndexOf($choicesDiv[$i].Value)

            # answer
            $answer = $choicesDiv[$i].Value[-1]
            
            $string = $explanation.substring($start + $choicesDiv[$i].Value.Length, 4)
            if ($string -eq " and") {
                $answer += $explanation.substring($start + $choicesDiv[$i].Value.Length + 5, 1)
            }
            elseif ($string -eq ", ") {
                $answer += $explanation.substring($start + $choicesDiv[$i].Value.Length + 2, 1)
                $answer += $explanation.substring($start + $choicesDiv[$i].Value.Length + 9, 1)
            }
            $answers[$i].Node.SetAttribute("data-answer", $answer)

            # explanation 
            $end = if ($i -eq $choicesDiv.Count - 1) {$explanation.Length - 1} else {$explanation.IndexOf($choicesDiv[$i + 1].Value)}
            
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
    $wordApp = ""
    $regex = "(a(n)? )?\w{3,}( $prepositions)?"
    ConvertFrom-Epub $path
}
