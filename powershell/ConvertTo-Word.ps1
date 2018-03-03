. .\Utility.ps1

function ConvertTo-Word () {
    param($Content, $SavePath, $Word)

    $file = $word.Documents.Add()
    $file.Content = $Content 
    $range = $file.Content
    $found = $range.Find.Execute("\<h?\>*\<\/h?\>", $default, $default, $true) 
    $file.Content = $file.Content.Text -replace "</.*?><p>", "`n" -replace "<.*?>"
    if($found) {$range.sentences(1).Bold = $true}
    $file.SaveAs2($SavePath)
    $file.Close()
}

$word = New-Object -ComObject Word.Application 
$word.Visible = $true

$files = Get-ChildItem "GitHub/toefl/essay/topic*.html"
$files.ForEach{
    [xml]$xml = Update-Entity $_.FullName "Add"
    $savePath = $_.Directory.FullName + "\" + $_.BaseName + ".docx"
    ConvertTo-Word (Select-Xml "//article" $xml).Node.InnerXml $savePath $word  
}

$word.Quit() 
[void][Runtime.Interopservices.Marshal]::ReleaseComObject($word)