. .\Utility.ps1
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
#$html = Invoke-WebRequest "$website/listen/og.html"
$Path = "C:\github\toefl\tpo\tpo01\tpo01-reading1.html"
$title = $Path.Split('\\')[-1].TrimEnd('.html').Split('-')
$title[0].ToUpper() + " " + ($title[1].Substring(0,1).ToUpper() + 
    $title[1].Substring(1,$title[1].length - 1)).insert($title[1].length - 1, " ")