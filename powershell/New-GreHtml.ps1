. $PSScriptRoot\Utility.ps1
$wordApp = $null
$set = "pr"
$name = "$set-dr-verbal" 
$type = "html"
$ebooks = "C:\github\temp\ebooks"
$testHtml = "C:\github\temp\files\html\test.html"
$path = "C:\github\gre\$set\$name.html"
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
        $text = Export-ImageText $path.Replace("_r1","") $rect
        $text = $text -replace "^.*?\n" -replace "\n+", "`n"
        $words = ($text | Select-String $regex -AllMatches).Matches
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
        [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
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
        $text = Export-ImageText $newPath
        Remove-Item $newPath
    }
    else {
        $text = Export-ImageText $path
    }

    $text -replace "(\w)\|(\w)", "`$1l`$2"
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
                $text = if (Test-Logic $question) {
                    $question.ChildNodes[1].InnerText
                }
                else {
                    $question.ChildNodes[0].InnerText
                }
            }
            else {
                $text = $question.InnerText -replace "^\d+\.? ?|\u00A0"
            }
            $text
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
    
            $text = Get-QuestionText
            $blank = (Get-RegExMatch $text "_{2,}").Count
    
            if ($question.InnerXml -match " sentence " -and !$blank -and 
            $question.InnerXml -notmatch " highlighted ") { $type = "select" }
            else {$type = "radio"}
              
            
            if ((Select-Xml "//div[contains(@id,'question')]" $questionsDiv)) {
                $id = (Select-Xml "//div[contains(@id,'question')]" $questionsDiv).Node.Count
                if (!$id) { $id = 1}
            }
            
            #Write-Host "Question $id"
            
            $questionDiv = Add-XmlNode ("div", @{id = "question$id"; "data-choice-type" = $type}) $questionsDiv
            Add-XmlNode ("div", @{class = "question"}, "<p>$text</p>") $questionDiv | Out-Null
    
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
                            $content = if ($text -match "i{2,3}") { $content -replace "^.*?\n"} else {$content}
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
            for ($j = 0; $j -lt $passages.Count -and $text -notmatch "__"; $j++) {
    
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

function ConvertFrom-Text ($content, $path) {
    function Remove-FootNote ($text) {
        $text = $text -replace "CHAPTER.*\r\n" # page footnote
        $text = $text -replace "\d{1,3}\r\n" # page number
        $text = $text -replace "GRE Verbal Reasoning Practice Questions\r\n" # page footnote
        $text = $text -replace "Question Type.*\r\n" # page footnote
        $text = $text -replace "\d{2,3} PART .*\r\n" # page footnote
        $text
    }
    
    function Update-Text($regex, $oldText, $newText) {
        foreach ($match in (Get-RegExMatch $text $regex)) {
            $text = $text -replace (Invoke-Expression $oldText), (Invoke-Expression $newText)
        }
        $text
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
                    $answer += $choice[$number++][0] 
                    while ($content[0][$choice[$number].Index - 13] -eq ";" -or $content[0][$choice[$number].Index - 12] -eq ";" -or $content[0][$choice[$number].Index - 8] -eq ";") { 
                        $answer += $choice[$number++][0] 
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
                $start = $explanation.IndexOf($choicesDiv[$i])
    
                # answer
                $answer = $choicesDiv[$i][-1]
                
                $string = $explanation.substring($start + $choicesDiv[$i].Length, 4)
                if ($string -eq " and") {
                    $answer += $explanation.substring($start + $choicesDiv[$i].Length + 5, 1)
                }
                elseif ($string -eq ", ") {
                    $answer += $explanation.substring($start + $choicesDiv[$i].Length + 2, 1)
                    $answer += $explanation.substring($start + $choicesDiv[$i].Length + 9, 1)
                }
                $answers[$i].Node.SetAttribute("data-answer", $answer)
    
                # explanation 
                $end = if ($i -eq $choicesDiv.Count - 1) {$explanation.Length - 1} else {$explanation.IndexOf($choicesDiv[$i + 1])}
                
                $answers[$i].Node.ChildNodes[0].InnerXml = "<p>" + $explanation.substring($start, $end - $start) + "</p>"
            }
        }
    
    
        #New-Item -Path $path -value $xml.OuterXml -ErrorAction SilentlyContinue | Out-Null
        Set-Content $path $xml.OuterXml.Replace("html[]", "html") -Encoding UTF8
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
    $oldText = "`"(\u201D)?[(\r\n)| ]`$(`$match.Trim(`"<p>Questions `"))\. `""
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
    $oldText = "`$match"
    $newText = "`"`$(`$match.Replace('</p></div><div class=`"choices`"><p>', ' '))`""
    
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
            $newText = "`"`$(`$match.Replace('</p><p>', ' '))`""
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
                $temp = $value1.InnerText
                $value1.InnerText = $value2.InnerText
                $value2.InnerText = $temp
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


if ($type -eq "txt") {
    $splitIndex = $content.IndexOf("Answers")
    $question = $content.Substring(0, $splitIndex)
    $explanation = $content.Substring($splitIndex + 7, $content.Length - $splitIndex - 7) 
    ConvertFrom-Text $question $path
    Get-Answer $explanation $path
}
else {
    ConvertFrom-Epub
}
