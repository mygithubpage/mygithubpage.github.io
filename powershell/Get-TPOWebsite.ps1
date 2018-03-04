
. ".\Utility.ps1"

function Add-XmlNodes ($xml, $parentNode, $nodes) 
{
    foreach ($node in $nodes) 
    {
        $xmlElement = $xml.CreateElement($node.Name)
        $xmlElement.innerText = $node.innerText
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
        $node = @{ Name = $names[$i]; innerText = $innerTexts[$i] }
        $nodes += $node
    }
    Add-XmlNodes $xml $parentNode $nodes | Out-Null
}

function New-File($file, $path) 
{
    New-Item $path -ErrorAction SilentlyContinue | Out-Null
    if ($file.GetType().Name -eq "XmlDocument") {$file = Format-Xml $file}
    Set-Content -Value $file -Path $path
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

function Copy-ResourceItem($name, $path, $files) 
{
    $file = $files.Where{$_.Name -like $name}[0]
    if ($file) { }#Copy-Item -Path $file.FullName -Destination $path -ErrorAction SilentlyContinue }
}

function Format-Paragraphs($string) 
{
    $string = $string -replace "\s*`r`n\s*", "`r"
    $string = $string -replace "`r`n`r`n", "`r"
    while($string.Contains("  ")) { $string = $string.Replace("  ", " ") }
    $string = $string.Replace("`r", "`n" + " " * 8)
    $string
}

function Add-Shading($text, $highlight, $character) 
{
    $sentenceIndex = $text.IndexOf((Remove-Characters $highlight.parentNode.innerText))
    $index = $highlight.parentNode.innerHTML.indexof("v=201711281803") + 16
    if($index -ne 15) 
    {
        $selectionIndex = $highlight.parentNode.innerHTML.IndexOf('<span class="light">') - $index
        $selection = $highlight.parentNode.innerHTML.Substring($selectionIndex + 20 + $index, `
            $highlight.parentNode.innerHTML.IndexOf('</span>') - $selectionIndex - 20 - $index)
    }
    else
    {
        $index = $highlight.parentNode.innerHTML.indexof("data-answer=") + 23
        $selectionIndex = $highlight.parentNode.innerHTML.IndexOf('<span class="light">')
        if($index -ne 22) 
        { 
            $selectionIndex -= $index 
            $selection = $highlight.parentNode.innerHTML.Substring($selectionIndex + 20 + $index, `
            $highlight.parentNode.innerHTML.IndexOf('</span>', $selectionIndex + $index) - $selectionIndex - 20 - $index)
        } 
        else 
        {
            $selection = $highlight.parentNode.innerHTML.Substring($selectionIndex + 20, `
            $highlight.parentNode.innerHTML.IndexOf('</span>') - $selectionIndex - 20)
        }
        
    }
    $text = $text.Insert($selectionIndex + $sentenceIndex, $character)
    $startIndex = $selectionIndex + $sentenceIndex + $selection.Length + 1
    if($selection.Substring($selection.Length - 1, 1) -eq " ") { $startIndex-- }
    $text = $text.Insert($startIndex, $character)
    $text
}

function Remove-Characters($string, $type) 
{
    if ($type -eq "selection") {$digit = "0-9"}
    $character = "[^A-za-z$digit!#$%&'()*+,./:;<=>?@\^_`{}~-]"
    while ($string -and $string.Substring(0, 1) -match $character) { $string = $string.Remove(0, 1) } 
    while ($string -and $string.Substring($string.Length - 1, 1) -match $character) { $string = $string.Remove($string.Length - 1, 1) } 
    if ($type -eq "question") { while ($string.Substring(0, 1) -match "[^A-Za-z]") { $string = $string.Remove(0, 1) } }
    while($string.Contains("  ")) { $string = $string.Replace("  ", " ") }
    $string 
}

function Update-SamplerXml () 
{
    
    $path = "$($projectPath.Substring(0, $projectPath.Length - 7))\sampler.xml"
    $content = Get-Content $path
    $content = $content -replace "$sets[0-9]*", "$sets$number"
    [xml]$xml = $content

    foreach ($section in $sections[0..1]) 
    {
        $xmlPrefix = "$projectPath\$sets$number\$section\$sets$number$($section.Chars(0))"
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
                    innerText = "$sets$number\$section\$sets$number$($section.Chars(0))$($i)Q$($node.TestItemName.Count).xml"
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
                [xml]$xml = Get-Content "$projectPath\$sets$number\$($sections[$i])\$sets$number$($sections[$i].Chars(0))$($j)Q$l.xml"
                
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
    $xmlFiles = Get-ChildItem "$projectPath\$sets$number\*.xml" -Recurse
    foreach ($xmlFile in $xmlFiles) 
    {
        [xml]$xml = Get-Content $xmlFile
        $node = (Select-Xml "/TestItem[@CLASS!='ssmc_simple']//LectureSound" $xml).Node
        if ($node) 
        { 
            if ($test) { $node.innerText = "Sampler\RLWlistn.wav" }
            else { $node.innerText = $xmlFile.FullName.Substring(60, $xmlFile.FullName.Length - 64) + ".wav" }
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
                $num = [int]$xmlFile.Name.Substring(6,1)
                $node.Attributes["TIMELIMIT"].Value = $time[0][[Math]::Ceiling($num / 2) - 1]
                $node.Attributes["PREPLIMIT"].Value = $time[1][[Math]::Ceiling($num / 2) - 1]
            }
        }

        $node = (Select-Xml "/TestItem[@CLASS='writelisten_paced']//miniPassageDuration" $xml).Node
        if ($node) 
        { 
            if ($test) { $node.innerText = "2" }
            else { $node.innerText = "180" }
        }
        $xml.Save($xmlFile.FullName) 
    }
}

function Get-Audio ($Uri, $AudioName) 
{
    if($Uri.Contains("speak") -and !$Uri.Contains("feedback"))
    {
        Invoke-WebRequest $Uri -OutFile "$PSScriptRoot\$sets$number.html"
        $html = Get-Content "$PSScriptRoot\$sets$number.html"
        foreach($line in $html)
        {
            $end = $line.IndexOf(".mp3") + 4
            $start = $line.IndexOf("https://tikustorage.oss-cn-hangzhou.aliyuncs.com")
            if($start -ne -1)
            {
                $link = $line.Substring($start,$end - $start)
                break
            }
        }
        Remove-Item "$PSScriptRoot\$sets$number.html"
    }
    else
    {
        $html = Invoke-WebRequest $Uri
        $document = $html.ParsedHtml.body

        $link = ""
        do 
        {
            $link = $document.getElementsByClassName("audio").item(0).src
        } until ($link)

        if($link.substring($link.length - 6,2) -notlike "*[_CLQ][0-9]*" -and $link.substring($link.length - 6,2) -notlike "*1[0-9]*") 
        {
            $AudioName = $AudioName.Insert(9,"R")
        }
    }

    $item = New-Object PSObject -Property `
    @{
        Audiolink = $link
        FileName  = $link.Split("/")[-1]
        AudioName = $AudioName            
    }
    $global:links += $item
    $links | Out-Null
    $link
}

function Get-Text ()
{
    $word = new-object -comobject word.application 
    $word.Visible = $false 
    $xmlFiles = Get-ChildItem "$projectPath\$sets$number\*.xml" -Recurse
    foreach ($xmlFile in $xmlFiles) 
    {
        $text = ""
        $content = Get-Content $xmlFile
        [xml]$xml = $content
        $node = (Select-Xml "//miniPassageText" $xml).Node
        if ($node) 
        { 
            $text += "Reading Text`n" + $node.innerText + "`n"
        }
        $node = (Select-Xml "//PassageText" $xml).Node
        if ($node) 
        { 
            $text += "Passage Text`n" + $node.innerText + "`n"
        }
        $node = (Select-Xml "//AudioText" $xml).Node
        if ($node) 
        { 
            $text += "Listening Text`n" + ($node.innerText -replace "\[.{8}\]", "" -replace (" " * 8), "") + "`n"
        }
        $node = (Select-Xml "//SampleResponse" $xml).Node
        if ($node) 
        { 
            if ($xmlFile.Name -like "*S[12].xml") 
            {
                $text += $node.ParentNode.Stem
            }
            $text += "Sample Response`n" + $node.innerText
        }
        $path = "$env:USERPROFILE\Downloads\$sets\$($xmlFile.Name.Substring(0,5))"
        New-Item $path -ItemType "Directory" -ErrorAction SilentlyContinue
        if($text) 
        { 
            $file = $word.Documents.Add()
            $file.Content = $text
            $file.SaveAs2("$path\$($xmlFile.Name.TrimEnd(".xml")).docx")
        }
    }
    $word.Quit() 
    [void][Runtime.Interopservices.Marshal]::ReleaseComObject($word)
}

