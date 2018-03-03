. .\Utility.ps1

(Get-ChildItem .\..\toefl\essay\topic*.html).ForEach{
    $content = Get-Content $_.FullName
    $xml = [xml]($content.Replace("&emsp", "emsp"))

    $nodes = (Select-Xml "//head/meta | //head/link" $xml)
    $nodes.foreach{ $_.Node.ParentNode.RemoveChild($_.Node) | Out-Null }

    $node = (Select-Xml "//head/script" $xml).Node
    $node.src = "/github/initialize.js"

    $node = (Select-Xml "//nav[@id='topNav']" $xml).Node
    $node.ParentNode.RemoveChild($node) | Out-Null

    $node = (Select-Xml "//nav[@id='sidebar']" $xml).Node
    $node.ParentNode.RemoveChild($node) | Out-Null

    $node = (Select-Xml "//footer" $xml).Node
    $node.ParentNode.RemoveChild($node) | Out-Null

    $_.FullName
    Set-Content $_.FullName (Format-Xml $xml.OuterXml 2).Replace("&amp;", "&").Replace("html[]", "html").Replace("<br />", "").Replace("w3-brown", "my-color")
}
