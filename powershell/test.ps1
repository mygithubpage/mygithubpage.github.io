. $PSScriptRoot\Utility.ps1
<# set top table
$xml = [xml](Get-Content .\..\toefl\tpo\tpo.html)
$node = (Select-Xml "//div[@id='tpo01']" $xml).Node
for ($i = 2; $i -le 53; $i++) {
    $num = if($i -lt 10) { "0$i" } else { $i }
    $div = $xml.CreateElement("div")
    $div.SetAttribute("class", "w3-bar my-margin-small")
    $div.SetAttribute("id", "tpo$num")
    $div.InnerXml = $node.InnerXml.Replace("tpo01", "tpo$num").Replace("TPO01", "TPO$num")
    (Select-Xml "//div[@id='tpo']" $xml).Node.AppendChild($div)
    Set-Content .\..\test.html (Format-Xml $xml.OuterXml 2).Replace("html[]", "html")
}
#>
<##>
    <#
    if ($type -eq "selection") {$digit = "0-9"}
    $character = "[^A-za-z$digit!#$%&'()*+,./:;<=>?@\^_`{}~-]"
    while ($string -and $string.Substring(0, 1) -match $character) { $string = $string.Remove(0, 1) } 
    while ($string -and $string.Substring($string.Length - 1, 1) -match $character) { $string = $string.Remove($string.Length - 1, 1) } 
    if ($type -eq "question") { while ($string.Substring(0, 1) -match "[^A-Za-z]") { $string = $string.Remove(0, 1) } }
    while($string.Contains("  ")) { $string = $string.Replace("  ", " ") }
    #>
#$HEXDATA.Replace("%", " ").Split(" ") | FOREACH {WRITE-HOST –object ( [BYTE][CHAR]([CONVERT]::toint16($_,16))) –nonewline }

#Get-Content "TPO52-1316.html" -Encoding UTF8
#[System.Text.Encoding]::Unicode
$questionText = "Directions: An introductory sentence for a brief summary of the passage is provided below. Complete the summary by selecting the THREE answer choices that express the most important ideas in the passage. Some sentences do not belong in the summary because they express ideas that are not presented in the passage or are minor ideas in the passage. This question is worth 2 points.Drag your answer choices to the spaces where they belong. To remove an answer choice, click on it.To review the passage, click VIEW TEXT. Over a period of thousands of years, the symbols originally used for keeping track of goods evolved into the first writing system, Sumerian cuneiform."


if (!$questionText.EndsWith(".")) {
    $questionText += "."
}

$summary = $questionText.Split(".")[-2]
$count = 0
while($summary.Length -lt 20 -or $summary.IndexOf("answer choice") -gt 0) { 
    $count--
    $summary = "$($questionText.Split(".")[$count-2])"
}
#"150,240,800,0,$summary.".Substring("150,240,800,0,$summary.".IndexOf(",0,") + 3)
$sets = "TPO"
$number = 52
$global:htmlPath = "C:\github\toefl\$($sets.ToLower())"


#$ie = Invoke-InternetExplorer "https://top.zhan.com/toefl/read/alltpo.html"
#$ie.Document.queryselectorAll(".title")
$ie = Invoke-InternetExplorer "https://top.zhan.com/toefl/read/practicereview-1312-13.html"
while ($ie.Busy -or $ie.ReadyState -ne 4) {
    
}
$text = ""
foreach($item in $ie.Document.IHTMLDocument3_getElementsByTagName("span"))
{
    if ($item.className -ne "text" -or $item.tagName -ne "span") { continue }
    $text += $item.innerHtml
}
$text