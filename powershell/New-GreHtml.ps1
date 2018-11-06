. $PSScriptRoot\Utility.ps1
$wordApp = $null
$set = "be"
$name = "$set-dt-verbal" 
$type = "txt"
$ebooks = "C:\github\temp\ebooks"
$testHtml = "C:\github\temp\files\html\test.html"
$path = "C:\github\gre\$set\$name.$type"
$prepositions = "\b(about|across|after|against|along|and|around|at|between|by|down|for|from|in|into|of|off|on|onto|over|through|to|toward|under|up|with)\b"

$passageRegex = "`"(no)?indentr?1?(-float)?`"|hang(3|-nums)|block_(rc|9[23])|-stimulus|nums-|Test_samplei" #_\d+_r1.jpg|
$letterRegex = "\b[A-I]+\b"
$optionRegex = "(an? )?\w{4,}(-\w{4,})?( $prepositions)?"

function Get-RegExMatch ($string, $regex) {
    if (!$regex) { return }
    ( $string | Select-String $regex -AllMatches -CaseSensitive).Matches.Value
}

function Get-ImageText ($path, [ref]$wordApp, $scale = 100) {
    <#
    $length = 3
    $options = @()
    for ($i = 0; $i -lt $length; $i++) {
        $width = $img.Width * $scale / 100 / $length
        $height = $img.Height * $scale / 100
        $rect = New-Object System.Drawing.Rectangle ($width * $i),0,$width,$height
        $content = Export-ImageText $path.Replace("_r1","") $rect
        $content = $content -replace "^.*?\n" -replace "\n+", "`n"
        $words = ($content | Select-String $regex -AllMatches).Matches
        if ($words.Length -gt 3) {
            for ($j = 0; $j -lt $words.Count; $j+=2) {
                $options += $words[$j] + " " + $words[$j+1]
            }
        }
        else {  $words.ForEach{ $options += $_ } }
    }
    #>
    Import-Module "PSImaging"
    if (!$wordApp.Value) {
        $word = Get-Process "winword" -ErrorAction SilentlyContinue
        if ($word) { Stop-Process $word }
        $wordApp.Value = New-Object -ComObject Word.Application 
        $wordApp.Value.Documents.Add() | Out-Null
    }

    $extension = Get-RegExMatch $path "\.(\w+)$"

    if ($extension -ne ".jpg") {
        #Load required assemblies and get object reference 
        $i = New-Object System.Drawing.Bitmap($path)
        $path = $path -replace "\.(\w+)$", ".jpg"

        #Save with the image in the desired format 
        While(!(Test-Path $path)) {
            $i.Save($path.Replace(""),"jpeg")
        } 
    }

    if ($scale -ne 100) { 
        $newPath = $path.Replace(".jpg","_$scale.jpg")
        Resize-Image $path $newPath -Scale $scale 
        $content = Export-ImageText $newPath
        Remove-Item $newPath
    }
    else {
        $content = Export-ImageText $path
    }

    $content -replace "(\w)\|(\w)", "`$1l`$2"
}

function Get-Logic ($expression) {
    if ($expression) { Invoke-Expression $expression }
}