function Get-Audios ()
{
    $n = [int]$number
    New-Item -Path "$($wavPath.TrimEnd('\*'))\$sets\$sets$($number)\" -ItemType "Directory" -ErrorAction SilentlyContinue
    if ($n -lt 35 -or $n -gt 39 -and $n -lt 50) 
    {
        $listening = Get-ChildItem "$jpgPath\tpo$($n)_listening_passage*.mp3"
        $speaking = Get-ChildItem "$jpgPath\tpo$($n)_speaking_question?_dialog.mp3"
        $writing = Get-ChildItem "$jpgPath\tpo$($n)_writing_question.mp3"
        
        for ($j = 0; $j -lt $listening.Count; $j++) 
        {
            Copy-Item $listening[$j].FullName "$($wavPath.TrimEnd('\*'))\$sets\$sets$($number)\$sets$($number)L$($j+1).mp3"
        }
        for ($j = 0; $j -lt $speaking.Count; $j++) 
        {
            Copy-Item $speaking[$j].FullName "$($wavPath.TrimEnd('\*'))\$sets\$sets$($number)\$sets$($number)S$($j+3).mp3"
        }
        Copy-Item $writing[0].FullName "$($wavPath.TrimEnd('\*'))\$sets\$sets$($number)\$sets$($number)W1.mp3"
    }
    else 
    {
        (Get-ChildItem "$HOME\Downloads\Music\$sets$($number)??.mp3").foreach{
            Copy-Item -Path $_.FullName -Destination "$($wavPath.TrimEnd('\*'))\$sets\$sets$($number)\$($_.Name)"
        }
    }
}

