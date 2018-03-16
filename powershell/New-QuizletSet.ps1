# Get Vocabulary 

$sets = @()
$msWord = New-Object -ComObject Word.Application 
$docx = (Get-ChildItem "$env:USERPROFILE\OneDrive\TOEFL\*.docx")[0]
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
        $sentence
        
        $uri = "https://www.thefreedictionary.com/" + $string
        $html = Invoke-WebRequest $uri
        $document = $html.ParsedHtml.body
        
        $definition = ""
        $definitions = $document.getElementsByClassName("pseg")
        for ($i = 0; $definitions[$i].parentNode.id -eq "Definition"; $i++) {
            $definitions[$i].getElementsByClassName("ds-list") | ForEach-Object { $definition += "$($_.innerText)`n" }
            $definitions[$i].getElementsByClassName("ds-single") | ForEach-Object { $definition += "$($_.innerText)`n" }
        }
        $definition

        $synonyms = ""
        foreach ($item in $document.getElementsByClassName("Syn")) {
            if($item.tagName -ne "span" -or $item.innerText.IndexOf(",") -lt 0) { continue }
            $synonyms += "$($item.innerText).`n"
        }
        $synonyms
        
        $sets += @($string, @("$sentence`n", $definition, $synonyms))
        break
        
    }
}

$msWord.Quit() 
[void][Runtime.Interopservices.Marshal]::ReleaseComObject($msWord)
#Remove-Item $docx
#>
$text = ""
for ($i = 0; $i -lt $sets.Count; $i+=2) {
    foreach($definition in $sets[$i+1]) {
        $text += $sets[$i] + "`n" + $definition + "`n"
    }
}
Set-Clipboard $text

$name = $name.Substring(0, $name.Length - 2).ToLower()
if(Test-Path "$name.json") {
    $sets = (Get-Content "$name.json" -Raw | ConvertFrom-Json) + $sets
}
else {
    $json = ConvertTo-Json $sets
    New-Item "$name.json" -Value $json | Out-Null
}

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




<#

#>
