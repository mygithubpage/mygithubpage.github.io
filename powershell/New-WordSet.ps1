. $PSScriptRoot\Utility.ps1

# Get Vocabulary 



<#
    $msWord = New-Object -ComObject Word.Application 
    $docx = (Get-ChildItem "$env:USERPROFILE\Documents\*.docx")[0]
    $name = $docx.BaseName
    $file = $msWord.Documents.Open($docx.FullName)

    foreach ($sentence in $file.Content.Sentences) {
        foreach($word in $sentence.Words) {
            if($word.UnderLine -ne 1) { continue } # wdUnderlineSingle

            $string = $word.Text
            $string = [regex]::Replace($string, "\u00A0", " ")
            $string
            while($string.EndsWith(" ")) { $string = $string.TrimEnd(" ") }
            $sentence = $sentence.Text.Replace($string, "_" * $string.Length) 
            $sentence = [regex]::Replace($sentence, "\u00A0", " ")
            
            function Get-Definition ($string, $sentence) {
                $uri = "https://www.thefreedictionary.com/" + $string
                $html = Invoke-WebRequest $uri
                $document = $html.ParsedHtml.body
                
                $definition = ""
                $definitions = $document.getElementsByClassName("pseg")
                for ($i = 0; $definitions[$i].parentNode.id -eq "Definition"; $i++) {
                    $definitions[$i].getElementsByClassName("ds-list") | ForEach-Object { $definition += $_.outerHtml }
                    $definitions[$i].getElementsByClassName("ds-single") | ForEach-Object { $definition += $_.outerHtml }
                }

                $synonyms = ""
                foreach ($item in $document.getElementsByClassName("Syn")) {
                    if($item.tagName -ne "span" -or $item.innerText.IndexOf(",") -lt 0) { continue }
                    $synonyms += $item.parentNode.outerHtml
                }
                if (!$synonyms) {
                    for ($i = 1; $i -lt $document.getElementsByClassName("Syn").Length; $i++) {
                        $synonyms += $document.getElementsByClassName("Syn")[$i].outerHtml
                    }
                }

                $pronuciation = $document.getElementsByClassName("snd2")[0].getAttribute("data-snd")
                $sound = "http://img2.tfd.com/pron/mp3/$pronuciation.mp3"
                $pronuciation = $document.getElementsByClassName("snd")[0]
                if($pronuciation) { 
                    $pronuciation = $pronuciation.getAttribute("data-snd")
                    $sound += ",http://img.tfd.com/hm/mp3/$pronuciation.mp3" 
                }
                $definition, $synonyms, $sound
            }

            function Get-Oxford ($string) {
                $uri = "https://en.oxforddictionaries.com/definition/us/" + $string
                $html = Invoke-WebRequest $uri
                $document = $html.ParsedHtml.body
                
                $definition = ""
                foreach ($item in $document.getElementsByClassName("ind")) {
                    $definition += "<p>$($item.outerHtml)</p>"
                }

                $examples = @()
                foreach ($example in $document.getElementsByClassName("examples")) {
                    foreach($item in $example.getElementsByClassName("ex")) {
                        $examples += "<p>$($item.innerText.Substring(1,$item.innerText.Length -2))</p>"
                    }
                }
                $example = ""
                $examples | Sort-Object { $_.Length } | Select-Object -Last 5 | Foreach-Object { $example += $_ }

                $synonyms = ""
                foreach ($item in $document.getElementsByClassName("exs")) {
                    $synonyms += "<p>$($item.outerHtml)</p>"
                }

                $sound = $document.getElementsByClassName("speaker")[0].ChildNodes[0].src

                <#
                
                    $uri = "https://www.thefreedictionary.com/" + $string
                    $html = Invoke-WebRequest $uri
                    $document = $html.ParsedHtml.body
                    $pronuciation = $document.getElementsByClassName("snd2")[0].getAttribute("data-snd")
                    $sound += ",http://img2.tfd.com/pron/mp3/$pronuciation.mp3"
                    $pronuciation = $document.getElementsByClassName("snd")[0]
                    if($pronuciation) { 
                        $pronuciation = $pronuciation.getAttribute("data-snd")
                        $sound += ",http://img.tfd.com/hm/mp3/$pronuciation.mp3" 
                    }

                    foreach ($item in $document.getElementsByClassName("Syn")) {
                        if($item.tagName -ne "span" -or $item.innerText.IndexOf(",") -lt 0) { continue }
                        $synonyms += $item.parentNode.outerHtml
                    }
                    if (!$synonyms) {
                        for ($i = 1; $i -lt $document.getElementsByClassName("Syn").Length; $i++) {
                            $synonyms += $document.getElementsByClassName("Syn")[$i].outerHtml
                        }
                    }
                
                $example, $definition, $synonyms, $sound
            }
            
            $sets += , @($string, (Get-Oxford $string))
            break
            
        }
    }

    $msWord.Quit() 
    [void][Runtime.Interopservices.Marshal]::ReleaseComObject($msWord)
    Set-Content "$name.json" (ConvertTo-Json $sets) -Encoding UTF8