function Get-QuestionAudio () 
{
    if(Get-Content "$PSScriptRoot\$sets$number-AudioLinks.csv" -ErrorAction SilentlyContinue ) 
    { 
        $links = Import-Csv "$PSScriptRoot\$sets$number-AudioLinks.csv"
        $links.Audiolink | ForEach-Object  `
        {
            $_.Replace("?????", "%EF%BC%88%E9%87%8D%E5%90%AC%E9%A2%98%EF%BC%89") `
            -replace "\?\?\?", "%E9%87%8D%E5%90%AC%E9%A2%98" -replace "\?\?", "%E9%87%8D%E5%A4%8D"
        } | Set-Clipboard
        $links | ForEach-Object `
        {
            Copy-Item -Path "$env:USERPROFILE\Downloads\Music\$($_.FileName.Replace("?",'-').Replace("%20",' '))" -Destination "$env:USERPROFILE\Music\$($_.AudioName)"
        }
        return 
    }
    $html = Invoke-WebRequest "$website/listen/$location.html"
    $test = $html.ParsedHtml.body.getElementsByClassName("div") | `
    ForEach-Object {if($_.className -eq "title" -and $_.innerText.split(" ")[0] -eq "$sets$([int]$number)"){$_}} 
    $total = $test.nextSibling.nextSibling.GetElementsByTagName("span") | ForEach-Object {if($_.className -eq "total"){$_}}

    $articles = @()
    foreach ($item in $total) 
    {
        $articles += "$($item.previousSibling.previousSibling.id.split("-")[1]),$($item.innerText)"
    }

    for ($i = 0; $i -lt $articles.Count; $i++) 
    {
        $article = $articles[$i].split(",")[0]
        "$sets$($number)L$($i+1).mp3"
        Get-Audio "$website/listen/review-$article-13.html" "$sets$($number)L$($i+1).mp3" | Out-Null
        for ($j = 1; $j -le [int]$articles[$i].split(",")[1]; $j++) 
        {
            "$sets$($number)L$($i+1)Q$j.mp3"
            $link = Get-Audio "$website/listen/answer.html?scenario=13&article_id=$article&seqno=$j" "$sets$($number)L$($i+1)Q$j.mp3"

            if($link.substring($link.length - 6,2) -notlike "*[_CLQ][0-9]*" -and $link.substring($link.length - 6,2) -notlike "*1[0-9]*")
            {
                "$sets$($number)L$($i+1)Q$($j)R.mp3"
                Get-Audio "$website/listen/answer.html?scenario=13&step=2&article_id=$article&seqno=$j" "$sets$($number)L$($i+1)Q$j.mp3" | Out-Null
            }
        }
    }
    $html = Invoke-WebRequest "$website/speak/$location.html"
    $test = $html.ParsedHtml.body.getElementsByClassName("div") | `
    ForEach-Object {if($_.className -eq "title" -and $_.innerText.split(" ")[0] -eq "$sets$number"){$_}} 
    $articles = $test.nextSibling.nextSibling.GetElementsByTagName("div") | ForEach-Object { foreach($attribute in $_.Attributes){ if($attribute.Name -eq "data-id") {$attribute.textContent } } }
    for ($i = 0; $i -lt $articles.Count; $i++) 
    {
        if ($i -ne 0 -and $i -ne 1) 
        {
            "$sets$($number)S$($i+1).mp3"
            Get-Audio "$website/speak/feedback-$($articles[$i])-13.html" "$sets$($number)S$($i+1).mp3" | Out-Null
        }

        if ($i -eq 2 -or $i -eq 3) 
        {
            "$sets$($number)S$($i+1)P.mp3"
            Get-Audio "$website/speak/start-$($articles[$i])-13.html?step=getpaper" ("$sets$($number)S$($i+1)P.mp3") | Out-Null
        }
        "$sets$($number)S$($i+1)Q.mp3"
        Get-Audio "$website/speak/start-$($articles[$i])-13.html?step=getquestion" ("$sets$($number)S$($i+1)Q.mp3") | Out-Null
    }

    $html = Invoke-WebRequest "$website/write/$location.html"
    $test = $html.ParsedHtml.body.getElementsByClassName("div") | `
    ForEach-Object {if($_.className -eq "title" -and $_.innerText.split(" ")[0] -eq "$sets$number"){$_}} 
    $articles = $test.nextSibling.nextSibling.GetElementsByTagName("div") | ForEach-Object { foreach($attribute in $_.Attributes){ if($attribute.Name -eq "data-id") {$attribute.textContent } } }
    "$sets$($number)W1.mp3"
    Get-Audio "$website/write/practice-review.html?article_id=$($articles[0])" "$sets$($number)W1.mp3" | Out-Null

    $links | Export-Csv "$PSScriptRoot\$sets$number-AudioLinks.csv"
    $links = Import-Csv "$PSScriptRoot\$sets$number-AudioLinks.csv"
    $links.Audiolink | ForEach-Object  {
        $_.Replace("?????", "%EF%BC%88%E9%87%8D%E5%90%AC%E9%A2%98%EF%BC%89") -replace "\?\?", "%E9%87%8D%E5%A4%8D"
    } | Set-Clipboard
}

function Get-Resources()
{
    $xmlFiles = Get-ChildItem "$projectPath\$sets$number\*.xml" -Recurse
    foreach ($xmlFile in $xmlFiles) 
    {
        $content = Get-Content $xmlFile
        [xml]$xml = $content
        $node = (Select-Xml "/TestItem[@CLASS!='lecture']//AudioText" $xml).Node
        if ($node) 
        { 
            $path = "$env:USERPROFILE\Downloads\Documents\$($xmlFile.Name.TrimEnd(".xml")).txt"
            if (Test-Path $path)
            {
                $text = ""
                foreach($line in (Get-Content $path) )
                {
                    $text += $line + "`n"
                }
                $node.innerText = Format-Paragraphs $text
            }
        }
        $node = (Select-Xml "//LecturePicture" $xml).Node
        if ($node) 
        { 
            $path = "$imagePath\$($node.innerText.Split("\\")[-1])"
            if (Test-Path $path)
            {
                Copy-Item $path "$projectPath\$filePath.jpg"
            }
        }
        
        $xml.Save($xmlFile.FullName) 
    }
}

