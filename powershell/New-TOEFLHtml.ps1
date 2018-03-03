. .\Utility.ps1

$path = "GitHub/TOEFL/Essay/essay.html"
[xml]$essay = Update-Entity $path "Add"
#$node = (Select-Xml "//article" $essay).Node
#links = Select-Xml "//nav[@id='sidebar']/div/a" $essay | ForEach-Object {$_.Node}

for ($i = 1; $i -lt -51; $i++) {
    #$files = Get-ChildItem "GitHub/TOEFL/Essay/topic$($i)-*.html" -Recurse -File
    
    $number = if($i -lt 10) { "0$i" } else { $i }
    # Add Sidebar Page
    $element = $essay.CreateElement("button")
    $element.InnerText = "tpo$number"
    $element.SetAttribute("class", "w3-button w3-block w3-left-align")
    $element.SetAttribute("onclick", "accFunc('tpo$number')")
    $node.AppendChild($element) | Out-Null

    $element = $essay.CreateElement("div")
    $element.InnerText = ""
    $element.SetAttribute("id", "tpo$number")
    $element.SetAttribute("class", "w3-hide w3-white w3-card")
    $node.AppendChild($element) | Out-Null
    #>

    
    for($j = 1; $j -le $files.Count; $j++) {

        [xml]$xml = Update-Entity $files[$j-1].FullName "Add"

        <#
        # Add Previous and Next
        $previousNodes = Select-Xml "//a[. = 'Previous']" $essay
        $nextNodes = Select-Xml "//a[. = 'Next']" $essay
        $index = $links.IndexOf($files[$j-1].Name)
        for ($k = 0; $k -lt 2; $k++) {
            $previousNodes[$k].Node.href = $links[$index - 1]
            $nextNodes[$k].Node.href = $links[$index + 1]
        }
        $node.InnerXml = $xml.html.body.article.InnerXml
        
        # Add Sidebar Page links
        $child = $essay.CreateElement("a")
        $child.InnerText = "%emsp%" + "Essay $j"
        $child.SetAttribute("class", "w3-bar-item w3-button")
        $child.SetAttribute("href", $files[$j-1].Name)
        $element.AppendChild($child) | Out-Null
        #>
        $xml.html.head.InnerXml = $essay.html.head.InnerXml
        (Select-Xml "//title" $xml).Node.InnerText = $links.ForEach{if ($_.href -eq $files[$j-1].Name) { $xml.html.body.main.section.article.h3 + " " + $_.InnerText.Replace("%emsp%","")} }
        $xml.html.body.InnerXml = $xml.html.body.InnerXml + $essay.html.body.footer.OuterXml
        (Format-Xml $xml.InnerXml 2) -replace ">`r`n\s+</sc", "></sc" -replace ">`r`n\s+</i", "></i" | Out-File $files[$j-1].FullName -Encoding utf8
        $content = Update-Entity $files[$j-1].FullName
        $content | Out-File $files[$j-1].FullName -Encoding utf8
    }
}
#$content = Format-Xml $xml.InnerXml 2
#$content -replace ">`r`n\s+</sc", "></sc" -replace ">`r`n\s+</i", "></i"