#>

function Get-Definition ($word) {

    $uri = "https://en.oxforddictionaries.com/definition/us/$word"
    $html = Invoke-WebRequest $uri
    $document = $html.ParsedHtml.body

    # example and synonym are based on definition
    $count = $document.getElementsByClassName("ind").Length
    if ($count -eq 0) { Write-Host "See root of $word"}
    for ($i = 0; $i -lt $count; $i++) {
        
        # defintion
        $definitions += "<p>$($document.getElementsByClassName("ind")[$i].outerHtml)</p>"

        # example
        $example = $document.getElementsByClassName("examples")[$i]
        if ($example) {
            # get all sentence in this defintion and get the longest one
            $sentences = @()
            foreach($sentence in $example.getElementsByClassName("ex")) {
                $sentences += , "<p>$($sentence.innerText.Substring(1,$sentence.innerText.Length -2))</p>"
            }
            $examples += $sentences | Sort-Object { $_.Length } | Select-Object -Last 1
        }

        # synonym
        $synonym = $document.getElementsByClassName("exs")[$i]
        if ($synonym) {
            $synonyms += "<p>$($synonym.outerHtml)</p>"
        }
        
    }
    $etymology = "<p>" + $document.getElementsByClassName("etymology")[0].innerText + "</p>"

    # get pronunciation from the free dictionary if 0xford has not
    if (!$document.getElementsByClassName("speaker")[0]) {
        $uri = "https://www.thefreedictionary.com/$word"
        $html = Invoke-WebRequest $uri
        $document = $html.ParsedHtml.body
        $pronuciation = $document.getElementsByClassName("snd")[0].getAttribute("data-snd")
        $sounds = "http://img.tfd.com/hm/mp3/$pronuciation.mp3"

        if(!$sounds) { 
            $pronuciation = $document.getElementsByClassName("snd2")[0]
            $pronuciation = $pronuciation.getAttribute("data-snd")
            $sounds = "http://img2.tfd.com/pron/mp3/$pronuciation.mp3" 
        }
    }
    else { $sounds = $document.getElementsByClassName("speaker")[0].ChildNodes[0].src }
    
    # get synonyms from the free dictionary if 0xford has not
    $uri = "https://www.thefreedictionary.com/$word"
    $html = Invoke-WebRequest $uri
    $document = $html.ParsedHtml.body
    foreach ($item in $document.getElementsByClassName("Syn")) {
        if($item.tagName -ne "span" -or !$item.innerText.Contains(",") -or $item.innerText.Contains("(")) { continue }
        $synonyms += $item.parentNode.outerHtml
    }
    if (!$synonyms) {
        for ($i = 1; $i -lt $document.getElementsByClassName("Syn").Length; $i++) {
            $item = $document.getElementsByClassName("Syn")[$i]
            if(!$item.innerText.Contains(",") -or $item.innerText.Contains("(")) { continue }
            $synonyms += $item.outerHtml
        }
    }
    $etymology += "<p>" + $document.getElementsByClassName("etyseg")[0].innerText + "</p>"
    New-Object PSObject -Property @{ word = $word; examples = $examples; definitions = $definitions; synonyms = $synonyms; sounds = $sounds; etymology = $etymology}
}

