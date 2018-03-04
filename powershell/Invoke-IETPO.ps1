$global:website = "https://top.zhan.com/toefl"
$article = "1312"
$ie = Start-InternetExplorer "$website/read/practicereview-$article-13.html" ""
$textHtml = $ie.Document.body.getElementsByClassName("text")
while (!$textHtml) { $textHtml = $ie.Document.body.getElementsByClassName("text") }
foreach ($item in $textHtml) {
    if($item.tagName -eq "span") { 
        $passageHtml += $item.outerHTML.Remove($item.outerHTML.Length - 7, 7)
        if($item.parentNode.nextSibling.tagName -eq "br") { 
            $passageHtml += "</p><p>"}
        if($item.firstChild.tagName -eq "img") {
            $item.removeChild($item.firstChild)
            $passageHtml = "<span id=`"arrow`"><span>$passageHtml"
        }
    }
}
$passageHtml = $passageHtml.Replace("<span class=`"text`">", "").Replace("<span class=`"underline`">", "<strong>").Replace("</span>", "</strong>")
Set-Clipboard "<p>$passageHtml".Remove($passageHtml.Length, 3)