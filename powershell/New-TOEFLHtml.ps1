. .\Utility.ps1
function ConvertTo-HtmlCharSets($string)
{
    $string = $string -replace "\u2103", "&#8451;" # ℃
    $string = $string -replace "\u2013", "&#8211;" # –
    $string
}

function Update-Xml()
{
    param($content)
    $content = $content -replace "<!\[CDATA\[", "" -replace "\]\]>", ""
    $content = $content -replace "&amp;", "&" -replace "&lt;", "<" -replace "&gt;", ">" 
    $content = $content -replace " description=`".*?`"", ""
    $content = $content.Replace(" `$pstart ", "<p>").Replace(" `$pend ", "</p>")
    $content = $content.Replace(" `$hstart ", "<span style=`"background: #D3D3D3`">").Replace(" `$hend ", "</span>")
    $content = $content.Replace("`$nv ").Replace("`$ ")
    $content = $content -replace "</?(st1|font|w:r|w:t).*?>", ""
    $content = $content -replace "_____", "&#9724;"
    #$content = ConvertTo-HtmlCharSets $content
    while($content.Contains("  ")) { $content = $content -replace "  ", " "}
    Format-Xml ([xml]$content)
}

function New-Html () 
{
    param($Content, $Path) 
    $xml = ConvertTo-Xml -InputObject $xml
    $xml.RemoveAll()

    # Create html Node and Set Attribute lang="en" <html lang="en"></html>
    $htmlNode = $xml.CreateElement("html")
    $htmlNode.innerText = ""
    $htmlNode.SetAttribute("lang", "en")
    $htmlNode = $xml.AppendChild($htmlNode)

    # Create head Node
    $headNode = $xml.CreateElement("head")
    $headNode.innerText = ""
    $htmlNode.AppendChild($headNode) | Out-Null
 
    # Create title Node and Add title
    $titleNode = $xml.CreateElement("title")
    $title = $Path.Split('\\')[-1].TrimEnd('.html').Split('-')
    $titleNode.InnerText = $title[0].ToUpper() + " " + ($title[1].Substring(0,1).ToUpper() + 
    $title[1].Substring(1,$title[1].length - 1)).insert($title[1].length - 1, " ")
    $headNode.AppendChild($titleNode) | Out-Null

    # Create Script Element
    $scriptNode = $xml.CreateElement("script")
    $scriptNode.SetAttribute("src", "/index.js") 
    $scriptNode.InnerText = ""
    $headNode.AppendChild($scriptNode) | Out-Null


    # Create body Node
    $bodyNode = $xml.CreateElement("body") 
    $bodyNode.InnerText = ""
    $htmlNode.AppendChild($bodyNode) | Out-Null

    # Add Content
    $cdata = $xml.CreateCDataSection($Content)
    $bodyNode.AppendChild($cdata) | Out-Null
    $xml.InnerXml = $xml.InnerXml.Replace("<![CDATA[").Replace("]]>")

    # Add Navigation
    $node = (Select-Xml "//div[@id='$($title[0])']" ([xml](Get-Content .\..\toefl\tpo\tpo.html))).Node
    $div = $xml.CreateElement("div")
    $div.SetAttribute("class", "w3-bar w3-margin-bottom")
    $div.SetAttribute("id", $title[0])
    $div.InnerXml = $node.InnerXml
    $div.RemoveChild($div.FirstChild) | Out-Null
    (Select-Xml "//main" $xml).Node.InsertBefore($div, (Select-Xml "//main" $xml).Node.FirstChild) | Out-Null
    
    # Add Previous Next Button
    $htmls = Get-ChildItem ".\..\toefl\tpo\$($title[0])\*.html".ForEach{$_.Name}
    $index = $htmls.IndexOf($Path.Split('\\')[-1])
    $div = $xml.CreateElement("div")
    $div.SetAttribute("class", "w3-bar")
    
    $a = $xml.CreateElement("a")
    $a.SetAttribute("href", $htmls[$index - 1])
    $a.SetAttribute("class", "w3-btn w3-left my-color")
    $a.InnerText = "Previous"
    $div.AppendChild($a) | Out-Null

    $a = $xml.CreateElement("a")
    $a.SetAttribute("href", $htmls[$index + 1])
    $a.SetAttribute("class", "w3-btn w3-right my-color")
    $a.InnerText = "Next"
    $div.AppendChild($a) | Out-Null
    (Select-Xml "//main" $xml).Node.AppendChild($div) | Out-Null

    $string = (Format-Xml $xml 2).Tostring().Replace("$($title[0])/","")
    ("<!DOCTYPE html>`n" + $string) | Out-File $Path -Encoding "utf8"
}

function Get-Barrons () 
{
    for($i = 1; $i -le 7; $i++)
    {
        $xmls = Get-ChildItem "$folder\Barrons\test$i\assets\pages\*.xml"
        $xmls += Get-ChildItem "$folder\Barrons\test$i\toc.xml"
        foreach($xml in $xmls)
        {
            "test$i\" + $xml.Name
            $content = Get-Content $xml
            $file = Update-Xml $content 
            $file | Out-File "$HOME\Downloads\ETS\Box\Barrons\test$i\pages\$($xml.Name)" -Encoding "utf8"
        }
    }
}


$global:folder = "$HOME\Downloads\ETS\TOEFL Programs"
$global:projectPath = "$HOME\Downloads\ETS\TOEFL Programs\Sampler\forml1"
$global:sections = "reading", "listening", "speaking", "writing"
#Get-Barrons


<#
(Get-AllIndexesOf $article " ").Count
$article.Split("-")[4]
#$xml.html.body.InnerText

<#
if ($false) {
#$tests = "Barrons", "Cambridge", "Longman CD", "Longman EBook"
foreach($test in $tests[0]){
    (Get-ChildItem "C:\Users\decisactor\Box Sync\TOEFL\$test\*.mp3" -Recurse).foreach{
        Copy-Item "$folder\$test\$($_.Name)" $_.Directory.FullName
    }
}
#$mp3s = Get-ChildItem "$HOME\Downloads\ETS\TOEFL Programs\Cambridge\?S?S.mp3"
foreach($mp3 in $mp3s)
{
    $number = $mp3.Name.Substring(0,1)
    Copy-Item $mp3 "$HOME\Box Sync\TOEFL\Cambridge\test$number\audio\"
}
}
#>