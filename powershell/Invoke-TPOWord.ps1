
. "$PSScriptRoot/Utility.ps1"


function Add-XmlNodes ($xml, $parentNode, $nodes) 
{
    foreach ($node in $nodes) 
    {
        $xmlElement = $xml.CreateElement($node.Name)
        $xmlElement.InnerText = $node.InnerText
        try 
        {
            foreach ($attribute in $node.attributes.GetEnumerator())
            { $xmlElement.SetAttribute($attribute.Name, $attribute.Value) }
        }
        catch {}
        $parentNode.AppendChild($xmlElement)
        $xmlElement
    }
}

function Add-XmlTestItemNode($attributes) 
{
    $xml = ConvertTo-Xml -InputObject $xml
    $xml.RemoveAll()

    $node = @{ Name = "TestItem"; Attributes = $attributes }
    Add-XmlNodes $xml $xml $node | Out-Null
    $xml
}

function Add-XmlChildNodes($xml, $names, $innerTexts, $type) 
{
    $parentNode = $xml.FirstChild
    if ($type) { $parentNode = Add-XmlNodes $xml $xml.FirstChild @{ Name = $type} }
    $nodes = @()
    for ($i = 0; $i -lt $names.Count; $i++) 
    {
        $node = @{ Name = $names[$i]; InnerText = $innerTexts[$i] }
        $nodes += $node
    }
    Add-XmlNodes $xml $parentNode $nodes | Out-Null
}

function Get-PathPrefix($name) 
{
    $tpo = $name.Substring(0, 5)
    $section = $name.Substring(6, $name.Length - 11)
    $prefix = "$tpo\$section\$tpo$($section.Substring(0,1))"
    $prefix
}

function New-File($file, $path) 
{
    New-Item $path -ErrorAction SilentlyContinue
    if ($file.GetType().Name -eq "XmlDocument") {$file = Format-Xml $file}
    Set-Content -Value $file -Path $path
}

function Copy-ResourceItem($name, $path, $files) 
{
    try 
    {
        $file = $files.Where{$_.Name -like $name}[0]
        if ($file) { Copy-Item -Path $file.FullName -Destination $path -ErrorAction SilentlyContinue }
    }
    catch {
        Write-Host "name: $name, path: $path"
    }
}

function Add-Shading($text, $selection, $character) 
{
    try 
    {
        if ($character.Length -gt 1) 
        {
            $sentence = $selection
            $selection = $character.Remove(0, 1)
            $character = $character.Substring(0, 1)
            $selectionIndex = $sentence.IndexOf($selection) 
            $sentenceIndex = $text.IndexOf($sentence)
            if ($sentenceIndex -eq -1) { Write-Host "Can not find '$sentence'" }
            $text = $text.Insert($selectionIndex + $sentenceIndex, $character)
            $text = $text.Insert($selectionIndex + $sentenceIndex + $selection.Length + 1, $character)
        }
        else 
        {
            while ($selection.Endswith("`r")) { $selection = $selection.SubString(0, $selection.Length - 1) }
            $index = $text.IndexOf($selection)
            $text = $text.Insert($index, $character)
            $text = $text.Insert($index + $selection.Length + 1, $character)   
        }
        $text
    }
    catch 
    {
        Write-Host "text: $text, selection: $selection, character: $character"
    }
}

function Get-AllIndexesOf($string, $value) 
{
    $indexes = @()
    for ($index = 0; ; $index += $value.Length) 
    {
        $index = $string.IndexOf($value, $index)
        if ($index -eq -1) {break}
        $indexes += $index
    }
    $indexes
}

function Remove-Characters($string, $type) 
{
    if ($string.StartsWith("Paragraph "))
    {
        # if the sentence starwith "paragraph" remove the "paragraph" part
        $string = $string.SubString(12, $string.Length - 12)
    }
    if ($type -eq "selection") {$digit = "0-9"}
    $character = "[^A-za-z$digit!`"#$%&'()*+,./:;<=>?@\^_`{|}~-]"
    while ($string -and $string.Substring(0, 1) -match $character) { $string = $string.Remove(0, 1) } 
    while ($string -and $string.Substring($string.Length - 1, 1) -match $character) { $string = $string.Remove($string.Length - 1, 1) } 
    if ($type -eq "question") { while ($string.Substring(0, 1) -match "[^A-Za-z]") { $string = $string.Remove(0, 1) } }
    $string 
}

function Add-NewLineCharacter($string) 
{
    $string = $string -replace "\s*`r\s*", "`r"
    $string = $string -replace "`r`r", "`r"
    #if (-not($string.StartsWith("`r"))) { $string = $string.Insert(0, "`r") }
    #if (-not($string.EndsWith("`r"))) { $string = $string.Insert($string.Length, "`r") }
    while($string.Contains("  ")) { $string = $string.Replace("  ", " ") }
    #$string = $string.Replace("`r", "`n" + " " * 8)
    $string
}

function Get-TextParagraph($range, $startPosition, $next, $length) 
{
    if (-not($length)) {$length = [Int16]::MaxValue}
    if ($next -eq "Next") 
    {
        do 
        {
            $paragragh = $range.Paragraphs(1).Next($startPosition++).Range.Text
            if ($paragragh.StartsWith("Now listen to")) {break}
        } while ($paragragh.Length -lt 10 -or $paragragh.Length -gt $length) 
    }
    else 
    {
        do 
        {
            $paragragh = $range.Paragraphs(1).Previous($startPosition++).Range.Text
            if ($paragragh.StartsWith("Now listen to")) {break}
        } while ($paragragh.Length -lt 10 -or $paragragh.Length -gt $length)
    }
    $startPosition - 1
}

