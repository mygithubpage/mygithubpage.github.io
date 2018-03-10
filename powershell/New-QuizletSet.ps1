# Get Vocabulary 
$vocabulary = @()
$word = New-Object -ComObject Word.Application 
$file = $word.Documents.Open("$env:USERPROFILE\OneDrive\TOEFL\Vocabulary.docx")
for ($i = 5; $i -le $file.Content.Paragraphs.Count; $i++) {
    $vocabulary += $file.Content.Paragraphs($i).Range.Text
}
$word.Quit() 
[void][Runtime.Interopservices.Marshal]::ReleaseComObject($word)

$vocabulary.ForEach{
    $word = $_
    $sets = @()
    foreach ($word in $vocabulary) {
        $word
        $html = Invoke-WebRequest ("https://www.thefreedictionary.com/" + $word)
        $document = $html.ParsedHtml.body

        $definition =""
        $div = $document.getElementsByClassName("pron")[1].nextSibling.nextSibling
        while($div.tagName -eq "div" -and $div.className -eq $null) {
            foreach ($item in $div.getElementsByClassName("ds-list")) { $definition += "$($item.innerText)`n" }
            $div = $div.nextSibling
        }

        $sets += New-Object PSObject -Property `
            @{
                Term        = $word
                Definition  = $definition.TrimEnd("`n")      
            }
        $synonyms = ""
        foreach ($item in $document.getElementsByClassName("Syn")) {
            if($item.tagName -ne "span" -or $item.innerText.IndexOf(",") -lt 0) { continue }
            $synonyms += "$($item.innerText).`n"
        }
        $sets += New-Object PSObject -Property `
            @{
                Term        = $word
                Definition  = $synonyms.TrimEnd("`n")        
            }
    }

    $text = ""
    foreach ($item in $sets) {
        $text += $item.Term + "`n" + $item.Definition + "`n`n"
    }
    Set-Clipboard $text
}