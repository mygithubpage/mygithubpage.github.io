. .\Utility.ps1
function ConvertTo-HtmlCharSets()
{
    #$content = $content -replace "–", "&#8208;"
    #$content = $content -replace "°C", "&#8451;"
    $content
}

function Update-Xml()
{
    param($content)
    $content = $content -replace "<!\[CDATA\[", "" -replace "\]\]>", ""
    $content = $content -replace "&amp;", "&" -replace "&lt;", "<" -replace "&gt;", ">" 
    $content = $content -replace " description=`".*?`"", ""
    $content = $content.Replace(" `$pstart ", "<p>").Replace(" `$pend ", "</p>")
    $content = $content.Replace(" `$hstart ", "<span style=`"background: #D3D3D3`">").Replace(" `$hend ", "</span>")
    $content = $content.Replace("`$nv ", "").Replace("`$ ", "")
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

    # Create meat Node and Set attribute charset="UTF-8" <meta charset="UTF-8">
    $metaNode = $xml.CreateElement("meta")
    $metaNode.SetAttribute("charset", "UTF-8") 
    $headNode.AppendChild($metaNode) | Out-Null

    # Create meat Node and Set Attributes to view in mobile device
    $metaNode = $xml.CreateElement("meta")
    $metaNode.SetAttribute("name", "viewport") 
    $metaNode.SetAttribute("content", "width=device-width, initial-scale=1.0")
    $headNode.AppendChild($metaNode) | Out-Null

    # Create title Node and Add title
    $titleNode = $xml.CreateElement("title")
    $titleNode.innerText = $Path.Split('\\')[-1].TrimEnd('.html')
    $headNode.AppendChild($titleNode) | Out-Null

    # Create body Node
    $bodyNode = $xml.CreateElement("body") 
    $bodyNode.innerText = ""
    $htmlNode.AppendChild($bodyNode) | Out-Null

    # Add Content
    $cdata = $xml.CreateCDataSection($Content)
    $bodyNode.AppendChild($cdata) | Out-Null
    $xml.InnerXml = $xml.InnerXml.Replace("<![CDATA[", "").Replace("]]>", "")
    $string = (Format-Xml $xml 2).Tostring()
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

function Get-TPO ()
{
    for ($n = 1; $n -le 1; $n++) 
    {
        $tpoNumber = $n
        if ($tpoNumber -lt 10) {$tpoNumber = "0$tpoNumber"}
        
        $xmlFiles = Get-ChildItem "$projectPath\TPO$tpoNumber\???????.xml" -Recurse
        foreach ($xmlFile in $xmlFiles) 
        {
            $text = ""
            $content = Get-Content $xmlFile
            [xml]$xml = $content
            $node = (Select-Xml "//miniPassageText" $xml).Node
            if ($node) 
            { 
                if ($xmlFile.Name -like "*S[34].xml") 
                {
                    $text = "<main><section id=`"Reading Text`"><h2>Reading Text</h2><article><h3 style=`"text-align:center;`">" + 
                    $node.ParentNode.miniPassageTitle + "</h3><p>" + $node.innerText + "</p></article></section></main>"
                }
                else 
                {
                    $text = $node.innerText -replace ("`n"+ " " * 8),"</p><p>"
                    $text = "<main><section id=`"reading-text`"><h2>Reading Text</h2><article><p>" + $text + 
                    "</p></article></section></main>"
                }
            }
            $node = (Select-Xml "//PassageText" $xml).Node
            if ($node) 
            { 
                $index = $node.innerText.IndexOf("`n" + " "*8)
                $text = $node.InnerText.Remove($index, 9)
                $text = $text.Insert($index, "</h3><p>")
                $text = $text -replace ("`n"+ " " * 8),"</p><p>"
                $text = "<main><section id=`"reading-text`"><h2>Reading Text</h2><article><h3 style=`"text-align:center;`">" + $text + "</p></article></section></main>"
            }
            $node = (Select-Xml "//AudioText" $xml).Node
            if ($node) 
            { 
                $audioText = ($node.innerText -replace "\[.{8}\]", "" -replace (" " * 8), "")
                $audioText = $audioText -replace "`n","</p><p>"
                
                $text += "<main><section id=`"listening-text`"><h2>Listening Text</h2><article><p>" + $audioText + "</p></article></section></main>"
            }
            $node = (Select-Xml "//SampleResponse" $xml).Node
            if ($node) 
            { 
                $main = "<main>"
                if ($xmlFile.Name -like "*S[12].xml" -or $xmlFile.Name -like "*W1.xml") 
                {
                    $text += "<main><section id=`"question`"><h3>Question</h3><p>" + $node.ParentNode.Stem + "</p></section>"
                    $main = ""
                }
                $text += "$main<section id=`"sample-response`"><h3>Sample Response</h3><article><p>" + $node.innerText + "</p></article></section></main>"
            }
            $path = "$PSScriptRoot\TPO\$($xmlFile.Name.Substring(0,5))"
            New-Item $path -ItemType "Directory" -ErrorAction SilentlyContinue
            if($text) 
            { 
                New-Html ($text -replace "<p></p>", "" -replace "</main><main>", "") "$path\$($xmlFile.Name.TrimEnd(".xml")).html"
            }
        }
    }
}

function Set-TPO ()
{
    for ($n = 1; $n -le 1; $n++) 
    {
        $tpoNumber = $n
        if ($tpoNumber -lt 10) {$tpoNumber = "0$tpoNumber"}
        
        $mp3Files = Get-ChildItem "$PSScriptRoot\TPO\TPO$tpoNumber\??????.mp3" -Recurse
        foreach ($mp3File in $mp3Files) 
        {
            $path = $mp3File.FullName.Replace('.mp3', "") + ".html"
            $content = Get-Content $path
            [xml]$xml = $content
            $node = (Select-Xml "//section[@id=`"Listening Text`"]" $xml).Node
            $audio = $xml.CreateElement('audio')
            $audio.InnerText = ""
            $audio.SetAttribute('src', $mp3File.Name)
            $audio.SetAttribute('controls', 'controls')
            $node.InsertBefore($audio, $node.FirstChild)
            (Format-Xml $xml) | Out-File $path
        }
    }
}
$global:folder = "$HOME\Downloads\ETS\TOEFL Programs"
$global:projectPath = "$HOME\Downloads\ETS\TOEFL Programs\Sampler\forml1"
#Get-Barrons
#Get-TPO
#Set-TPO
$article = "/integrated-toefl-writing-essays/tpo-01-integrated-writing-task-united-states-employees-typically"
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