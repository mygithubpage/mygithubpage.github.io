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