function Import-Docx () 
{
    $word = New-Object -ComObject Word.Application 
    $word.Visible = $true
    
    $filePath = "$env:USERPROFILE\Downloads\TOEFL\TPO\TPO$tpoNumber\TPO$tpoNumber "
    for ($i = 2; $i -lt $sections.Count; $i++) 
    {
        New-Item -Path "$projectPath\TPO$tpoNumber\$($sections[$i])" -ItemType "Directory" -ErrorAction SilentlyContinue
        $file = $word.Documents.Open("$filePath$($sections[$i]).docx")
        Invoke-Expression "ConvertTo-$($sections[$i])Xml `$file" 
        $file.Close()
    }
    $word.Quit() 
    [void][Runtime.Interopservices.Marshal]::ReleaseComObject($word)
}

function ConvertTo-ReadingXml($file) 
{
    $prefix = Get-PathPrefix $file.Name

    for ($i = 1; $i -lt 4; $i++) 
    {
        Write-Host "Reading $i"
        # Get passage Text
        if ($i -eq 1) {$range = $file.Content}
        else {$range = $file.Range($range.End, $file.Content.End)}
        $range.Find.Execute("Passage*$i", $default, $default, $true) | Out-Null
                            
        # Check if is Centered
        $iteratorRange = $range.Paragraphs(1).Next(1).Range
        for ($iter = 1; $iteratorRange.ParagraphFormat.Alignment -ne 1 -or $iteratorRange.Text.Length -lt 7; $iter++) 
        {
            $iteratorRange = $range.Paragraphs(1).Next($iter).Range
        }
     
        $startPosition = $iteratorRange.Start - 1
        $titleLength = $iteratorRange.Text.Length

        $range = $file.Range($range.End, $file.Content.End)
        $range.Find.Execute("aragraph") | Out-Null
        $text = $file.Range($startPosition, $range.Start - 2).Text
        $text = Add-NewLineCharacter $text
        # Create passage xml and text
        $xml = Add-XmlTestItemNode @{CLASS = "view_this_passage_noquest"}
        Add-XmlChildNodes $xml @("TPPassage", "PassageText") @("$prefix$i.txt", $text)
        New-File $xml "$projectPath\$prefix$i.xml"

        # Formalize passage text
        $text = $text.Insert(9, "}")
        $text = $text.Insert($titleLength + 9, "}")
        $text = $text.Insert(1, " " * (60 - $titleLength))

        $text = $text.Replace("[", "(")
        $text = $text.Replace("]", ")")
        New-File $text "$projectPath\$prefix$($i).txt"
        
        # Create Quetion xml
        $passageQuestionNumber = 1
        do 
        {
            Write-Host "Question $passageQuestionNumber"
            if ($passageQuestionNumber -lt 10) { $number = "0$passageQuestionNumber"}
            else {$number = "$passageQuestionNumber"}
            $attributePath = "$prefix$($i)Q$number"
            $findText = "^p$passageQuestionNumber"
            # Find question range and get question text
            $passageText = $text
            $questionRange = $file.Range($range.End, $file.Content.End)
            $questionRange.Find.Execute($findText) | Out-Null
            
            $questionRange = $questionRange.Paragraphs(1).Next(1).Range
            $questionText = $questionRange.Text

            # last drag and drop question
            if ($questionText.Contains("This question is worth ") -or $questionText.Contains("This question worth ")) { break }

            # Add essential element
            $names = @("TPPassage")
            $nodes = @("$attributePath.txt")
            
            # Add paragraph mark and paragraph element if question text has "(P|p)aragraph 2" or "paragraphs 3 and 4" 
            $match = ($questionText | Select-String "aragraphs? (?<Paragraph1>[0-9])( and (?<Paragraph2>[0-9]))?").Matches
            if ($match) 
            {
                $names += "Paragraph"
                $paragraphs = $match[0].Groups["Paragraph1"].Value
                $indexes = Get-AllIndexesOf $passageText ("`n" + " " * 8)
                $passageText = $passageText.Insert($indexes[[int]$paragraphs] + 1, "^6")
                $paragraph2 = $match[0].Groups["Paragraph2"].Value
                if ($paragraph2) 
                {
                    $passageText = $passageText.Insert($indexes[[int]$paragraph2] + 2, "^6")
                    $paragraphs += " and $paragraph2"
                }
                $nodes += $paragraphs
            }
 
            # Add scroll line element if the question number is large
            $names += "TPTopScrollLine"
            $nodes += ([int](($passageQuestionNumber - 1) * 2.5)).ToString()

            $xml = Add-XmlTestItemNode @{CLASS = "passage_ssmc"}
            $selectionRange = $file.Range($questionRange.Start, $questionRange.Start)
            $iter = 1
            do 
            {
            } until($selectionRange.Paragraphs(1).Previous($iter++).Range.Text.IndexOf("Paragraph ") -ne -1)
            $selectionRange = $file.Range($selectionRange.Paragraphs(1).Previous($iter).Range.Start, $questionRange.Start)
            if ($selectionRange.Paragraphs(1).Previous(1).Range.Text.IndexOf("Paragraph ") -ne -1)
            { $selectionRange = $file.Range($selectionRange.Paragraphs(1).Previous(1).Range.Start, $questionRange.Start)}
            $key = ""
            $index = $questionText.IndexOf("[")
            if ($index -ne -1 -or $questionText.IndexOf("squares") -ne -1) 
            {
                # Insert text question
                $xml.TestItem.CLASS = "passage_insertText"

                $insertText = Remove-Characters $questionRange.Paragraphs(1).Next(1).Range.Text "selection"
                $distractorNames = @("Distractor")
                $distractorNodes = @($insertText)

                # Get special character "" in 3 position
                if ($index -ne -1) 
                {
                    $character = $questionText -replace "[A-za-z0-9!`"#$%&'()*+,./:;<=>?@\^_`{|}~-]|\s", ""
                }
                $character = $questionText.Substring($index + 1, 1)
                $indexes = Get-AllIndexesOf $selectionRange.Text $character
                Set-Clipboard $selectionRange.Text
                # Add special characters in question text
                $questionText = $questionText.Remove($index + 1, 1)
                $questionText = $questionText.Insert($index + 1, " |   | ")

                # Get square character position where is the answer being inserted
                if ($indexes.Count -lt 4) 
                {
                    $startIndexes = Get-AllIndexesOf $selectionRange.Text "["$startIndexes = Get-AllIndexesOf $selectionRange.Text "["
                    for ($j = 0; $j -lt $startIndexes.Count; $j++) 
                    {
                        if ($selectionRange.Text.Substring($startIndexes[$j] + 1, $insertText.Length) -eq $insertText) {break}
                    }
                    $indexes += $startIndexes[$j] # Put 4 position togerther
                    $indexes = $indexes | Sort-Object 
                    $key = "" + ($indexes.IndexOf($startIndexes[$j]) + 1)
                }
                else 
                {
                    foreach ($index in $indexes) 
                    {
                        if ( $selectionRange.Text.Substring($index - 1, 1) -eq "[") { break }
                        $key = "" + ($indexes.IndexOf($index) + 1)
                    }
                }
                # get the answer square position in ordered array to get answer

                # Add special characters in passage text file
                foreach ($index in $indexes) 
                {
                    $sentence = $file.Range([int]$index + $selectionRange.Start + 1, [int]$index + $selectionRange.Start + 1).Sentences(1)
                    while ($sentence.Paragraphs(1).Range.Text.Length -lt 100) { $sentence = $sentence.Next(3, 1) }
                    # use context to find position to be inserted
                    $startPosition = $passageText.IndexOf((Remove-Characters $sentence.Text))
                    
                    if ($startPosition -le 0) 
                    {
                        # context before is not find, use context after position to find
                        $sentence = $sentence.Previous(3, 1)
                        $sentence = (Remove-Characters $sentence.Text)
                        $startPosition = $passageText.IndexOf($sentence) + $sentence.Length
                        if ($startPosition -eq $sentence.Length - 1) {Write-Host "Can not find sentence '$sentence' in insert text question"}
                    }
                    $passageText = $passageText.Insert($startPosition, " |]    ]| ")
                }
            }
            else 
            {
                if ($questionText.Contains("highlighted sentence")) 
                {
                    # highlighted sentence question
                    foreach ($sentence in $selectionRange.Sentences) 
                    {
                        if ($sentence.Text.StartsWith("Paragraph ")) 
                        {
                            # if the sentence starwith "paragraph" remove the "paragraph" part
                            $sentence = $file.Range($sentence.Start + 14, $sentence.End)
                        }
                        $isUnderLine = $true
                        foreach ($word in $sentence.Words) {
                            # if all words in the sentence is underlined means the whole sentence is underlined
                            if (-not($word.UnderLine)) 
                            {
                                if ($word.Text -eq "`r") {break}
                                $isUnderLine = $false
                                break   
                            }
                        }
                        if ($isUnderLine) 
                        {
                            # find the underline sentence
                            $passageText = Add-Shading $passageText (Remove-Characters $sentence.Text) "["  
                            break 
                        }
                    }
                }
                # single selection question
                else 
                {
                    # Get Underline Selection Range
                    $startPosition = [int32]::MaxValue
                    $endPosition = 0
    
                    $selection = @()                    
                    # Select as much underlined text as possible
                    foreach ($word in $questionRange.Words) 
                    {
                        if ($word.UnderLine) 
                        {
                            $startPosition = [Math]::Min($startPosition, $word.Start)
                            $endPosition = [Math]::Max($endPosition, $word.End)
                        }
                        if ($startPosition -lt $endPosition -and -not($word.UnderLine)) 
                        { 
                            $selection += $file.Range($startPosition, $endPosition).Text 
                            $startPosition = [int32]::MaxValue
                            $endPosition = 0
                        }
                    }
    
                    # if has underlined text
                    foreach ($element in $selection) 
                    { 
                        # if there is undertext add special character in text
                        $endPosition = $selectionRange.End
                        while ($selectionRange.Find.Execute($element, $true, $true)) 
                        {
                            if (-not($selectionRange.Underline) -or $selectionRange.Sentences(1).Underline -lt 60) 
                            {
                                $selectionRange = $file.Range($selectionRange.End, $endPosition)
                            }
                            else { break }
                        }

                        # phrase
                        if($element.Contains(" ")) 
                        {
                            $sentence = $element
                        }    
                        else
                        {
                            $sentence = $selectionRange.Sentences(1).Text
                        }

                        $questionText = Add-Shading $questionText $element "|"
                        $passageText = Add-Shading $passageText (Remove-Characters $sentence) "[$element"
                    }  
                }

                # Add selection element
                $distractorNames = "Distractor", "Distractor", "Distractor", "Distractor"
                $distractorNodes = @()

                for ($j = 1; $j -lt 5; $j++) 
                {
                    # get selection text
                    $distractorNodes += Remove-Characters $questionRange.Paragraphs(1).Next($j).Range.Text "selection"
                    if ($questionRange.Paragraphs(1).Next($j).Range.Bold) { $key += "$j" }
                }                   
            }
            
            $names += "Stem"
            $nodes += Remove-Characters $questionText "question"
            Add-XmlChildNodes $xml $names $nodes
            Add-XmlChildNodes $xml $distractorNames $distractorNodes "Distractor_list"

            if (-not($key)) 
            {
                $keyRange = $file.Range($questionRange.End, $file.Content.End)
                $keyRange.Find.Execute($findText) | Out-Null
                $key = Remove-Characters $keyRange.Paragraphs(1).Range.Text
                $key = $key.Substring($key.Length - 1, 1)
                if (-not($key)) { Write-Host "Key is missing"}
            }
            Add-XmlChildNodes $xml @("Key") @($key)
                
            New-File $xml "$projectPath\$attributePath.xml" 
            New-File $passageText "$projectPath\$attributePath.txt"

            $passageQuestionNumber++
  
        } until ($questionText.contains("This question is worth "))

        if ($questionText.Contains("worth 2 points")) 
        {
            $xml = Add-XmlTestItemNode @{CLASS = "draggy"}
        }
        else 
        {
            $xml = Add-XmlTestItemNode @{CLASS = "draggy_table"}
        }
        Add-XmlNodes $xml $xml.FirstChild @{Name = "TPviewtext"; Attributes = @{PASSAGE = "$attributePath.txt"}} | Out-Null

        $range = $file.Range($questionRange.End, $file.Content.End)
        $range.Find.Execute("Answer*hoices", $default, $default, $true) | Out-Null

        $names = "tpFont", "QuestBmp"
        $nodes = "Arial,12,0", "$attributePath.bmp"

        Add-XmlChildNodes $xml $names $nodes

        $xCoordinates = "540", "45"
        $yCoordinates = "570"
        $bucketNames = "tpBucket", "tpBucket", "tpBucket"

        if ($questionText.Contains("worth 2 points")) 
        {
            $bucketNodes = "300,320", "300,400", "300,480"    
        }
        else 
        {
            $bucketNodes = "410,300", "410,350", "410,430", "410,480", "410,530"
            $bucketNames += "tpBucket", "tpBucket", "tpBucket", "tpBucket"
        }
        if(!$questionText.Contains("worth 2 points"))
        {
            $category = @()
            $character = $range.Paragraphs(1).Previous(1).Range.Text.Substring(0,1)
            $j = 1
            while ($range.Paragraphs(1).Previous(++$j).Range.Text.Substring(0,1) -eq $character) 
            { }
            $category += Remove-Characters $range.Paragraphs(1).Previous($j).Range.Text
            while ($range.Paragraphs(1).Previous(++$j).Range.Text.Substring(0,1) -eq $character) 
            { }
            $category += Remove-Characters $range.Paragraphs(1).Previous($j).Range.Text
            if($questionText.Substring(0, $questionText.IndexOf($category[1].Split(" ")[0].ToLower())).Contains("two"))
            {
                [Array]::Reverse($category)
            }
        }

        $names = @()
        $nodes = @()
        $choices = @()
        $keys = ""
        for ($j = 1; $range.Paragraphs(1).Next($j).Range.Text.Length -gt 5; $j++) 
        {
            $names += "tpObject"
            if ($questionText.Contains("worth 2 points"))
            {
                $step = 75
            }
            else 
            {
                $step = 45
            }
            $coordinates = "$($xCoordinates[$j % 2]),$([int]$yCoordinates + $step * ([Math]::Ceiling($j / 2) - 1))"
            $choice = Remove-Characters $range.Paragraphs(1).Next($j).Range.Text "selection"
            $choices += $choice
            $nodes += "$coordinates,450,0,$choice"
            $bucketNames += "tpBucket"
            $bucketNodes += $coordinates
            if($questionText.Contains("worth 2 points"))
            {
                if ($range.Paragraphs(1).Next($j).Range.Bold) 
                { 
                    $keys += "$j" 
                }
            }
            else 
            {
                $categoryRange = $file.Range($questionRange.End, $range.Start)
                if($categoryRange.Find.Execute($choice))
                {
                    $k = 0
                    do
                    {
                        $type = $category.IndexOf((Remove-Characters $categoryRange.Paragraphs(1).Previous(++$k).Range.Text))
                    } until ($type -ne -1)
                    $keys += "$j;$($k + 2 * $type)|"
                }
            }
        }

        $textParagraph = Get-TextParagraph $range 1 "Previous"
        if ($questionText.Contains("worth 2 points"))
        {
            $names += "tpObject"
            $nodes += "150,240,800,0,$(Remove-Characters $range.Paragraphs(1).Previous($textParagraph).Range.Text)"
        }
        else 
        {
            for($j = 0; $j -lt $category.Count; $j++)
            {
                $nodes += "160,$(280 + $j * 140),800,0,$($category[$j])"
            }
            $names += "tpObject", "tpObject", "tpObject"
            $questionText = $questionText.Remove(0, $questionText.IndexOf("Directions") + "Directions".Length + 2)
            $nodes += "200,140,700,0,$(Remove-Characters $questionText)"
        }

        Add-XmlChildNodes $xml $names $nodes "tpObject_list"
        Add-XmlChildNodes $xml $bucketNames $bucketNodes "tpBucket_list"
            
        if (-not($keys)) 
        {
            $keyRange = $file.Range($questionRange.End, $file.Content.End)
            $keyRange.Find.Execute($findText) | Out-Null
            $answers = @(Remove-Characters $keyRange.Paragraphs(1).Range.Text)
            for ($iter = 0; $iter -lt 2; $iter++) 
            {
                $answers += Remove-Characters $keyRange.Paragraphs(1).Next($iter).Range.Text
            }
            foreach ($answer in $answers) 
            {
                $keys += $choice.IndexOf($choices -like $answer)
            }
        }

        Add-XmlChildNodes $xml @("key") @($keys)

        if ($questionText.Contains("worth 2 points")) 
        {
            $answers = "1234567"
            for ($j = 0; $j -lt $keys.Length; $j++) 
            {
                $answers = $answers.Remove([int]$keys.Chars($j).ToString() - 1, 1)
                $answers = $answers.Insert([int]$keys.Chars($j).ToString() - 1, "0")
            }
        }
        else 
        {
            $pairs = $keys -split "\|"
            $answers = "123456789"
            $keys = "00000"
            foreach($pair in $pairs)
            {
                if($pair.Length -lt 1) {break}
                $answers = $answers.Remove([int]($pair -split ";")[0] - 1, 1)
                $answers = $answers.Insert([int]($pair -split ";")[0] - 1, "0")
                $keys = $keys.Remove([int]($pair -split ";")[1] - 1, 1)
                $keys = $keys.Insert([int]($pair -split ";")[1] - 1, ($pair -split ";")[0])
            }
        }
        
        $answers = $keys + $answers
        $keys = ""
        for ($j = 0; $j -lt $answers.Length; $j++) 
        {
            $keys += $answers.Chars($j).ToString() + ","
        }

        Add-XmlChildNodes $xml @("specialShowAnswer") @($keys)

        New-File $xml "$projectPath\$attributePath.xml" 
        New-File $passageText "$projectPath\$attributePath.txt"
        if ($questionText.Contains("worth 2 points")) 
        {
            Copy-Item "$projectPath\Sampler\draggy.bmp" "$projectPath\$attributePath.bmp" 
        }
        else 
        {
            Copy-Item "$projectPath\Sampler\draggy_table.bmp" "$projectPath\$attributePath.bmp"
        }
    }
}

