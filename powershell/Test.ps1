. $PSScriptRoot\Utility.ps1
$content = Get-Content "C:\github\gre\notes\test.html" -Encoding UTF8
$content
Out-Host $content
Write-Host $content
$content = $content -replace "<hr.*>" -replace "div.*>", "ol>"
$content = $content -replace "strong>", "b>" -replace "<span.*?/span>"
$content = $content -replace "p.*?`">", "li>" -replace "p>", "li>"
#Set-Clipboard $content

<# Test x   html 
(Get-ChildItem "C:\github\*" -Recurse -File).ForEach{
    $file = $_
    if ($file.FullName -notmatch "ebook|notes\\gre\\|quantitative|ubuntu|temp" -and $file -match ".html$") {
        Write-Host $file.FullName
        [xml](gc $file.FullName)
    }
}
#>
<#(Get-ChildItem "C:\github\toefl\sample\*.html").ForEach{
    $file = $_
    if ($file.Name -match "speaking|writing") {
        Write-Host $file.Name
        $html = [xml](Get-Content $_ -Encoding UTF8)
        Set-Content "C:\github\gre\notes\test.html" $html.OuterXml.Replace("html[]", "html") -Encoding UTF8
        (Select-Xml "//main/*" $html).Node.ForEach{
            $node = $_
            $html = [xml](Get-Content "C:\github\gre\notes\test.html" -Encoding UTF8)
            $content = ""
            if ($node.id -match "text") {
                $id = $node.id.Replace("text", "passage")
                $headding = ""
                $headding = "<h3>$($node.h3)</h3>"
                $content = "<article id=`"$id`" class=`"passage`">$headding$($node.article.InnerXml)</article>"
                $content = $html.OuterXml.Replace($node.OuterXml, $content)
                Set-Content "C:\github\gre\notes\test.html" $content.Replace("html[]", "html") -Encoding UTF8
            } 
            elseif ($node.id -match "sample-response") {
                if ($file.Name -match "og" -or $file.FullName -match "\\pt\\") {
                    $content = $node.ChildNodes[0].OuterXml
                    $content += "<div id=`"responses`"><article class=`"response`">"+$node.ChildNodes[2].OuterXml
                    $content += $node.ChildNodes[3].InnerXml+"</article>"
                    if ($node.ChildNodes.Count -eq 5) { 
                        $content += "<article class=`"response`">" + $node.ChildNodes[4].InnerXml + "</article>" 
                    }
                    $content += "</div>" + $node.ChildNodes[1].OuterXml   
                }
                else {
                    if ($node.ChildNodes[0].OuterXml -match "article") {
                        
                        $content = $node.InnerXml.Replace("<article>", "<article class=`"response`">")
                    }
                    else {
                        $content = $node.ChildNodes[0].OuterXml + $node.ChildNodes[1].InnerXml
                        $content = "<article class=`"response`">$content</article>"
                    }
                    $content = "<div id=`"responses`">$content</div>"
                    
                }
                $content = $html.OuterXml.Replace($node.OuterXml, $content)
                Set-Content "C:\github\gre\notes\test.html" $content.Replace("html[]", "html") -Encoding UTF8
            }
        }
        if (!$content) {$content = $html.OuterXml}
        #Set-Content $file $content.Replace("html[]", "html") -Encoding UTF8
    }
}
#>