function Get-Reading() {
    $section = $MyInvocation.MyCommand.Name.Split("-")[1]
    $letter = $section.substring(0, 1)
    $prefix = "$sets$number\$section\$sets$number$letter"
    New-Item -Path "$projectPath\$sets$number\$section" -ItemType "Directory" -ErrorAction SilentlyContinue  | Out-Null
    
    $type = $section.Remove($section.Length - 3, 3).ToLower()
    $html = Invoke-WebRequest "$website/$type/$location.html"

    # Get 3 Passage question number 
    foreach ($item in $html.ParsedHtml.body.getElementsByClassName("title")) {
        if($item.innerText -like "*$sets$([int]$number)*") { $test = $item }
    }

    # Get question number 14 14 14
    $articles = @()
    foreach ($item in $test.nextSibling.nextSibling.GetElementsByClassName("total")) {
        $articles += "$($item.previousSibling.previousSibling.id.split("-")[1]),$($item.innerText)"
    }

    for ($i = 1; $i -le $articles.Count; $i++) {
        $article = $articles[$i-1].split(",")[0]
        "$sets$number$letter$i"
        $filePath = "$prefix$i"
        $html = Invoke-WebRequest "$website/$type/practicereview-$article-13.html"

        # Create passage xml and text
        $text = $html.ParsedHtml.body.getElementsByClassName("article")[0].innerText
        $title = $html.ParsedHtml.body.getElementsByClassName("article_tit")[0].innerText

        $text = Format-Paragraphs $text 
        $xml = Add-XmlTestItemNode @{CLASS = "view_this_passage_noquest"}
        Add-XmlChildNodes $xml @("TPPassage", "Title", "PassageText") @("$filePath.txt", $title, $text)
        New-File $xml "$projectPath\$filePath.xml"

        
        $text = $text.Insert(0, "}")
        $text = $text.Insert($text.IndexOf("`n"), "}")
        $text = $text.Insert(0, " " * (60 - [int]($title.Length/2) ) )
        $text = $text.Replace("[", "(")
        $text = $text.Replace("]", ")")
        New-File $text "$projectPath\$filePath.txt"

        <#
        for ($j = 1; $j -le [int]$articles[$i-1].split(",")[1]; $j++) {
            # Add question passage text file
            if ($j -lt 10) {$k = "0$j"} else {$k = $j}
            "$sets$($number)$letter$($i)Q$k"
            $filePath = "$prefix$($i)Q$k"
            $names = @("TPPassage")
            $nodes = @("$filePath.txt")
            
            # Add scroll line element if the question number is large
            $names += "TPTopScrollLine"
            $nodes += ([int](($j - 1) * 2.5)).ToString()

            $xml = Add-XmlTestItemNode @{CLASS = "passage_ssmc"}

            # Question Text
            $html = Invoke-WebRequest "$website/$type/practicereview-$article-13.html?index=$($j-1)"
            $text = $html.ParsedHtml.body.getElementsByClassName("article")[0]
            $passageText = $text.innerText
            $passageText = Format-Paragraphs $passageText 

            $title = $html.ParsedHtml.body.getElementsByClassName("article_tit").innerText
            $passageText = $passageText.Insert(0, "}")
            $passageText = $passageText.Insert($passageText.IndexOf("`n"), "}")
            $passageText = $passageText.Insert(0, " " * (60 - [int]($title.Length/2) ) )
            $passageText = $passageText.Replace("[", "(")
            $passageText = $passageText.Replace("]", ")")

            $questionText = $html.ParsedHtml.body.getElementsByClassName("q_tit")[0]

            # Add paragraph mark and paragraph element if question text has "(P|p)aragraph 2" or "paragraphs 3 and 4" 
            $match = ($questionText.innerText | Select-String "aragraphs? ?(?<Paragraph1>[0-9])( and (?<Paragraph2>[0-9]))?").Matches
            if ($match) 
            {
                $names += "Paragraph"
                $paragraphs = $match[0].Groups["Paragraph1"].Value
                $indexes = Get-AllIndexesOf $passageText ("`n" + " " * 8)
                $passageText = $passageText.Insert($indexes[[int]$paragraphs - 1] + 1, "^6")
                $paragraph2 = $match[0].Groups["Paragraph2"].Value
                if ($paragraph2) 
                {
                    $passageText = $passageText.Insert($indexes[[int]$paragraph2 - 1] + 3, "^6")
                    $paragraphs += " and $paragraph2"
                }
                $nodes += $paragraphs
            }
 
            # highlighted Question
            $startIndexes = Get-AllIndexesOf $text.innerHTML '<span class="light">'
            
            for($k = 0; $k -lt $startIndexes.Count; $k++)
            {
                $highlight = $text.getElementsByClassName("light")
                $passageText = Add-Shading $passageText $highlight "["
                
                $match = ($questionText.innerHTML | Select-String '<span class="light">(?<highlight>.*)</span>').Matches
                if ($match) 
                {
                    $highlight = $questionText.getElementsByClassName("light")
                    $questionText = Add-Shading $questionText.innerText $highlight "|"
                }
            }
            if($questionText.innerText) { $questionText = $questionText.innerText }
            
            # Insert Text Question
            $index = $questionText.IndexOf("[")
            if ($index -ne -1) 
            {
                $xml.TestItem.CLASS = "passage_insertText"

                # Add question sauare
                $questionText = $questionText -replace "\[.*\]", "[]"
                $questionText = $questionText.Insert($index + 1, " |    | ")

                # Add passage square 
                $highlights = $text.getElementsByClassName("insert-area").parentNode.innerText
                for ($k = 0; $k -lt $highlights.Count; $k++) 
                {
                    $indexes = Get-AllIndexesOf (Remove-Characters $highlights[$k]) "["
                    $sentence = Remove-Characters $highlights[$k].Replace("[","(").Replace("]",")")

                    $startPosition = $passageText.IndexOf($sentence)
                    if ($indexes.Count -gt 1) # 2 squares in one sentence
                    {
                        $passageText = $passageText.Remove($startPosition, 3)
                        $passageText = $passageText.Remove($startPosition + $indexes[1] - 3, 3)
                        $passageText = $passageText.Insert($startPosition + $indexes[1] - 3, " |]    ]| ")
                        $passageText = $passageText.Insert($startPosition, " |]    ]| ")
                        $k++
                    }
                    else # square in start 
                    {
                        $passageText = $passageText.Remove($startPosition + $indexes, 3)
                        $passageText = $passageText.Insert($startPosition + $indexes, " |]    ]| ")
                    }
                }
            }

            # Add question text node
            $names += "Stem"
            $nodes += Remove-Characters $questionText "question"
            Add-XmlChildNodes $xml $names $nodes

            # Draggy question
            if ($questionText.Contains("points.")) # Draggy question
            {
                Add-XmlNodes $xml $xml.FirstChild @{Name = "TPviewtext"; Attributes = @{PASSAGE = "$filePath.txt"}} | Out-Null
                
                $names = "tpFont", "QuestBmp"
                $nodes = "Arial,12,0", "$filePath.bmp"
                Add-XmlChildNodes $xml $names $nodes
    
                # Options and Answers location 
                $xCoordinates = "540", "45"
                $yCoordinates = "570"
                $bucketNames = "tpBucket", "tpBucket", "tpBucket"

                if ($questionText.Contains("brief summary")) 
                {
                    $xml.TestItem.CLASS = "draggy"
                    #Copy-Item "$projectPath\Sampler\draggy.bmp" "$projectPath\$filePath.bmp"
    
                    $bucketNodes = "300,320", "300,400", "300,480"
                }
                else 
                {
                    $xml.TestItem.CLASS = "draggy_table"
                    #Copy-Item "$projectPath\Sampler\draggy_table.bmp" "$projectPath\$filePath.bmp"
    
                    $bucketNodes = "410,300", "410,350", "410,430", "410,480", "410,530"
                    $bucketNames += "tpBucket", "tpBucket", "tpBucket", "tpBucket"
                }    
            }
            
            # Options
            $names = @()
            $nodes = @()
            $options = $html.ParsedHtml.body.getElementsByClassName("ops").innerText
            if ($questionText.Contains("points.")) # Draggy question
            {
                for($k = 1; $k -le $options.Count; $k++)
                {
                    $names += "tpObject"
                    if ($questionText.Contains("brief summary"))
                    {
                        $step = 75
                    }
                    else 
                    {
                        $step = 45
                    }
                    $coordinates = "$($xCoordinates[$k % 2]),$([int]$yCoordinates + $step * ([Math]::Ceiling($k / 2) - 1))"
                    $nodes += "$coordinates,450,0,$(Remove-Characters ($options[$k-1] -replace "[A-I]\.", '') "selection")"
                    $bucketNames += "tpBucket"
                    $bucketNodes += $coordinates
                }
            }
            else 
            {
                foreach($option in $options)
                {
                    $names += "Distractor"
                    $nodes += Remove-Characters ($option -replace "[A-I]\. ", "") "selection"
                }

                Add-XmlChildNodes $xml $names $nodes "Distractor_list"
            }
            

            # Add Draggy Question Summary or category
            if ($questionText.Contains("points.")) # Draggy question
            {
                $index = $questionText.IndexOf("brief summary") + 15
                if ($index -ne 14)
                {
                    $summary = $questionText
                    $sentence = " Drag your answer choices to the space where they belong. To remove an answer choice, double click on it. "
                    if ($questionText.IndexOf($sentence) -ne -1) 
                    {
                        $summary = $questionText.Remove($questionText.IndexOf($sentence), $sentence.Length)
                    }
                    $summary = $summary.Remove(0, $index)
                    $names += "tpObject"
                    $nodes += "150,240,800,0,$(Remove-Characters $summary)"
                }
                else 
                {
                    $category = $html.ParsedHtml.body.getElementsByClassName("grouptext").innerText
                    $questionText = $questionText.Remove(0, $questionText.IndexOf("Directions") + "Directions".Length + 2)
                    $index = $category.IndexOf("ANSWER CHOICE")
                    $category = if($index -ne -1) { $category[0..($index-1)] }
                    
                    $index = $questionText.IndexOf($category[1].Split(" ")[0].ToLower())
                    if($index -eq -1) { $index = $questionText.IndexOf($category[1].Split(" ")[0]) }
                    if($questionText.Substring(0, $index).Contains("two"))
                    {
                        [Array]::Reverse($category)
                    }
                    for($k = 0; $k -lt $category.Count; $k++)
                    {
                        $nodes += "160,$(280 + $k * 140),800,0,$($category[$k])"
                    }
                    $names += "tpObject", "tpObject", "tpObject"
                    $nodes += "200,140,700,0,$(Remove-Characters $questionText)"
                }
                Add-XmlChildNodes $xml $names $nodes "tpObject_list"
                Add-XmlChildNodes $xml $bucketNames $bucketNodes "tpBucket_list"
            }

            # Key
            $answer = $html.ParsedHtml.body.getElementsByClassName("left correctAnswer").innerHTML
            $start = $answer.IndexOf("<span>") + 6
            $end = $answer.IndexOf("</span>")
            $answers = $answer.Substring($start, $end - $start)
            
            $keys = ""
            foreach($answer in $answers.ToCharArray())
            {
                if([int][char]$answer -lt 60 -or [int][char]$answer -gt 80) 
                { 
                    $keys += "0" 
                }
                else
                {
                    $keys += ([int][char]$answer - 64).ToString()
                }
            }
            Add-XmlChildNodes $xml @("Key") @($keys)

            # Add draggy question special answer
            if ($questionText.Contains("points.")) # Draggy question
            {
                if ($questionText.Contains("brief summary")) 
                {
                    $answers = "1234567"
                    for ($k = 0; $k -lt $keys.Length; $k++) 
                    {
                        $answers = $answers.Remove([int]$keys.Chars($k).ToString() - 1, 1)
                        $answers = $answers.Insert([int]$keys.Chars($k).ToString() - 1, "0")
                    }
                }
                else 
                {
                    $pairs = $keys -split "0"
                    $answers = "123456789"
                    $keys = "00000"
                    foreach($pair in $pairs)
                    {
                        if($pair.Length -lt 3) 
                        {
                            for ($l = 0; $l -lt $pair.Length; $l++) 
                            {
                                $answers = $answers.Remove([int]$pair[$l].ToString() - 1, 1)
                                $answers = $answers.Insert([int]$pair[$l].ToString() - 1, "0")
                                $keys = $keys.Remove($l, 1)
                                $keys = $keys.Insert($l, $pair[$l])
                            }
                        }
                        else 
                        {
                            for ($l = 0; $l -lt $pair.Length; $l++) 
                            {
                                $answers = $answers.Remove([int]$pair[$l].ToString() - 1, 1)
                                $answers = $answers.Insert([int]$pair[$l].ToString() - 1, "0")
                                $keys = $keys.Remove($l+2, 1)
                                $keys = $keys.Insert($l+2, $pair[$l])
                            }
                        }
                    }
                }

                $answers = $keys + $answers
                $keys = ""
                for ($k = 0; $k -lt $answers.Length; $k++) 
                {
                    $keys += $answers.Chars($k).ToString() + ","
                }
                Add-XmlChildNodes $xml @("specialShowAnswer") @($keys)
            }
    
            New-File $xml "$projectPath\$filePath.xml" 
            New-File $passageText "$projectPath\$filePath.txt"
        }
        #>
    }
    
}