function ConvertTo-ListeningXml($file) 
{
    $prefix = Get-PathPrefix $file.Name
    $wavFiles = Get-ChildItem $wavPath -Include "TPO$([int]$tpoNumber)_$($prefix.Split('\')[1])*.wav"
    $jpgFiles = Get-ChildItem $jpgPath -Include "TPO$([int]$tpoNumber)_passage*.jpg" -Recurse

    $questionNumber = 1
    for ($i = 1; $i -lt 7; $i++) 
    {
        Write-Host "Listening $i"

        $wavSet = "$([Math]::Ceiling($i/3))"
        $passageNumber = if ($i % 3 -eq 0) {3} else {$i % 3}
        Copy-ResourceItem "*passage$($wavSet)_$passageNumber.wav" "$projectPath\$prefix$i.wav" $wavFiles
        Copy-ResourceItem "*$($wavSet)_$passageNumber.jpg" "$projectPath\$prefix$i.jpg" $jpgFiles
        
        $passageQuestionNumber = 1

        $range = $file.Content
        $range.Find.Execute("Passage $i") | Out-Null

        $questionRange = $file.Range($range.End, $file.Content.End)
        $found = $questionRange.Find.Execute("^p$questionNumber")
        if (-not($found)) 
        {
            $questionNumber = 1
            $questionRange = $file.Range($range.End, $file.Content.End)
            $questionRange.Find.Execute("^p$questionNumber") | Out-Null
        }

        $xml = Add-XmlTestItemNode @{CLASS = "lecture"}

        $names = "LecturePicture", "LectureSound", "LecturePicture", "AudioText"
        $nodes = 
        @(
            "$prefix$i.jpg",
            "$prefix$($i).wav",
            "Sampler\GetReady.gif",
            (Add-NewLineCharacter $file.Range($range.End + 1, $questionRange.Start - 2).Text)
        )
        Add-XmlChildNodes $xml $names $nodes

        New-File $xml "$projectPath\$prefix$i.xml"

        do 
        {
            Write-Host "Question $passageQuestionNumber"
            $questionSet = if ($questionNumber % 17 -eq 0) {17} else {$questionNumber % 17}
            $questionRange = $file.Range($range.End, $file.Content.End)
            $questionRange.Find.Execute("^p$questionNumber") | Out-Null
 
            $xml = Add-XmlTestItemNode @{CLASS = "ssmc_simple"}

            $audioPath = "$projectPath\$prefix$($i)Q$($passageQuestionNumber)R.wav"

            Copy-ResourceItem "*repeat$($wavSet)_$questionSet.wav" $audioPath $wavFiles

            if (Test-Path $audioPath) 
            {
                $names = "LecturePicture", "LectureSound"
                $nodes = 
                @(
                    "Sampler\RplayLec.gif",
                    "$prefix$($i)Q$($passageQuestionNumber)R.wav"
                )
                Add-XmlChildNodes $xml $names $nodes "miniLecture"
            }

            Copy-ResourceItem "*question$($wavSet)_$questionSet*" "$projectPath\$prefix$($i)Q$($passageQuestionNumber).wav" $wavFiles
            
            $key = ""
            $questionText = $questionRange.Paragraphs(1).Next(1).Range.Text
            $index = $questionText.IndexOf("Keys: ")
            if ($index -ne -1) 
            {
                $key = $questionText.Substring($index + 6, $questionText.Length - $index - 6)
                $questionText = $questionText.Remove($index, $questionText.Length - $index)
            }

            $names = "Stem", "StemWav"
            $nodes = 
            @(
                (Remove-Characters $questionText "question"),
                "$prefix$($i)Q$($passageQuestionNumber).wav"
            )
            Add-XmlChildNodes $xml $names $nodes
    
            $names = @()
            $nodes = @()
            
            $flag = $true
            $selectionRange = $file.Range($questionRange.End, $questionRange.Paragraphs(1).Next(3).Range.End)
            if ($selectionRange.Tables.Count -gt 0) 
            {
                $flag = $false
                $table = $selectionRange.Tables(1)
                for ($j = 1; $j -le $table.Rows.Count; $j++) 
                {
                    if ($j -ne 1) 
                    {
                        $names += "Distractor"
                        $nodes += Remove-Characters $table.Cell($j, 1).Range.Text "selection"
                    }
                    for ($k = 2; $k -le $table.Columns.Count; $k++) 
                    {
                        if ($j -eq 1) 
                        {
                            $xml.TestItem.Stem += " " + $table.Cell($j, $k).Range.Text
                        }
                        elseif ($table.Cell($j, $k).Range.Text -like "*x*") 
                        {
                            $key += ($k - 1).ToString()
                            break
                        }
                    }
                }
            }

            if ($flag) 
            {
                for ($j = Get-TextParagraph $questionRange 1 "Next"; $questionRange.Paragraphs(1).Next($j+1).Range.Text.Length -gt 10; $j++) 
                {
                    $names += "Distractor"
                    $nodes += Remove-Characters $questionRange.Paragraphs(1).Next($j+1).Range.Text "selection"
                    if ($questionRange.Paragraphs(1).Next($j+1).Range.Bold) { $key += "$j" }
                }
            }
            if (-not($key)) { Write-Host "Key is missing"}
            Add-XmlChildNodes $xml $names $nodes "Distractor_list"
            Add-XmlChildNodes $xml @("Key") @($key)

            if ($key.Length -gt 1) {$xml.TestItem.CLASS = "2smc_simple"}
            New-File $xml "$projectPath\$prefix$($i)Q$passageQuestionNumber.xml" 

            $questionNumber++
            $passageQuestionNumber++
           
        } until ($questionRange.Paragraphs(1).Next(7).Range.Text.Length -lt 15 -and $flag)
    }
}

