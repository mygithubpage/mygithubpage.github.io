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
<#
(Get-ChildItem .\..\blog\*.html).ForEach{
    [xml](Get-Content $_)
}
#>


#05R2Q14 596 
#41R1
<#
Cannot convert value "System.Object[]" to type "System.Xml.XmlDocument". Error: "Reference to undeclared entity 'shy'. Line 8,
position 1381."
At C:\github\powershell\Get-TPOWebsite.ps1:316 char:9
#>