function Get-Listening() {
    $section = $MyInvocation.MyCommand.Name.Split("-")[1]
    $letter = $section.Substring(0, 1)

    $prefix = "$sets$number\$section\$sets$number$letter"
    New-Item -Path "$projectPath\$sets$number\$section" -ItemType "Directory" -ErrorAction SilentlyContinue  | Out-Null
    
    $type = $section.Remove($section.Length - 3, 3).ToLower()
    $html = Invoke-WebRequest "$website/$type/$location.html"

    # Get 3 Passage question number 
    foreach ($item in $html.ParsedHtml.body.getElementsByClassName("title")) {
        if($item.innerText -like "*$sets$([int]$number)*") { $test = $item }
    }

    # Get question number 14 14 14
    $articles = @()
    foreach ($item in $test.nextSibling.nextSibling.GetElementsByClassName("total")) {
        $articles += "$($item.previousSibling.previousSibling.id.split("-")[1]),$($item.innerText)"
    }

    if (!$isNew) 
    {
        $wavFiles = Get-ChildItem $wavPath -Include "$sets$([int]$number)_$section*.wav"
    }
    $questionNumber = 0

    for ($i = 1; $i -le $articles.Count; $i++) 
    {
        
        $article = $articles[$i-1].split(",")[0]
        "$sets$number$letter$i"
        $filePath = "$prefix$i"
        $html = Invoke-WebRequest "$website/$type/review-$article-13.html" 

        $questions = @()
        foreach ($item in $html.ParsedHtml.body.getElementsByClassName("undone")) {
            $questions += "$website$($item.parentNode.href.Remove(0,12))"
        }

        # Create passage xml
        $text = $html.ParsedHtml.body.getElementsByClassName("article")[0].innerText 
        $xml = Add-XmlTestItemNode @{CLASS = "lecture"}
        $text = Format-Paragraphs $text
        $names = "LecturePicture", "LectureSound", "LecturePicture", "AudioText"
        $nodes = "$filePath.jpg", "$filePath.wav", "Sampler\GetReady.gif", $text
        Add-XmlChildNodes $xml $names $nodes
        New-File $xml "$projectPath\$filePath.xml"

        <#
        # Copy wav and jpg files
        if ($isNew) 
        {
            #Copy-Item "$($wavPath.TrimEnd("\*"))\$($filePath.Split("\")[-1]).wav" "$projectPath\$filePath.wav"
        }
        else 
        {
            $wavSet = "$([Math]::Ceiling($i/3))"
            $passageNumber = if ($i % 3 -eq 0) {3} else {$i % 3}
            Copy-ResourceItem "*passage$($wavSet)_$passageNumber.wav" "$projectPath\$filePath.wav" $wavFiles
        }
        
        for ($j = 1; $j -le [int]$articles[$i-1].split(",")[1]; $j++) 
        {
            $questionNumber++
            "$sets$($number)$($section.Substring(0,1))$($i)Q$j"
            $filePath = "$prefix$($i)Q$j"
            $audioPath = "$projectPath\$($filePath)R.wav"

            if ($isNew) 
            {
                if(Test-Path "$($wavPath.TrimEnd("\*"))\$($filePath.Split("\")[-1])R.wav")
                { #Copy-Item "$($wavPath.TrimEnd("\*"))\$($filePath.Split("\")[-1])R.wav" $audioPath }
            }
            else 
            {
                $questionSet = if ($questionNumber % 17 -eq 0) {17} else {$questionNumber % 17}
                Copy-ResourceItem "*repeat$($wavSet)_$questionSet.wav" $audioPath $wavFiles
                Copy-ResourceItem "*question$($wavSet)_$questionSet*" "$projectPath\$filePath.wav" $wavFiles
            }
            $xml = Add-XmlTestItemNode @{CLASS = "ssmc_simple"}

            if (Test-Path $audioPath) 
            {
                "$sets$($number)$($section.Substring(0,1))$($i)Q$($j)R"
                $names = "LecturePicture", "LectureSound"
                $nodes = "Sampler\RplayLec.gif", "$($filePath)R.wav"
                Add-XmlChildNodes $xml $names $nodes "miniLecture"
            }

            # question Text
            $html = Invoke-WebRequest "$($questions[$j-1])"
            $questionText = $html.ParsedHtml.body.getElementsByClassName("div") | ForEach-Object {if($_.className -eq "q_tit"){$_.innerText}} 
            $names = "Stem", "StemWav"
            $nodes = (Remove-Characters $questionText "question"), "$filePath.wav"
            Add-XmlChildNodes $xml $names $nodes

            $names = @()
            $nodes = @()
            $options = $html.ParsedHtml.body.getElementsByClassName("p") | ForEach-Object {if($_.className -like "ops *"){$_.innerText}}
            foreach($option in $options)
            {
                $names += "Distractor"
                $nodes += Remove-Characters ($option -replace "[A-I]\. ", "") "selection"
            }
            Add-XmlChildNodes $xml $names $nodes "Distractor_list"

            # Key
            $answer = $html.ParsedHtml.body.getElementsByClassName("div") | `
            ForEach-Object {if($_.className -eq "left correctAnswer"){$_.innerHTML}}
            $start = $answer.IndexOf("<span>") + 6
            $end = $answer.IndexOf("</span>")
            $answers = $answer.Substring($start, $end - $start)
            
            $keys = ""
            foreach($answer in $answers.ToCharArray())
            {
                $keys += ([int][char]$answer - 64).ToString()
            }
            Add-XmlChildNodes $xml @("Key") @($keys)

            New-File $xml "$projectPath\$filePath.xml" 
        }
        #>
    }

}

function Get-Speaking() {
    $section = $MyInvocation.MyCommand.Name.Split("-")[1]
    $letter = $section.Substring(0, 1)

    $prefix = "$sets$number\$section\$sets$number$letter"
    New-Item -Path "$projectPath\$sets$number\$section" -ItemType "Directory" -ErrorAction SilentlyContinue  | Out-Null

    $type = $section.Remove($section.Length - 3, 3).ToLower()
    $html = Invoke-WebRequest "$website/$type/$location.html"

    # Get 3 Passage question number 
    foreach ($item in $html.ParsedHtml.body.getElementsByClassName("title")) {
        if($item.innerText -like "*$sets$([int]$number)*") { $test = $item }
    }

    $articles = @()
    foreach ($item in $test.nextSibling.nextSibling.getElementsByClassName("tpo_talking_item")) { $articles += $item.id.split("-")[1] }

    # Get-Audio 
    #$wavFiles = Get-ChildItem $wavPath -Include "$sets$([int]$number)_$section*.wav"

    for ($i = 1; $i -le $articles.Count; $i++) 
    {
        "$sets$($number)$($section.Substring(0,1))$i"
        $filePath = "$prefix$i"
        $xml = Add-XmlTestItemNode `
        @{
            CLASS          = "speaking_paced"; 
            TIMELIMIT      = $time[0][[Math]::Ceiling($i / 2) - 1]; 
            PREPLIMIT      = $time[1][[Math]::Ceiling($i / 2) - 1]; 
            SHOWDIRECTIONS = "FALSE"
        }
        
        $html = Invoke-WebRequest "$website/speak/feedback-$($articles[$i-1])-13.html" 

        if ($i -ne 1 -and $i -ne 2) 
        {
            if ($i -eq 3 -or $i -eq 4) 
            {
                #Copy-Item "$($wavPath.TrimEnd("\*"))\$($filePath.Split("\")[-1])P.wav" "$projectPath\$($filePath)P.wav"

                $title = $html.ParsedHtml.body.getElementsByClassName("article_tit")[0].innerText 
                $article = $html.ParsedHtml.body.getElementsByClassName("article")[0].innerText
                
                $names = "miniPassageIntroSound", "miniPassageIntroPic", "miniPassageDuration", "miniPassageTitle", "miniPassageText"
                $nodes = "$($filePath)P.wav", "Sampler\headphon.jpg", 45, $title, $article
                Add-XmlChildNodes $xml $names $nodes "miniPassage"     
            }

            #Copy-Item "$($wavPath.TrimEnd("\*"))\$($filePath.Split("\")[-1]).wav" "$projectPath\$filePath.wav" 
            
            $names = "LecturePicture", "LectureSound", "LecturePicture"
            $nodes = "$filePath.jpg", "$filePath.wav", "Sampler\SGetReady.gif"
            Add-XmlChildNodes $xml $names $nodes "miniLecture"

            Add-XmlNodes $xml $xml.FirstChild `
            @{
                Name      = "AudioText";
                innerText = $html.ParsedHtml.body.getElementsByClassName("audio_topic")[0].innerText
            } | Out-Null

            # question text
            $text = $html.ParsedHtml.body.getElementsByClassName("article ques")[0].innerText
        }
        else # independent speaking
        {
            # question text
            $text = $html.ParsedHtml.body.getElementsByClassName("article")[0].innerText
            if (!$text) { $text = $html.ParsedHtml.body.getElementsByClassName("article")[0].nextSibling.innerText }
        }

        #Copy-Item "$($wavPath.TrimEnd("\*"))\$($filePath.Split("\")[-1])Q.wav" "$projectPath\$($filePath)Q.wav"

        $sampleText = $html.ParsedHtml.body.getElementsByClassName("ansart")[0].innerText

        $names = "Stem", "StemWav", "SampleResponse"
        $nodes = `
        @( 
            (Remove-Characters $text),
            "$($filePath)Q.wav",
            (Remove-Characters $sampleText)
        )
        Add-XmlChildNodes $xml $names $nodes 
        New-File $xml "$projectPath\$filePath.xml"
    }
}

function Get-Writing () {
    $section = $MyInvocation.MyCommand.Name.Split("-")[1]
    $letter = $section.Substring(0, 1)
    $prefix = "$sets$number\$section\$sets$number$letter"
    New-Item -Path "$projectPath\$sets$number\$section" -ItemType "Directory" -ErrorAction SilentlyContinue  | Out-Null

    $html = Invoke-WebRequest "$website/write/$location.html"

    # Get 3 Passage question number 
    foreach ($item in $html.ParsedHtml.body.getElementsByClassName("title")) {
        if($item.innerText -like "*$sets$([int]$number)*") { $test = $item }
    }

    $articles = @()
    foreach ($item in $test.nextSibling.nextSibling.getElementsByClassName("tpo_talking_item")) { $articles += $item.id.split("-")[1] }

    for ($i = 1; $i -le $articles.Count; $i++) 
    {
        "$sets$($number)$($section.Substring(0,1))$i"
        $filePath = "$prefix$i"
        $html = Invoke-WebRequest "$website/write/practice-review.html?article_id=$($articles[$i-1])&write_type=$i"
        if ($i -eq 1) # Integrated Writing Xml 
        {
            $xml = Add-XmlTestItemNode @{CLASS = "writelisten_paced"; TIMELIMIT = "20"; SHOWDIRECTIONS = "FALSE"} 
            $text = $html.ParsedHtml.body.getElementsByClassName("article")[0].innerText 
            if (!$text) 
            { $text = $html.ParsedHtml.body.getElementsByClassName("article")[0].nextSibling.innerText }
            $names = "miniPassageDuration", "miniPassageText"
            $nodes = 180, (Format-Paragraphs $text)
            Add-XmlChildNodes $xml $names $nodes "miniPassage"
        
            # Get Audio
            #Copy-Item "$($wavPath.TrimEnd("\*"))\$sets$([int]$number)_$($section)_question.wav" "$projectPath\$filePath.wav"
            
            $names = "LecturePicture", "LectureSound", "LecturePicture"
            $nodes = "$filePath.jpg", "$filePath.wav", "Sampler\WGetReady.gif"
            Add-XmlChildNodes $xml $names $nodes "miniLecture"
        
            $names = "AudioText", "Stem", "StemWav"
            $nodes = `
            @(
                $html.ParsedHtml.body.getElementsByClassName("audio_topic")[0].innerText,
                "Summarize the points made in the lecture, being sure to explain how they oppose specific points made in the reading passage.",
                "Sampler\SAWQ.wav"
            )  

        }
        else # Independent Writing Xml
        {
            $xml = Add-XmlTestItemNode @{CLASS = "independentwriting_paced"; TIMELIMIT = "30"}
            $questionText = $text = $html.ParsedHtml.body.getElementsByClassName("article")[0].innerText
            # Question
            $names = @("Stem") 
            $nodes = @($questionText) 
        }

        $sampleText = $html.ParsedHtml.body.getElementsByClassName("noedit fanwen")[0].innerText

        $names += "SampleResponse"
        $nodes += Format-Paragraphs $sampleText

        Add-XmlChildNodes $xml $names $nodes
        New-File $xml "$projectPath\$filePath.xml"
    }
}

$global:links = @()
$global:sets = "TPO"
$global:website = "https://top.zhan.com/toefl"
$global:sections = "Reading", "Listening", "Speaking", "Writing"
$global:projectPath = "$env:USERPROFILE\Downloads\ETS\TOEFL Programs\Sampler\forml1"
$global:wavPath = "$env:USERPROFILE\Music\*"
$global:jpgPath = "$env:USERPROFILE\Downloads\ETS\TOEFL Programs\$sets\resources\cache\*"
$global:imagePath = "$env:USERPROFILE\Pictures\*"
$global:time = @("45", "60", "60"), @("15", "30", "20")

for ($n = 52; $n -le 53; $n++) 
{
    $global:number = $n
    $global:tpos = if($number % 4 -eq 0) {"$number"} 
    else {"$($number - $number % 4 + 4)"}
    if ($sets -eq "TPO") { $location = "alltpo$tpos" } else { $location = $sets.ToLower()}
    if ($number -lt 10) {$number = "0$number"}
    #New-Item -Path "$projectPath\$sets$number\" -ItemType "Directory" -ErrorAction SilentlyContinue
    
    #Get-QuestionAudio
    Get-Reading
    #Get-Listening 
    #Get-Speaking 
    #Get-Writing
    #Update-SamplerXml 
    #Update-Audio #"test"
    #Get-Resources
    #Get-Text
    #Get-Audios
}
<#
(Get-ChildItem "$env:USERPROFILE\Downloads\$sets\*.txt" -Recurse).foreach{
    $content = Get-Content $_.FullName
    Set-Content $_.FullName $content #-Encoding "UTF8"
}
(Get-ChildItem "$env:USERPROFILE\Pictures\*.jpg").foreach{ 
    #Resize-Image -InputFile $_ -OutputFile ("$env:USERPROFILE\Pictures\Feedback\"+$_.Name) -Width 600 -Height 450
}
#>

 