function ConvertTo-SpeakingXml ($file) 
{
    $prefix = Get-PathPrefix $file.Name
    
    #$wavFiles = Get-ChildItem $wavPath -Include "TPO$([int]$tpoNumber)_$($prefix.Split('\')[1])*.wav"
    #$jpgFiles = Get-ChildItem $jpgPath -Include "TPO$([int]$tpoNumber)_question*.jpg" -Recurse

    for ($i = 3; $i -lt 7; $i++) 
    {
        Write-Host "Speaking $i"
        $xml = Add-XmlTestItemNode `
        @{
            CLASS          = "speaking_paced"; 
            TIMELIMIT      = $time[0][[Math]::Ceiling($i / 2) - 1]; 
            PREPLIMIT      = $time[1][[Math]::Ceiling($i / 2) - 1]; 
            SHOWDIRECTIONS = "FALSE"
        }
        if ($i -eq 1) { $range = $file.Content }
        else { $range = $file.Range($range.End, $file.Content.End) }
        $range.Find.Execute("$i") | Out-Null
        $startPosition = $range.Start
        $range = $file.Range($range.End, $file.Content.End)
        $range.Find.Execute("#$i Sample Response") | Out-Null
        $passageRange = $file.Range($startPosition, $range.Start)

        if ($i -ne 1 -and $i -ne 2) 
        {
            if ($i -eq 3 -or $i -eq 4) 
            {
                #Copy-ResourceItem "*$i*before*" "$projectPath\$prefix$($i)P.wav" $wavFiles
                
                $names = "miniPassageIntroSound", "miniPassageIntroPic", "miniPassageDuration", "miniPassageTitle", "miniPassageText"
                $titleParagraph = Get-TextParagraph $passageRange 1 "Next" 50
                $textParagraph = Get-TextParagraph $passageRange ($titleParagraph + 1) "Next"
                
                $nodes = `
                @( 
                    "$prefix$($i)P.wav", 
                    "Sampler\headphon.jpg", 
                    $passageRange.Text.Substring($passageRange.Text.IndexOf(" seconds") - 2, 2),
                    (Remove-Characters $passageRange.Paragraphs(1).Next($titleParagraph).Range.Text),
                    (Add-NewLineCharacter $passageRange.Paragraphs(1).Next($textParagraph).Range.Text)
                )
                Add-XmlChildNodes $xml $names $nodes "miniPassage"     
            }

            #Copy-ResourceItem "*$i*dialog*" "$projectPath\$prefix$($i).wav" $wavFiles
            #Copy-ResourceItem "*$i*" "$projectPath\$prefix$($i).jpg" $jpgFiles
            
            $names = "LecturePicture", "LectureSound", "LecturePicture"
            $nodes = `
            @( 
                "$prefix$($i).jpg",
                "$prefix$($i).wav",
                "Sampler\SGetReady.gif"
            )
            Add-XmlChildNodes $xml $names $nodes "miniLecture"

            $audioTextRange = $file.Range($startPosition, $file.Content.End)
            $audioTextRange.Find.Execute("Now listen to ") | Out-Null

            $questionParagraph = Get-TextParagraph $range 1 "Previous"

            Add-XmlNodes $xml $xml.FirstChild `
            @{
                Name      = "AudioText";
                InnerText = ""
            } | Out-Null

            Add-NewLineCharacter $file.Range($audioTextRange.Start, $range.Paragraphs(1).Previous($questionParagraph).Range.Start).Text `
            | Out-File ("TPO$tpoNumber"+"S$i.txt")
        }

        #Copy-ResourceItem "*$i.wav" "$projectPath\$prefix$($i)Q.wav" $wavFiles

        $questionParagraph = Get-TextParagraph $range 1 "Previous"
        $textParagraph = Get-TextParagraph $range 1 "Next"

        $names = "Stem", "StemWav", "SampleResponse"
        $nodes = `
        @( 
            (Remove-Characters $range.Paragraphs(1).Previous($questionParagraph).Range.Text "question"),
            "$prefix$($i)Q.wav",
            (Add-NewLineCharacter $range.Paragraphs(1).Next($textParagraph).Range.Text)
        )
        Add-XmlChildNodes $xml $names $nodes 

        #New-File $xml "$projectPath\$prefix$i.xml"
    }
}

