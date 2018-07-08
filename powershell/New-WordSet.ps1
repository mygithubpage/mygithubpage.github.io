# Get Vocabulary 

$sets = @()
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
            #"<p>$sentence</p>", $definition, $synonyms, $sound
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
        function Get-Affix ($word) {
            $xml = [xml](Get-Content "..\toefl\notes\affix.html")
            (Select-Xml "//tr" $xml).Node.ForEach{
                $string = ""
                for ($i = 1; $i -lt $word.Length; $i++) {
                    $suffix = $word.Substring($i)
                    $prefix = $word.Substring(0,$word.Length - $i)
                    $affix = $_
                    $roots = @()
                    $roots = $affix.ChildNodes[0].InnerText

                    if(!$roots -and $affix.ChildNodes[1].InnerText.Contains("/")) {
                        $array = $affix.ChildNodes[1].innerText.Split("/")
                        for ($j = 1; $j -lt $array.Count; $j++) {
                            if($affix.ChildNodes[1].innerText.StartsWith("-")) { $roots += $array[$j] + "," }
                            else { $roots += $array[0] + $array[$j] + "," }
                            
                        }
                        $roots += $array[0].TrimEnd(",")
                    }
                    $roots = $roots.Trim(" ").Replace("-", "").Split(",")
                    $roots.ForEach{
                        if($prefix -eq $_) { $string += "<p>Prefix: $prefix</p>" }
                        elseif($suffix -eq $_) { $string += "<p>Suffix: $suffix</p>" }
                        else { return }

                        $i = $word.Length
                        if($affix.ChildNodes[0].InnerText) {
                            $string += "<p>Meaning: $($affix.ChildNodes[1].InnerText)</p>"
                            $string += "<p>Example: $($affix.ChildNodes[2].InnerText)</p>"
                        }
                        else {
                            $string += "<p>Meaning: $($affix.ChildNodes[2].InnerText)</p>"
                            $string += "<p>Example: $($affix.ChildNodes[$affix.ChildNodes.Count - 1].InnerText)</p>"
                        }
                        
                    }
                }
            }
            $string
        }
        
        $affix = Get-Affix $string
        $sets += , @($string, (Get-Oxford $string))
        break
        
    }
}

$msWord.Quit() 
[void][Runtime.Interopservices.Marshal]::ReleaseComObject($msWord)
Set-Content "$name.json" (ConvertTo-Json $sets) -Encoding UTF8

(Get-Content "$name.json") -replace "\s{2,}" -join "" -replace "\[\[", "[`"$name`",[[" -replace "\]\]\]", "]]]]," | Set-Clipboard
Remove-Item $docx
Remove-Item "$name.json"
<#
$text = ""
for ($i = 0; $i -lt $sets.Count; $i+=2) {
    foreach($definition in $sets[$i+1]) {
        $text += $sets[$i] + "`n" + $definition + "`n"
    }
}
Set-Clipboard $text
if($false) {
    $sets = (Get-Content "$name.json" -Raw | ConvertFrom-Json) + $sets
}
else {
    
}
#>
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

#>