$xml = [xml](Get-Content "blog\text\affix.html")
$nodes = $(Select-Xml "//tr" $xml).Node

for ($i = 577; $i -lt $nodes.Count; $i++) {
    
    $affix = $nodes[$i]
    $roots = $affix.ChildNodes[0].InnerText
    
    if ($roots.Contains("/")) { 
        $roots.Contains(", ")
    }
}