function ConvertTo-WritingXml ($file) 
{
    Write-Host "Writing"
    $prefix = Get-PathPrefix $file.Name

    $range = $file.Content
    $textParagraph = Get-TextParagraph $range 0 "Next"
    $range.Find.Execute("Use specific reasons and examples to support your answer") | Out-Null
    $w1Range = $file.Range($file.Paragraphs($textParagraph).Range.Start, $range.Paragraphs(1).Previous(1).Range.End)

    $sampleRange = $file.Range($w1Range.Start, $w1Range.End)
    $sampleRange.Find.Execute("Sample Response") | Out-Null

    $range = $file.Range($w1Range.Start, $w1Range.End)
    $range.Find.Execute("Listening") | Out-Null

    # Integrated Writing Xml
    $xml = Add-XmlTestItemNode @{CLASS = "writelisten_paced"; TIMELIMIT = "20"; SHOWDIRECTIONS = "FALSE"} 

    $names = "miniPassageDuration", "miniPassageText"
    $nodes = `
    @(
        180, 
        ("")
    )
    
    Add-XmlChildNodes $xml $names $nodes "miniPassage"
   
    #$wavFile = Get-ChildItem $wavPath -Include "TPO$([int]$tpoNumber)_$($prefix.Split('\')[1])*.wav"
    #$jpgFile = Get-ChildItem $jpgPath -Include "TPO$([int]$tpoNumber)_$($prefix.Split('\')[1])*.jpg" -Recurse

    #Copy-Item $wavFile.FullName "$projectPath\$($prefix)1.wav"
    #Copy-Item $jpgFile.FullName "$projectPath\$($prefix)1.jpg"

    $names = "LecturePicture", "LectureSound", "LecturePicture"
    $nodes = `
    @(
        "$($prefix)1.jpg",
        "$($prefix)1.wav",
        "Sampler\WGetReady.gif"
    )
    Add-XmlChildNodes $xml $names $nodes "miniLecture"

    $names = "AudioText", "Stem", "StemWav", "SampleResponse"
    $nodes = `
    @(
        (Add-NewLineCharacter $file.Range($range.End, $sampleRange.Start - 1).Text),
        "Summarize the points made in the lecture, being sure to explain how they oppose specific points made in the reading passage.",
        "Sampler\SAWQ.wav",
        (Add-NewLineCharacter $file.Range($sampleRange.End, $w1Range.End - 2).Text)
    )
    Add-XmlChildNodes $xml $names $nodes
    Add-NewLineCharacter $file.Range($range.End, $sampleRange.Start - 1).Text | Out-File ("TPO$tpoNumber"+"W1.txt")
    #New-File $xml "$projectPath\$($prefix)1.xml"
    
    # Independent Writing Xml
    $range = $file.Content
    $range.Find.Execute("Use specific reasons and examples to support your answer") | Out-Null
    $w2Range = $file.Range($range.Paragraphs(1).Previous(2).Range.End, $file.Content.End)
    $range = $file.Range($w2Range.Start, $w2Range.End)
    $range.Find.Execute("Sample Response") | Out-Null

    $xml = Add-XmlTestItemNode @{CLASS = "independentwriting_paced"; TIMELIMIT = "30"}

    # Question
    $names = "Stem", "SampleResponse"
    $nodes = `
    @(
        (Add-NewLineCharacter $file.Range($w2Range.Start, $range.Start - 1).Text),
        (Add-NewLineCharacter $file.Range($range.End, $file.Content.End).Text)
    )
    Add-XmlChildNodes $xml $names $nodes

    #New-File $xml "$projectPath\$($prefix)2.xml"
}