function ConvertFrom-Epub {
    
    function Get-EpubXml {
        for ($i = $start; $i -lt $end; $i++) {
            $content += Get-Content $files[$i] -Encoding UTF8
        }
        $content = $content -replace "xmlns.*?=`".*?`"|<\?.*?\?>|epub:"
        $content = Format-Html "<c>$content</c>"
        $content = $content -replace "<a i.*?/>|<(div|hr|br)\w* .*?/>|</?c>"
        $content
    }
    
    function Get-Xml ($oldText, $newText) {

        for ($i = 0; $i -lt $ranges.Count; $i+=2) {
            $start = $ranges[$i]; $end = $ranges[$i+1]
            $content = Get-EpubXml
        }
        if ($oldText) { $content = $content -replace $oldText, "________" }

        Set-Content "C:\github\temp\files\html\ebook.html" $content -Encoding UTF8
        Set-Content $testHtml $content -Encoding UTF8
        [xml]("<b>$content</b>")
    }

    function Set-Questions {

        function Format-Content ($content) {
            $content = Format-Html "<c>$content</c>"
            $content = $content -replace "<a.*?/a>|<[dsai]\w+ .*?/>|(((?<=<[pc]>)|^)\s*(\d+.?|\([A-F]\)))?\u00A0?"
            $content = $content -replace "<(\w+).*?>", "<`$1>" -replace "<(div|section)>((`r`n.*?)*)</\1>", "`$2"
            while($content -match "<(.*?)>(`r`n *)*</\1>") { $content = $content -replace "<(.*?)>(`r`n *)*</\1>"}
            $content = Format-Html "<c>$content</c>"
            $content -replace "</?c>" -replace " {2,}", " " -replace "^\s+|\s+$"
        }
    
        function Test-Passage ($passage, $src) {
            ($passage.OuterXml -match "$passageRegex|num-list" -or (Test-Logic $passage)) -and 
            (Format-Content $passage.InnerXml) -and 
            (Format-Content $content).Contains((Format-Content $passage.InnerXml)) -or 
            (Format-Content $passage.InnerXml).Contains((Format-Content $content)) -or 
            ($src -and $passage.InnerXml.Contains($src))
            
        }
    
        function Test-Logic ($passage) {
            $passage.NextSibling.Class -match "textb.?|para$" -or $passage.Class -eq "noindent" -or ($passage.OuterXml -match "-stimulus" -and $passage.OuterXml -cnotmatch "Passage ") -or (Get-Logic ($logicRegex -replace '\$_', '$passage'))
        }
    
        function Test-Choice {
            $choice.OuterXml -match "\btable\b|\balpha\b|list-h[s1]?|nss|src=`".*?`"|-answers`"|squf"
        }
    
        function Test-Question {
            ($question.InnerXml -match "apply\." -and $name -notmatch "pr-dr|mp-ps") -or ($name -match "pr-ps|og|mp-pp" -and (Test-Logic $question))
        }
    
        function Test-Option {
            $wordApp.CheckSpelling($option) -and !($wordApp.GetSpellingSuggestions($option) | Select-Object) -or $option -match "imbibement"
        }
    
        function Test-Image {
            if ((Select-Xml ".//img" $question).Node.src) { (Select-Xml ".//img" $question).Node.src }
            elseif ((Select-Xml ".//img" $choice).Node.src) { (Select-Xml ".//img" $choice).Node.src }
        }
    
        function Get-QuestionText {
            if ($question.Class -match "ktp") {
                $content = if (Test-Logic $question) {
                    $question.ChildNodes[1].InnerText
                }
                else {
                    $question.ChildNodes[0].InnerText
                }
            }
            else {
                $content = $question.InnerText -replace "^\d+\.? ?|\u00A0"
            }
            $content
        }
    
        if (Test-Path $path) { 
            $html = [xml](Get-Content $path)
            $questionsDiv = (Select-Xml "//div[@id='questions']" $html).Node
        }
        else {
            $html = [xml](Get-Content "C:\github\temp\files\html\temp.html")
            $questionsDiv = Add-XmlNode ("div", @{id = "questions"}) (Select-Xml "//main" $html).Node
        }
    
        for ($i = $range[0] - 1; $i -le $range[1] - 1; $i++) {
    
            #region Questions Div
            $question = $questions[$i]
            if (Test-Question) { $question = $question.NextSibling }
    
            Write-Host $i
    
            $content = Get-QuestionText
            $blank = (Get-RegExMatch $content "_{2,}").Count
    
            if ($question.InnerXml -match " sentence " -and !$blank -and 
            $question.InnerXml -notmatch " highlighted ") { $type = "select" }
            else {$type = "radio"}
              
            
            if ((Select-Xml "//div[contains(@id,'question')]" $questionsDiv)) {
                $id = (Select-Xml "//div[contains(@id,'question')]" $questionsDiv).Node.Count
                if (!$id) { $id = 1}
            }
            
            #Write-Host "Question $id"
            
            $questionDiv = Add-XmlNode ("div", @{id = "question$id"; "data-choice-type" = $type}) $questionsDiv
            Add-XmlNode ("div", @{class = "question"}, "<p>$content</p>") $questionDiv | Out-Null
    
            #endregion
    
            #region Choices
            if ($type -ne "select") {
                if ($question.Class -match "ktp") {
                    $choice = if ((Test-Logic $question) -and $name -notmatch "kap") {
                        $question.ChildNodes[2]
                    }
                    else {
                        $question.ChildNodes[1]
                    }
                }
                else {
                    $choice = $question
                    while ( !(Test-Choice) ) { $choice = $choice.NextSibling }
                }
                $count = (Get-RegExMatch (Get-Content "C:\github\temp\files\html\ebook.html") (Test-Image)).Count

                if ($choice.OuterXml -match "multicol|multiple-" -or (Select-Xml ".//img | li" $choice).Count -gt 1) { 
                    $choice = if($choice.OuterXml -match "multicol") { 
                        if ($choice.OuterXml -match "table>") {
                            (Select-Xml ".//td" $choice).Node.InnerXml -join ""
                        }
                        else { $choice.InnerXml }
                    }
                    else { $choice.OuterXml }
                    $choice = (Format-Content $choice) -replace "li>", "p>" -replace "[ou]l>", 'div>'
                    $choice = $choice -replace "<p>Blank \(i\)</p>" -replace "<p>Blank.*?</p>", '</div><div class="choices">'
                    if ($choice -notmatch "<div>") { $choice = "<div class=`"choices`">$choice</div>"}
                    $questionDiv.InnerXml += $choice -replace "<div>", '<div class="choices">'
                }
                elseif ($choice.OuterXml -match "table>" -or ($count -lt 9 -and $count -gt 0) ) {
                    if ($choice.OuterXml -match "table>") {
                        $options = (Select-Xml ".//td" $choice).Node.InnerText.Where{$_ -notmatch "blank " -and $_ -match "\w+"}
                    } 
                    #region Convert image to Choice
                    elseif (Test-Path ("$ebooks\$ebook\$(Test-Image)" -replace "\.(jpg|gif)", ".txt")) {
                        $options = Get-Content ("$ebooks\$ebook\$(Test-Image)" -replace "\.(jpg|gif)", ".txt")
                    } 
                    else {#elseif ((Select-Xml "img" $question).Count -eq 1) { 
                        $words = (Select-Xml ".//em" $explanations[$i]).Node.InnerText -replace "\W"
                        $scale = 4; $step = 5
                        $length = if ($blank -eq 3) { 9 } elseif ($blank -eq 2){ 6 } else {5}
    
                        $choices = @()
                        for ($j = 0; $j -lt $length; $j++) { $choices += "" }
    
                        #region Get options
                        do {
                            if ($scale * $step -gt 400) { 
                                
                                Write-Host "$ebooks\$ebook\$(Test-Image)"
                                Set-Content ("$ebooks\$ebook\$(Test-Image)" -replace "\.(jpg|gif)", ".txt") $choices
                                $choices.ForEach{
                                    $option = $_
                                    Write-Host $option (Test-Option)
                                }
                                exit
                                
                            } 
                            
                            # get option text
                            $content = Get-ImageText "$ebooks\$ebook\$(Test-Image)" ([ref]$wordApp) ($scale*$step)
                            if ($content.Count -gt 1) { $content = $content[1] }
                            $content = if ($content -match "i{2,3}") { $content -replace "^.*?\n"} else {$content}
                            $options = Get-RegExMatch $content $optionRegex
                            $options = $options.Where{$_ -match "\w+" -and $_ -notmatch "Blank|i{2,3}"}
                            
                            # set chioce text
                            for ($j = 0; $j -lt $options.Count -and $options.Count -eq $length; $j++) {
                                $option = $options[$j].ToString().ToLower()
                                $matchFlag = (Get-RegExMatch $option "[\W\d]").Where{ $_ -notmatch "[ -]"}.Count -eq 0
                                if ($option -in $words -or ((Test-Option) -and $choices[$j] -ne $options -and $matchFlag -and $option -notin $choices) -or 
                                $explanation -match ($option -replace "\s+$prepositions|^an? ")) {
    
                                    if ($option -eq "accolades") { $option = "approbation"}
                                    if ($option -eq "epitome") { $option = "esoteric"}
                                    $choices[$j] = $option
                                }
                            }
                            $flag = [int]$choices.Where{$_ -eq ""}.Count -ne 0 -or 
                            [int]$answers.Where{($choices -join "") -notmatch $_}.Where{$_ -cnotmatch "[A-I]"}.Count -ne 0 
                            if ($options.Count -gt 15) { 
                                $flag = $false; $choices = @("") }
                        } while ( $choices.Length -eq 0 -or $flag -and $scale++)
    
                        $options = $choices
                        Set-Content ("$ebooks\$ebook\$(Test-Image)" -replace "\.(jpg|gif)", ".txt") $choices
                        #endregion
                    }
                    #endregion
    
                    #region Rearrange Choice
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
                    #endregion
                }
                elseif (Test-Choice) { # Choice are parallel
                    $choicesDiv = Add-XmlNode ("div", @{class = "choices"}) $questionDiv
                    while (Test-Choice) {
                        Add-XmlNode ("p", ($choice.InnerText -replace "\u00A0")) $choicesDiv | Out-Null
                        $choice = $choice.NextSibling
                    }
                }
            }
            #endregion
            
            #region Answer
            
            $content = (Select-Xml $answerRegex $explanations[$i]).Node.InnerText -replace "Choice|\d"
            $content = $content -replace "1st","A" -replace "2nd","B" -replace "3rd","C" -creplace "\b(and|only|CORRECT)\b"
            if ($type -eq "select") {
                if ($name -match "pp") { 
                    $content = Get-RegExMatch $explanation "(?<=\u201C).*?(?=\u201D)"
                }
                elseif ($name -match "kap") {
                    $content = (Select-Xml ".//b" $explanations[$i]).Node.InnerText
                }
                $answers = $content -replace "^\d+\.?|\s{2,}|\.\.\.|\u2026 "
            }
            else {
                if ($explanations[$i].OuterXml -match "<ol" -and $name -notmatch "kap") {
                    $answers = ""
                    $keys = (Select-Xml ".//li" $explanations[$i]).Node.InnerText
                    for ($j = 0; $j -lt $keys.Count; $j++) {
                        if ($keys[$j] -match "CORRECT") {
                            $answers += "$([char]($j+65))"
                        }
                    }
                }
                else {
                    $keys = if ($content -cmatch $letterRegex -and $name -notmatch "mp-pp") { Get-RegExMatch $content $letterRegex}
                    else {Get-RegExMatch $content "\w+(\s+\w+)*"}
                    $answers = @()
                    $keys.ForEach{ if ($_ -notin $answers) { $answers += , $_ } }
                }
            }
    
            for ($j = 0; $j -lt $answers.Count -and $type -ne "select"; $j++) {
                $key = if ($answers.Count -eq 1) {$answers} else {$answers[$j]}
                $key = if ($answers.Length -gt 3) { $key.ToLower() } else { $key }
                if($key -cnotmatch $letterRegex -or $name -match "mp-pp") {
                    $options = (Select-Xml "div[@class='choices']/p" $questionDiv).Node.InnerText
                    $key = "$([char]($options.IndexOf( $options.Where{ $_ -match $key }[0] ) + 65))"
                    if ($answers.Count -eq 1) {$answers = $key} else {$answers[$j] = $key}
                }
            }
            
            if ((Select-Xml "div[@class='choices']/p" $questionDiv).Count -eq 3 -or # Reading Comprehension
            ($blank -eq 1 -and $answers.Count -eq 2)) { # Sentence Equivalence
                $questionDiv.SetAttribute("data-choice-type", "checkbox") 
            }
    
            #endregion
    
            #region Explanation
            $explanation = $explanations[$i]
            $content = ""
            if ($explanation.OuterXml -match "feedback") {
                $content = if ($explanation.ChildNodes[0].ChildNodes[0].Name -eq "ol") {
                    $explanation.InnerXml.Replace($explanation.ChildNodes[0].ChildNodes[0].OuterXml, "")
                }
                elseif ($explanation.OuterXml -match "ktp-answer-correct" -or $name -match "kap") {
                    $explanation.InnerXml
                }
                else {
                    $explanation.ChildNodes[0].ChildNodes[0].OuterXml
                }
            }
            else {
                do {
                    $content += $explanation.OuterXml
                    $explanation = $explanation.NextSibling
                } while ($explanation -and $explanation.OuterXml -notmatch "<a.*href|\d+\.|subhead|aside")
            }
            $explanation = (Format-Content $content) -replace ">\s*(\r\n)*\s*\.", ">"
            $explanation = Add-XmlNode ("div", @{class = "explanation"; "data-answer" = ($answers -join "")}, $explanation) $questionDiv
          
            #endregion
       
            #region Passage
            for ($j = 0; $j -lt $passages.Count -and $content -notmatch "__"; $j++) {
    
                #region Text
                $content = ""
                if ($passages[$j].Class -match "ktp" -or (Test-Logic $passages[$j])) {
                    $content = $passages[$j].InnerXml
                    <#
                    if (Test-Logic $passages[$j]) { 
                        $passages[$j].InnerXml }
                    else { 
                        $passages[$j].ChildNodes[1].InnerXml }#>
                }
                else {
                    $passage = $passages[$j].NextSibling
                    while ($passage.OuterXml -match $passageRegex) {
                        if ($name -match "pd") { 
                            $folder = "$ebooks\$ebook\"
                            $jpg = $folder + (Select-Xml ".//img" $passage).Node.src
                            
                            if (!(Test-Path "$ebooks\$ebook\passage$j.html" )) {
                                $content += (Export-ImageText $jpg) 
                                $content = $content -creplace "`nL.ne |\(\d+\) " -replace "(`n.{1,40})\.`n", "`$1.</p><p>" -replace "`n+", " " 
                                $content = $content.Replace("l<", "k").Replace("|","l")
                            }
                        }
                        else {
                            $content += $passage.OuterXml 
                        }
                        $passage = $passage.NextSibling
                    }   
                    if ($name -match "mp-ps" -and (Test-Logic $passage)) { 
                        $content = $passage.PreviousSibling.OuterXml -replace "(?<=>)\d+\."
                    } 
                }
                if (Test-Path "$ebooks\$ebook\passage$j.html") {
                    $content = Get-Content "$ebooks\$ebook\passage$j.html"
                    Set-Content "$ebooks\$ebook\$name-passage$j.html" $content
                }
                else {
                    $content = $content -replace "</p><p.*?(nums-[2-4]|hang3|-float).>\d*\s{1,}\d*", " "

                    if (((Test-Logic $passages[$j]) -and $name -notmatch "mp-ps") -or 
                    ($name -match "pr-pd" -and !(Test-Path "$ebooks\$ebook\$name-passage$j.html"))) { 
                        $content = "<p>$content</p>" }
    
                    $content = Format-Content $content
                    if ($name -match "pr-pd") { Set-Content "$ebooks\$ebook\$name-passage$j.html" $content}
                    
                    if ($question.InnerXml -match "gray`"|highlighted") { 
                        $content = $content -replace "<span>", "<span data-question=`"question$id`">"
                    }
                }
               
                #endregion
                
                #region Range
                if ($jpg) { $src = $jpg.Replace($folder, "") }
                
                $passage = $question 
                #if ($name -match "pd") {$question.ParentNode.PreviousSibling} 
                #elseif (Test-Logic $question) { $question}
                #else {$question.PreviousSibling}
    
                while (($passage.OuterXml -cnotmatch $passageRegex -or $passage.OuterXml -cmatch "annotation") -and !(Test-Logic $passage)) { #!(Test-Logic $question)) {
                    while(!$passage.PreviousSibling) { $passage = $passage.ParentNode }
                    $passage = $passage.PreviousSibling
                }
                
                if (Test-Passage $passage $src) {
                    if ($temp -ne $j) { $passageNum++ }
                    Write-Host "Passage $passageNum"
                    $questionDiv.SetAttribute("data-passage", "passage$passageNum")
                    $passage = (Select-Xml "//div" $html).Node.Where{$_.id -eq "passage$passageNum"}[0]
                    if(!$passage) {
                        $passage = Add-XmlNode ("div", @{id = "passage$passageNum"; class = "passage"}, $content) $questionsDiv
                    }
                    else {
                        if($question.InnerXml -match "gray`"|highlighted") {
                            $passage.InnerXml = $content
                        }
                    }
                    $temp = $j
                    break
                }
                
                #endregion
            }
            #endregion
    
        }
        
        $content = (Format-Html $html.OuterXml).Replace("html[]", "html")
        Set-Content $testHtml $content -Encoding UTF8
        Set-Content $path $content -Encoding UTF8
        $passageNum
    }
    
    if ($name -match "kap-ps") {
        $ebook = "GRE Prep 2018\OPS\text"
        $files = Get-ChildItem "$ebooks\$ebook\*chapter*_output*"
        $ranges = 0, 12
        
        $xml = Get-Xml "<span class=`"blank-s`".*?/>"

        $explanations = (Select-Xml "//li" $xml).Node.Where{$_.OuterXml -match "value=" -and $_.OuterXml -match "feedback"}
        $questions = (Select-Xml "//li" $xml).Node.Where{$_.OuterXml -match "value=" -and $_.class -match "question" -and $_ -notin $explanations -and $_.InnerXml -notmatch "Global</li"}
        $passages = (Select-Xml "//li" $xml).Node.Where{$_.class -match "-stimulus"}

        $answerRegex = "b"

        $sets = (
            ((1,16)),
            ((17,41))
        )
    
    }
    elseif ($name -match "pr-ps") {
        $ebook = "Cracking the GRE Premium 2018\OEBPS"
        $files = Get-ChildItem "$ebooks\$ebook\Prin_9780451487667_epub3_*"
        $ranges = 10, 14, 36, 37

        $xml = Get-Xml
        
        $answerRegex = ".//strong"
        $logicRegex = '($_.class -match "Test_sample1l" -and $_.InnerXml -notmatch "apply." -and $_.PreviousSibling.class -match "Test_sample2l" -and $_.NextSibling.class -match "Test_sample1l")'

        $questions = (Select-Xml "//a" $xml).Node.Where{$_.href -match "(c04-q00|c0[56]-q|c07-q000).*a$"}.ParentNode.NextSibling
        $explanations = (Select-Xml "//a" $xml).Node.Where{$_.id -match"(c04-q00|c0[56]-q|c07-q000).*a$"}.ParentNode.ParentNode
        $passages = (Select-Xml "//p" $xml).Node.Where{$_.class -match "Test_samplen" -or (Get-Logic $logicRegex)}
        
        $sets = ( 
            ((1,3),(7,9),(13,14),(17,21),(27,32),(37,38)), #
            ((4,6),(10,12),(15,16),(22,26),(33,36),(39,41)) #
        )
    } 
    elseif ($name -match "pr-dr") {
        $ranges = 2, 27
        $ebook = "1,014 GRE Practice Questions 3\OEBPS"
        $files = Get-ChildItem "$ebooks\$ebook\Revi_9780307945396_epub_c02_s*"
        $xml = Get-Xml

        $questions = (Select-Xml "//a" $xml).Node.Where{$_.href -match "#QST\d+a$"}.ParentNode.NextSibling
        $explanations = (Select-Xml "//a" $xml).Node.Where{$_.href -match "#QST\d+$" -and $_.ParentNode.OuterXml -match "<strong>"}.ParentNode.ParentNode
        $passages = (Select-Xml "//div" $xml).Node.Where{$_.class -match 'block_rc'}.PreviousSibling

        $answerRegex = ".//strong"

        $sets = (
            ((1,7),(106,113),(197,206)),
            ((8,14),(114,120),(207,216)),
            ((15,22),(121,126),(217,226)),
            ((23,30),(127,132),(227,236)),
            ((31,37),(133,138),(237,246)),
            ((38,44),(139,145),(247,256)),
            ((45,52),(146,151),(257,266)),
            ((53,60),(152,157),(267,276)),
            ((61,67),(158,164),(277,286)),
            ((68,75),(165,170),(287,296)),
            ((76,82),(171,177),(297,306)),
            ((83,90),(178,182),(307,316)),
            ((91,98),(183,188),(317,326)),
            ((99,105),(189,196),(327,336))
        )
    }
    elseif ($name -match "pr-pd") { 
        $ranges = 2, 5
        $ebook = "Verbal Workout for the GRE 6\OEBPS"
        $files = Get-ChildItem "$ebooks\$ebook\Prin_9781524710323_epub3_c0*"
        $content = Get-EpubXml

        $xml = Get-Xml

        $questions = (Select-Xml "//a" $xml).Node.Where{$_.href -match "c0([45]\-ans|3\-drl)\d+a$"}.ParentNode.ParentNode
        $explanations = (Select-Xml "//a" $xml).Node.Where{$_.id -match "c0([45]\-ans|3\-drl)\d+a$"}.ParentNode.ParentNode
        $passages = (Select-Xml "//div" $xml).Node.Where{$_.class -match "dis_img2"}.PreviousSibling

        $answerRegex = ".//strong"

        $sets = (
            ((1,7),(35,47),(91,100)),
            ((8,13),(48,57),(101,110)),
            ((14,20),(58,71),(111,119)),
            ((21,27),(72,81),(120,129)),
            ((28,34),(82,90),(130,139))
        )
    }
    elseif ($name -match "og-dq") {

        $ranges = 3, 4
        $ebook = "The Official Guide to the GRE General Test 3\EPUB\xhtml"
        $files = Get-ChildItem "$ebooks\$ebook\chapter*"
 
        $xml = Get-Xml "<img.*?blank.*?/>"

        $xml = (Select-Xml "//section" $xml).Node.Where{$_.class -eq "division1"}

        $questions = (Select-Xml ".//p" $xml).Node.Where{$_.class -eq "question"}
        $explanations = (Select-Xml ".//aside" $xml).Node.Where{$_.class -match "Sidebar1" -and $_.InnerXml -match "Explanation"}
        $passages = (Select-Xml ".//h3 | .//h4 | .//p" $xml).Node.Where{($_.class -match "lefthd2" -or $_.NextSibling.class -match "para") }
        
        $answerRegex = ".//b"

        $sets = (
            ((1,17)),
            ((18,34)),
            ((35,51))
        )
    }
    elseif ($name -match "mh-es") {
        $ranges = 10, 13
        $ebook = "McGraw-Hill Education GRE 2019\OEBPS"
        $files = Get-ChildItem "$ebooks\$ebook\ch*"

        $xml = Get-Xml
        
        $answerRegex = ".//strong"

        $questions = (Select-Xml "//a" $xml).Node.Where{$_.href -match "_ch.ans"}.ParentNode
        $explanations = (Select-Xml "//a" $xml).Node.Where{$_.id -match "_ch.ans"}.ParentNode.ParentNode
        $passages = (Select-Xml "//p" $xml).Node.Where{$_.class -match "noindenttb" -and $_.InnerXml -cmatch "Question"}
        $sets = (
            ((1,10),(31,40),(62,63),(71,72),(76,76)),
            ((11,20),(41,50),(64,66),(73,74)),
            ((21,30),(51,61),(67,70),(75,75))
        )
    }
    elseif ($name -match "mp-ps") {
        $ebook = "GRE Verbal Strategies\OPS\text"
        $files = Get-ChildItem "$ebooks\$ebook\*chapter??_output*"
        $ranges = 9, 13, 17, 23, 27, 33
       
        $xml = Get-Xml

        $explanations = (Select-Xml "//li" $xml).Node.Where{$_.OuterXml -match "value=" -and $_.OuterXml -match "feedback"}
        $questions = (Select-Xml "//li" $xml).Node.Where{$_.OuterXml -match "value=" -and $_.class -match "question" -and $_ -notin $explanations}
        $passages = (Select-Xml "//li | //section" $xml).Node.Where{$_.class -match "-stimulus"}

        $answerRegex = ".//b[1]"

        $sets = (
            ((1,7),(47,47),(57,66),(117,126)),
            ((8,12),(40,46),(48,48),(67,76),(127,136)),
            ((13,19),(49,50),(77,86),(137,146)),
            ((20,25),(51,52),(87,96),(147,156)),
            ((26,32),(53,54),(97,106),(157,166)),
            ((33,39),(55,56),(107,116),(167,176))
        )
    
    
    }
    elseif ($name -match "mp-pp") {
        $ebook = "5 lb  Book of GRE Practice Problems 2\OEBPS"
        $files = Get-ChildItem "$ebooks\$ebook\*chapter??*"
        $ranges = 6, 20

        $xml = Get-Xml 

        $explanations = (Select-Xml "//p" $xml).Node.Where{$_.class -match "body-text" -and $_.InnerXml -match "^\d"}
        $questions = (Select-Xml "//p" $xml).Node.Where{$_.class -match "num-list"}
        $passages = (Select-Xml "//div | //p" $xml).Node.Where{($_.class -match "box$" -and $_.InnerXml -match "Question") -or $_.NextSibling.class -match "-textb"}

        $answerRegex = ".//b[1]"

        $sets = (
            ((1,6),(145,150),(292,298),(463,464)),
            ((7,12),(151,156),(299,305),(465,466)),
            ((13,18),(157,162),(306,313),(467,468)),
            ((19,24),(163,168),(314,318),(469,471)),
            ((25,30),(169,174),(319,328),(472,473)),
            ((31,36),(175,180),(329,336),(474,475)),
            ((37,42),(181,186),(337,342),(476,478)),
            ((43,48),(187,192),(343,347),(479,481)),
            ((49,54),(193,198),(348,355),(482,483)),
            ((55,60),(199,204),(356,361),(484,486)),
            ((61,66),(205,210),(362,367),(487,489)),
            ((67,72),(211,216),(368,375),(490,491)),
            ((73,78),(217,222),(376,381),(492,494)),
            ((79,84),(223,228),(382,389),(495,496)),
            ((85,90),(229,234),(390,394),(497,499)),
            ((91,96),(235,240),(395,403),(500,501)),
            ((97,102),(241,246),(404,409),(502,504)),
            ((103,108),(247,252),(410,417),(505,506)),
            ((109,114),(253,258),(418,423),(507,509)),
            ((115,120),(259,264),(424,430),(510,511)),
            ((121,126),(265,270),(431,437),(512,513)),
            ((127,132),(271,276),(438,444),(514,515)),
            ((133,138),(277,282),(445,453),(516,517)),
            ((139,144),(283,291),(454,461),(518,519))

        )
    }
    
    for ($i = 1; $i -le $sets.Count; $i++) {
        $ranges = $sets[$i-1]
        $path = $path -replace "\d*\-verbal", "$i-verbal"
        if (Test-Path $path) { Remove-Item $path }
        $passageNum = 0
        for ($j = 0; $j -lt $ranges.Count; $j++) {
            $range = if ($ranges[$j].GetType().Name -match "Object") { $ranges[$j] }
            else { $ranges }
            $passageNum = Set-Questions
            if ($ranges[$j].GetType().Name -match "Int") { break }
        }
    }
    
    #Set-Content $testHtml $passages.OuterXml -Encoding UTF8 
}

function ConvertFrom-Text {

    function Set-Swap ([ref]$value1, [ref]$value2) {
        $temp = $value1.Value.InnerText
        $value1.Value.InnerText = $value2.Value.InnerText
        $value2.Value.InnerText = $temp
    }

    function Update-Text($regex, $oldText, $newText) {
        foreach ($match in (Get-RegExMatch $content $regex)) {
            $content = $content -replace (Invoke-Expression $oldText), (Invoke-Expression $newText)
        }
        $content
    }

    $beginning = "<div class=`"passage`"><p>"
    $end = "</p></div><div class=`"explanation`"><p></p></div></div>"
    $start = "<div id=`"question`" data-choice-type=`"`"><div class=`"question`"><p>"
    
    #region Remove Extra Text

    # replace character
    $content = $content -replace " (\u00e2\u20ac\u201d)+ ", " _______ " # Grubers
    $content = $content -replace "\u00e2\u20ac\u0153", [char]0x201C
    $content = $content -replace "\u00e2\u20ac\u009d", [char]0x201D
    $content = $content -replace "\u00e2\u20ac\u2122", [char]0x2019
    $content = $content -replace "\u00e2\u20ac\u00a6", [char]0x2026
    $content = $content -replace "\u00e2\u20ac\u201d", [char]0x2014
    $content = $content -replace " & ", " and "

    # remove extra text
    $content = $content -replace "(\r\n)*Blank (\(i*\)|[123])"
    $content = $content -replace "\(\d+\) |(?<=\r\n)(\d{0,1}[05]|\s*)(?!\.)"
    $content = $content -replace "-\s*\r\n|\s+(?=\r\n)|(?<=\r\n)line "
    $content = $content -replace "(?<!Question.*\r\n)(?<=\r\n). ", "(A) "
    
    $words = "[A-Za-z]+(\s[A-Za-z]+)"
    do {
        $content = $content -replace "($words{4,})\r\n($words{0,2})", "`$1 `$3"
    } while ($content -match "($words{4,})\r\n($words{0,2})")

    $content = $content -replace "(?<=\r\n)($words{0,2})(?=\r\n)", "(A) `$1"
    if ($name -match "gr") { $content = $content -creplace "\r\n(?=[a-z])", " " }
    $content = $content -creplace "(?<!Question.*)\r\n(?!(\(A|\d|Question))", " "
    Set-Content $testHtml $content -Encoding UTF8
    #endregion
    
    #region Replace Text
    $subsitutions = if ($name -match "gr") { "`$1" }
    $content = $content -creplace "(?<=\r\n\d+.+[\.?:\)\w])\s+(\(?A\)? )", "</p></div><div class=`"choices`"><p> " # add choice start
    if ($name -match "gr") {
        $content = $content -creplace "(?<=\r\n)([A-Z])", "$end$beginning$subsitutions" # add passage start 
    }
    else {
        $content = $content -creplace "Question.*\r\n", "$end$beginning$subsitutions" # add passage start 
    }
    $content = $content -creplace "(?<=\r\n)\(?([A-I])\)? ", "</p><p>$subsitutions " # add choice 
    $content = $content -replace "(?<=\r\n)1\. ", $start # add question start and choice end
    $content = $content -replace "(?<=\r\n)\d{1,2}\. ", ($end + $start) # add question start and choice end
    $content = $content -replace "<p></p>|\r\n"
    $content = $content -replace "(class=`"passage`">.*?(\r\n)?</p></div>).*?</div></div>", "`$1" # remove extra explanation
    $content = "<div id=`"questions`">$content$end</div>"
    
    Set-Content $testHtml $content -Encoding UTF8
    Set-Content $path $content -Encoding UTF8
    $html = [xml] (Get-Content $path)
    $questions = Select-Xml "//div[@id=`"question`"]" $html
    #endregion

    # traverse questions
    for ($i = 0; $i -lt $questions.Count; $i++) {
        $question = $questions[$i].Node
        $question.SetAttribute("id", "question$($i+1)") # add question id
        $questionText = $question.ChildNodes[0].InnerText
        
        #region Choice
        $choices = $question.ChildNodes[1].ChildNodes

        $options = @()
        for ($j = 0; $j -lt $choices.Count; $j++) {
            $options += , ("($([char](65+$j))) " + $choices[$j].InnerText)
        }

        $options.ForEach{
            $index = [int][char](Get-RegExMatch $_ "(?<=\()[A-I]\b") - 65
            $choices[$index].InnerText = $_
        }

        if ((Get-RegExMatch $questionText "_{2,}").Count -gt 1) {
            $question.SetAttribute("data-choice-type", "radio")
            $question.InnerXml = $question.InnerXml -replace "</p>(<p>\(?D\)?)", "</p></div><div class=`"choices`">`$1"
            $question.InnerXml = $question.InnerXml -replace "</p>(<p>\(?G\)?)", "</p></div><div class=`"choices`">`$1"
        }
        elseif ($choices.Count -eq 5) { $question.SetAttribute("data-choice-type", "radio") }
        elseif ($choices.Count -eq 6 -or $choices.Count -eq 3) { $question.SetAttribute("data-choice-type", "checkbox") }
        else { $question.SetAttribute("data-choice-type", "select") }
        #endregion

        #region Explanations
        $content = $explanation
        if ($name -match "gr") {
            $explanations = Get-RegExMatch $content "(?<=\r\n\d{1,2}\.? )[A-I](, [A-I])?"
            $answer = $explanations[$i] -replace ", "
            (Select-Xml "div[@class=`"explanation`"]" $question).Node.SetAttribute("data-answer", $answer)
        }
        elseif ($name -match "be") {
            $content = $content -creplace "\r\n(?!\d+\.)"
            $explanations = $content -split "\r\n" 
            $content = $explanations[$i]
            $content = $content -replace "-\s*"
            $answer = (Get-RegExMatch $content "(?<=\()[A-I](?=\))") -join ""
            $node = (Select-Xml "div[@class=`"explanation`"]" $question).Node
            $node.SetAttribute("data-answer", $answer)
            $node.InnerXml = "<p>$content</p>"
        }
        #endregion

        #region Passage
        Set-Content $testHtml $html.OuterXml -Encoding UTF8
        if ( $questionText -match "_") { continue }
        $passages = Select-Xml "//div[@class=`"passage`"]" $html
        if($passages.Count -eq 1) {$passages = @($passages)}
        $node = $question
        do {
            $node = $node.PreviousSibling
        } until ( $node.class -eq "passage")
        $index = if($passages.Count -gt 1) { $passages.Node.IndexOf($node) } else { 0 }
        $passages[$index].Node.SetAttribute("id", "passage$($index+1)") # add question id
        $question.SetAttribute("data-passage", "passage$($index+1)")
        #endregion

    }

    $html = "<!DOCTYPE html><html lang=`"en`"><head><title></title><script src=`"/index.js`"></script></head><body><main class=`"w3-container`">" + $html.OuterXml + "</main></body></html>"
    $html = $html -replace "\n(\s*\n)*(?=</p>)"
    $html = Format-Html $html
    $html = $html -replace "\[\]"

    Set-Content $path $html -Encoding UTF8
}

if ($type -eq "txt") {
    $extraRegex = "PRACTICE ?SET|STRATEGY|GRE2015|SET|CHAPTER|\d{2,3} PART|Question Type|GRE Verbal|For each of|Select two |For (the following|this question)|\d+  .*?  GRUBER|Screen clipping"

    $content = Get-Content $path.Replace("\gre", "\temp\gre") -Raw
    $path = $path -replace ".txt", ".html"
    $content = $content -creplace "(?<=\r\n)($extraRegex).*\r\n"

    $splitIndex = $content.IndexOf("Answers")
    $explanation = $content.Substring($splitIndex + 9, $content.Length - $splitIndex - 9) 
    $content = $content.Substring(0, $splitIndex)
    ConvertFrom-Text
}
else {
    ConvertFrom-Epub
}