function Get-Etymology ($word) {
    $terms = @()
    $etymology = @()
    
    $uri = "https://en.wiktionary.org/wiki/$word"
    $html = Invoke-WebRequest $uri
    $document = $html.ParsedHtml.body
    $etymology = $document.getElementsByTagName("p") | ForEach-Object { if ($_.previousSibling.innerText -like "*Etymology*") { $_.innerHTML } }

    $xml = [xml](Get-Content "blog\text\affix.html")
    $nodes = $(Select-Xml "//tr" $xml).Node
    $maxPrefixString = ""
    $maxSuffixString = ""
    $maxPrefixIndex = 0
    $maxSuffixIndex = 0
    $maxPrefixLength = 0
    $maxSuffixLength = 0
    $etymologyes = "Prefix", "Suffix"
    for ($i = 1; $i -lt $nodes.Count; $i++) {
        
        $affix = $nodes[$i]
        $roots = $affix.ChildNodes[0].InnerText

        if($affix.ChildNodes[0].InnerText.Contains("/")) {
            $roots = ""
            $array = $affix.ChildNodes[0].innerText.Split("/")
            for ($j = 0; $j -lt $array.Count; $j++) {
                if($array[0].Trim(" ").StartsWith("-") -and !$array[$j].StartsWith("-")) { 
                    $array[$j] = "-" + $array[$j]
                }
                $roots += $array[$j] + ","
            }
        }
        $roots = $roots.Trim(" ").Split(", ")
        $roots.ForEach{
            $root = $_
            if (!$root -or $root-eq "-" -or $word.length -le $root.length) { return }
            $prefix = $word.Substring(0,$_.length)
            $suffix = $word.Substring($word.length - $root.length)
            for ($j = 0; $j -lt $affix.Count; $j++) {
                $affix = $affix[$j]
                if( $root.StartsWith("-") -and $word.EndsWith($root.Trim("-")) -or $word.StartsWith($root.Trim("-"))) { 
                    if ( (Get-Variable "max$($affix)Length" -ValueOnly) -lt $root.length) {
                        Set-Variable "max$($affix)Length" $root.length
                        Set-Variable "max$($affix)Index"  $i
                        Set-Variable "max$($affix)String" "<p><b>$($affix[$j]):</b> $(Get-Variable $affix -ValueOnly)</p>" 
                    }
                }
            }
        }
    }

    for ($j = 0; $j -lt $affix.Count; $j++) {
        if( !(Get-Variable $affix[$j] -ValueOnly) ) { continue }
        $etymology = $nodes[(Get-Variable "max$($affix[$j])Index" -ValueOnly)]
        $contents = "", "Meaning", "Example"
        for ($k = 1; $k -lt 3; $k++) {
            if (!(Get-Variable "max$($affix[$j])String" -ValueOnly)) {continue}
            Set-Variable "max$($affix[$j])String" "$(Get-Variable "max$($affix[$j])String" -ValueOnly)<p><b>$($contents[$k]):</b> $($etymology.ChildNodes[$k].InnerText)</p>"
        }
        $string += Get-Variable "max$($affix[$j])String" -ValueOnly
    }
    "<div class=`"etymology`">" + $string + $etymology + "</div>"
}

function Get-WordFamily ($word) {

    function Get-Children($Parent) {
        $words = @()
        $words = $members.Where{$_.Parent -eq $Parent}.Word
        if(!$words) { return }
        foreach ($word in $words) {
            $global:family = $family.Insert(($family.IndexOf($Parent) + $Parent.Length),"<ul><li>$word</li></ul>")
            Get-Children $word
        }
        
    }

    $uri = "https://www.vocabulary.com/dictionary/$word"
    $members = @()
    $html = Get-Html $uri $word
    $innerHtml = $html.body.getElementsByClassName("family")[0].innerHtml
    $global:family = ""
    if ($innerHtml) {
        # add member
        $regex = "`"word`":`"(?<word>.*?)`",(`"hw`":true,)?(`"parent`":`"(?<parent>.*?)`")?"
        foreach ($match in ($innerHtml | Select-String $regex -AllMatches -CaseSensitive).Matches) {
            $members += New-Object PSObject -Property @{ Word = $match.Groups["word"].Value; Parent = $($match.Groups["parent"].Value)}
        }
    }
    else {
        Write-Host "Manually create word family for $word"
        $ie = Invoke-InternetExplorer "https://www.vocabulary.com/dictionary/$word"
        $words = $ie.Document.IHTMLDocument3_getElementsByTagName("a") | ForEach-Object { if($_.className -like "*bar*" -and $_.innerText -notlike "the*family") {$_.innerText}}
        $words = $words | Sort-Object -Unique | Sort-Object Length
        $members += New-Object PSObject -Property @{ Word = $words[0]; Parent = ""}
        for ($i = 1; $i -lt $words.Count; $i++) {
            $j = 0
            do {
                $parent = @(($members.Where{$words[$i].Contains($_.Word.Substring(0,$_.Word.Length - $j))}.Word) | Sort-Object Length -Descending)[0]
                $j++
            }
            while(!$parent)
            $members += New-Object PSObject -Property @{ Word = $words[$i]; Parent = $parent}
        }
    }
    Get-Children ""
    Remove-Item "$PSScriptRoot\$word.html"
    $family
}