function Update-SamplerXml () 
{
    
    $path = "$($projectPath.Substring(0, $projectPath.Length - 7))\sampler.xml"
    $content = Get-Content $path
    $content = $content -replace "TPO[0-9]*", "TPO$tpoNumber"
    [xml]$xml = $content

    foreach ($section in $sections[0..1]) 
    {
        $xmlPrefix = "$projectPath\TPO$tpoNumber\$section\TPO$tpoNumber$($section.Chars(0))"
        $nodes = Select-Xml -Xml $xml -XPath "/TestItem/TESTLET[@LABEL=`"$section`" and @NUMBQUESTS]"
        for ($i = 1; $i -le $nodes.Count; $i++) 
        {
            $count = (Get-ChildItem "$xmlPrefix$($i)Q*.xml").Count
            $node = $nodes[$i - 1].Node
            if ($section -eq "Reading") { $node.NUMBQUESTS = $count.ToString() }
            else 
            {
                if ($i -lt 4) { $question = "123" }
                else { $question = "456" }
                $node.NUMBQUESTS = (Get-ChildItem "$xmlPrefix[$question]Q*.xml").Count.ToString()
            }
            if ($node.QUESTBEGIN) 
            {
                $length = $nodes[$i - 2].Node.TestItemName.Count
                if ($i -eq 3 -or $i -eq 6) { $length += $nodes[$i - 3].Node.TestItemName.Count - 1 }
                $node.QUESTBEGIN = ($length).ToString()
            }
            while ($node.TestItemName.Count - 1 -lt $count) 
            { 
                Add-XmlNodes $xml $node `
                @{
                    Name = "TestItemName"; 
                    InnerText = "TPO$tpoNumber\$section\TPO$tpoNumber$($section.Chars(0))$($i)Q$($node.TestItemName.Count).xml"
                }
            }
            while ($node.TestItemName.Count - 1 -gt $count)
            { $node.RemoveChild($node.LastChild) }
        }
    }
    New-File $xml "$($projectPath.Substring(0, $projectPath.Length - 7))\sampler.xml" 
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
    for ($i = 0; $i -lt $keys.Count; $i++) 
    {
        for ($j = 1; $j -le $keys[$i].Count; $j++) 
        {
            for ($k = 1; $k -le $keys[$i][$j - 1].Count; $k++) 
            {
                if ($k -lt 10 -and $i -eq 0) { $l = "0$k" }
                else {$l = $k}
                [xml]$xml = Get-Content "$projectPath\TPO$tpoNumber\$($sections[$i])\TPO$tpoNumber$($sections[$i].Chars(0))$($j)Q$l.xml"
                
                if ($xml.TestItem.Key -ne $keys[$i][$j - 1][$k - 1]) 
                {
                    $totalPoints[$i]--
                    if ($k -eq 14) 
                    {
                        $string = $xml.TestItem.Key
                        $point = -3
                        foreach ($character in $string.ToCharArray()) 
                        {
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

function Update-Audio ($test) 
{
    $xmlFiles = Get-ChildItem "$projectPath\TPO$tpoNumber\*.xml" -Recurse
    foreach ($xmlFile in $xmlFiles) 
    {
        [xml]$xml = Get-Content $xmlFile
        $node = (Select-Xml "/TestItem[@CLASS!='ssmc_simple']//LectureSound" $xml).Node
        if ($node) 
        { 
            if ($test) { $node.InnerText = "Sampler\RLWlistn.wav" }
            else { $node.InnerText = $xmlFile.FullName.Substring(60, $xmlFile.FullName.Length - 64) + ".wav" }
        }

        $node = (Select-Xml "/TestItem[@CLASS='speaking_paced']" $xml).Node
        if ($node)
        {
            if ($test) 
            { 
                $node.Attributes["TIMELIMIT"].Value = 2
                $node.Attributes["PREPLIMIT"].Value = 2
            }
            else 
            {
                $number = [int]$xmlFile.Name.Substring(6,1)
                $node.Attributes["TIMELIMIT"].Value = $time[0][[Math]::Ceiling($number / 2) - 1]
                $node.Attributes["PREPLIMIT"].Value = $time[1][[Math]::Ceiling($number / 2) - 1]
            }
        }

        $node = (Select-Xml "/TestItem[@CLASS='writelisten_paced']//miniPassageDuration" $xml).Node
        if ($node) 
        { 
            if ($test) { $node.InnerText = "2" }
            else { $node.InnerText = "180" }
        }
        $xml.Save($xmlFile.FullName) 
    }
}


$global:sections = "Reading", "Listening", "Speaking", "Writing"
$global:projectPath = "$env:USERPROFILE\Downloads\ETS\TOEFL\TOEFLSampler\forml1"
$global:default = [Type]::Missing
$global:wavPath = "$env:USERPROFILE\Music\*"
$global:jpgPath = "$env:USERPROFILE\Downloads\ETS\TOEFL\TPO\resources\cache\*"
$global:time = @("45", "60", "60"), @("15", "30", "20")

[xml]$xml = Get-Content "C:\Users\decisactor\Downloads\VSCode\My Code\GitHub\blog\mdn-javascript.html"

for ($i = 25; $i -lt 14; $i++) 
{
    $global:tpoNumber = $i
    if ([int]$tpoNumber -lt 10) {$tpoNumber = "0$tpoNumber"} 
    #New-Item -Path "$projectPath\TPO$tpoNumber\" -ItemType "Directory" -ErrorAction SilentlyContinue
    #Import-Docx
}


#Update-SamplerXml
#Update-Audio "test"
#Get-Score

<#
#$word = New-Object -ComObject Word.Application 
#$word.Visible = $true



for ($i = 50; $i -lt 52; $i++) 
{
    #$file = $word.Documents.Open("$env:USERPROFILE\Documents\TOEFL\TPO\TPO$i\TPO$i Speaking.docx")
    $range = $file.Content
    for ($j = 3; $j -lt 7; $j++)
    {
        #New-Item "$PSScriptRoot\TPO$($i)S$j.txt"
    }

    #New-Item "$PSScriptRoot\TPO$($i)W1.txt" 
    
}


#$word.Quit() 
#[void][Runtime.Interopservices.Marshal]::ReleaseComObject($word)
#>
