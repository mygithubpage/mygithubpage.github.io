. $PSScriptRoot\Utility.ps1

# Get Vocabulary 

function Get-Definition ($word) {

    $uri = "https://en.oxforddictionaries.com/definition/us/$word"
    $html = Invoke-WebRequest $uri
    $document = $html.ParsedHtml.body

    # example and synonym are based on definition
    $count = $document.getElementsByClassName("ind").Length
    if ($count -eq 0) { Write-Host "See root of $word"}
    for ($i = 0; $i -lt $count; $i++) {
        
        # defintion
        $definitions += $document.getElementsByClassName("ind")[$i].outerHtml -replace "SPAN", "p"

        # example
        $example = $document.getElementsByClassName("examples")[$i]
        if ($example) {
            # get all sentence in this defintion and get the longest one
            $sentences = @()
            foreach ($sentence in $example.getElementsByClassName("ex")) {
                $sentences += , $sentence.innerText.Substring(1,$sentence.innerText.Length -2) -replace "SPAN", "p"
            }
            $examples += $sentences | Sort-Object { $_.Length } | Select-Object -Last 1
        }

        # synonym
        $synonym = $document.getElementsByClassName("exs")[$i]
        if ($synonym) {
            $synonyms += $synonym.outerHtml
        }
        
    }
    if ($document.getElementsByClassName("etymology")[0]) {
        $etymology = $document.getElementsByClassName("etymology")[0].ChildNodes[1].innerHTML
    }

    # get pronunciation from the free dictionary if 0xford has not
    if (!$document.getElementsByClassName("speaker")[0]) {
        $uri = "https://www.thefreedictionary.com/$word"
        $html = Invoke-WebRequest $uri
        $document = $html.ParsedHtml.body
        $pronuciation = $document.getElementsByClassName("snd")[0].getAttribute("data-snd")
        $sounds = "http://img.tfd.com/hm/mp3/$pronuciation.mp3"

        if (!$sounds) { 
            $pronuciation = $document.getElementsByClassName("snd2")[0]
            $pronuciation = $pronuciation.getAttribute("data-snd")
            $sounds = "http://img2.tfd.com/pron/mp3/$pronuciation.mp3" 
        }
    }
    else { $sounds = $document.getElementsByClassName("speaker")[0].ChildNodes[0].src }
    
    # get synonyms from the free dictionary if Oxford has not
    $uri = "https://www.thefreedictionary.com/$word"
    $html = Invoke-WebRequest $uri
    $document = $html.ParsedHtml.body
    foreach ($item in $document.getElementsByClassName("Syn")) {
        if ($item.tagName -ne "span" -or !$item.innerText.Contains(",")) { continue }
        $synonyms += $item.outerHtml
    }
    if (!$synonyms) {
        for ($i = 1; $i -lt $document.getElementsByClassName("Syn").Length; $i++) {
            $item = $document.getElementsByClassName("Syn")[$i]
            if (!$item.innerText.Contains(",") -or $item.innerText.Contains("(")) { continue }
            $synonyms += $item.outerHtml
        }
    }
    $synonyms = $synonyms -replace "<A.*?>(.*?)</A>", "`$1"
    $synonyms = $synonyms -replace " <I>.*?</I>"
    $synonyms = $synonyms -replace "((?<=>)| )(\w+([ -]\w+)+|<B>.*?</B>)(,|(?=<))"
    $synonyms = $synonyms -replace ",(?=<)|<strong></strong>,? ?" 
    $synonyms = $synonyms -replace "strong>", "b>"
    $synonyms = $synonyms -replace "<div.*exs`"></div>|<div class=Syn>\(.*\)</div>|(?<=(`"|n)>) (?=\w+)"
    $synonyms = $synonyms -replace "SPAN|div", "p"

    $etymology += "<p>"+$document.getElementsByClassName("etyseg")[0].innerHTML+"</p>"
    $etymology = $etymology -replace "<A.*?>(.*?)</A>", "<b>`$1</b>"
    $etymology = $etymology -replace "(<i.*?>.*?</i>)", "<b>`$1</b>"
    $etymology = $etymology -replace "<span.*?>(.*?)</span>", "`$1"

    Add-Content "C:\github\gre\notes\test.html" "`n`n$word`n$synonyms`n$etymology"
    New-Object PSObject -Property @{ 
        word        = $word; 
        examples    = $examples; 
        definitions = $definitions; 
        synonyms    = $synonyms; 
        sounds      = $sounds; 
        etymology   = $etymology
    }

}

function Get-WordFamily ($word) {

    function Get-Children($Parent) {
        $words = @()
        $words = $members.Where{$_.Parent -eq $Parent}.Word
        if (!$words) { return }
        foreach ($word in $words) {
            $global:family = $family.Insert(($family.IndexOf($Parent) + $Parent.Length), "<ul><li>$word</li></ul>")
            Get-Children $word
        }
        
    }

    $uri = "https://www.vocabulary.com/dictionary/$word"
    $members = @()
    $html = Get-Html $uri $word
    $innerHTML = $html.body.getElementsByClassName("family")[0].innerHTML
    $global:family = ""
    if ($innerHTML) {
        # add member
        $regex = "`"word`":`"(?<word>.*?)`",(`"hw`":true,)?(`"parent`":`"(?<parent>.*?)`")?"
        foreach ($match in ($innerHTML | Select-String $regex -AllMatches -CaseSensitive).Matches) {
            $members += New-Object PSObject -Property @{ Word = $match.Groups["word"].Value; Parent = $match.Groups["parent"].Value}
        }
    }
    else {
        Write-Host "Manually create word family for $word"
        $ie = Invoke-InternetExplorer "https://www.vocabulary.com/dictionary/$word"
        $words = $ie.Document.IHTMLDocument3_getElementsByTagName("a").ForEach{ if ($_.className -like "*bar*" -and $_.innerText -notlike "the*family") {$_.innerText}}
        $words = $words | Sort-Object -Unique | Sort-Object Length
        $members += New-Object PSObject -Property @{ Word = $words[0]; Parent = ""}
        for ($i = 1; $i -lt $words.Count; $i++) {
            $j = 0
            do {
                $parent = @(($members.Where{$words[$i].Contains($_.Word.Substring(0, $_.Word.Length - $j))}.Word) | Sort-Object Length -Descending)[0]
                $j++
            }
            while (!$parent)
            $members += New-Object -Property PSObject @{ Word = $words[$i]; Parent = $parent}
        }
    }
    Get-Children ""
    Remove-Item "$PSScriptRoot\$word.html"
    $family
}

$words = @()
$sets = ConvertFrom-Json ((Get-Content C:\github\js\vocabulary.js -Raw) -replace "sets = ")
$id = "pq-easy"
$name = (Get-Culture).TextInfo.ToTitleCase(($id -replace "-", " "))
$name = $name.Split(" ")[0].ToUpper() + " " + $name.Split(" ")[1]

$xml = [xml](Get-Content "C:\github\gre\notes\vocabulary.html")
$list = (Select-Xml "//div[@id=`"$id`"]" $xml).Node.InnerXml.Split(" ")
$set = New-Object PSObject -Property @{name = $name}

Set-Content "C:\github\gre\notes\test.html" ""

foreach ($word in $list) {
    if (!$word) { continue }
    Write-Host $word
    #$etymology = Get-Etymology $word 
    $family = Get-WordFamily $word
    $word = Get-Definition $word
    #$word.etymology += $etymology
    $word | Add-Member family $family
    $words += $word
}

$set | Add-Member words $words
if ($sets -and $sets.Name.Contains($set.Name)) { $sets[$sets.Name.IndexOf($set.Name)] = $set } 
else { $sets += , $set }

# format json to js
$content = "sets = " + (ConvertTo-Json $sets) 
$details = ($sets[0].words[0] | Get-Member -MemberType NoteProperty).Name
foreach ($detail in $details) { $content = $content -replace "$detail=", "`"$detail`"`:`"" }
$content = $content -replace ",`r`n\s+`"Count`".*`r`n}" -replace "{`r`n\s+`"value`":" 
$content = $content -replace "; `"", "`", `"" -replace "`"@{", "{" -replace "}`"", "`"}"

Set-Content C:\github\js\vocabulary.js $content -Encoding UTF8

<#
function Get-Etymology ($word) {
    $terms = @()
    $etymology = @()
    
    $uri = "https://en.wiktionary.org/wiki/$word"
    $html = Invoke-WebRequest $uri
    $document = $html.ParsedHtml.body
    $etymology = $document.getElementsByTagName("p") | ForEach-Object { if ($_.previousSibling.innerText -like "*Etymology*") { $_.innerHTML } }

    $xml = [xml](Get-Content "notes\affix.html")
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

        if ($affix.ChildNodes[0].InnerText.Contains("/")) {
            $roots = ""
            $array = $affix.ChildNodes[0].innerText.Split("/")
            for ($j = 0; $j -lt $array.Count; $j++) {
                if ($array[0].Trim(" ").StartsWith("-") -and !$array[$j].StartsWith("-")) { 
                    $array[$j] = "-" + $array[$j]
                }
                $roots += $array[$j] + ","
            }
        }
        $roots = $roots.Trim(" ").Split(", ")
        $roots.ForEach{
            $root = $_
            if (!$root -or $root -eq "-" -or $word.length -le $root.length) { return }
            $prefix = $word.Substring(0, $_.length)
            $suffix = $word.Substring($word.length - $root.length)
            for ($j = 0; $j -lt $affix.Count; $j++) {
                $affix = $affix[$j]
                if ( $root.StartsWith("-") -and $word.EndsWith($root.Trim("-")) -or $word.StartsWith($root.Trim("-"))) { 
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
        if ( !(Get-Variable $affix[$j] -ValueOnly) ) { continue }
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
#>