$words = @()
$sets = ConvertFrom-Json ((Get-Content C:\github\vocabulary.js -Raw) -replace "sets = ")
$id = "mh-example"
$name = (Get-Culture).TextInfo.ToTitleCase(($id -replace "-", " "))
$name = $name.Split(" ")[0].ToUpper() + " " + $name.Split(" ")[1]
$xml = [xml](Get-Content "C:\github\blog\text\gre\vocabulary.html")
$list = (Select-Xml "//div[@id=`"$id`"]" $xml).Node.InnerXml.Split(" ")
$set = New-Object PSObject -Property @{name = $name}

foreach($word in $list) {
    if(!$word) { continue }
    Write-Host $word
    $etymology = Get-Etymology $word 
    $family = Get-WordFamily $word
    $word = Get-Definition $word
    $word.etymology += $etymology
    $word | Add-Member -Type NoteProperty -Name family -Value $family
    $words += $word
}

$set | Add-Member -Type NoteProperty -Name words -Value $words
if ($sets -and $sets.Name.Contains($set.Name)) { $sets[$sets.Name.IndexOf($set.Name)] = $set } 
else { $sets += , $set }
$content = "sets = " + (ConvertTo-Json $sets) 
$details = ($sets[0].words[0] | Get-Member -MemberType NoteProperty).Name
foreach($detail in $details) { $content = $content -replace "$detail=", "`"$detail`"`:`"" }
$content = $content -replace ",`r`n\s+`"Count`".*`r`n}" -replace "{`r`n\s+`"value`":" 
$content = $content -replace "; `"", "`", `"" -replace "`"@{", "{" -replace "}`"", "`"}"
#Set-Content C:\github\vocabulary.js $content -Encoding UTF8

<#
                                xml to json
    $ie = Invoke-InternetExplorer "http://www.utilities-online.info/xmltojson/"
    while (!$ie.Document.IHTMLDocument3_getElementById("xml")) { Start-Sleep 1 }
    $ie.Document.IHTMLDocument3_getElementById("xml").value = $xml.OuterXml
    while(!$ie.Document.IHTMLDocument3_getElementById("json").value) {
        Start-Sleep 1
        $ie.Document.IHTMLDocument3_getElementById("tojson").Click()
        $json = $ie.Document.IHTMLDocument3_getElementById("json").value
        $json
    }
                                json to xml
    while (!$ie.Document.IHTMLDocument3_getElementById("json")) { Start-Sleep 1 }
    $ie.Document.IHTMLDocument3_getElementById("json").value = $json
    while(!$ie.Document.IHTMLDocument3_getElementById("xml").value) {
        Start-Sleep 1
        $ie.Document.IHTMLDocument3_getElementById("toxml").Click()
        $xml = $ie.Document.IHTMLDocument3_getElementById("xml").value
        $xml
    }

        function Get-Etymology ($word) {
        
    
#>
