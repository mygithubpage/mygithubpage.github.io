<#
(Get-ChildItem "$env:USERPROFILE\Downloads\VSCode\My Code").ForEach{
    Set-Location $PSItem.PSPath
    if (!(Test-Path .\.git))
    {
        $repository = (($PWD.Path -split "\\")[-1]).ToLower().Replace(" ", "-")
        
        git init
        git remote add origin "https://gitlab.com/decisacters/$repository.git"
    }
    
    git add .
    
    if((git status -s).Count -gt 0)
    {
        git commit -m "Update My Script"
        git push -u origin master   
    }
}
#>

<#
# Update jQuery version
----------------------------- Update jQuery version !! TO do !! ---------------------------- 
$html = Invoke-WebRequest "http://jQuery.com"
$jQueryVersion = $html.parsedHtml.querySelector("span.download").nextSibling.nextSibling.textContent
$content = Get-Content .\..\initialize.js
if (($content -like "*jquery*js*" -split "/")[-1] -like "*$($jQueryVersion.TrimStart("v"))*")
{$content -replace ($content -like "*jquery*js*" -split "/")[-1], "jquery-$($jQueryVersion.TrimStart("v")).js\`""}
#>

<#
----------------------------- Update highlight.js version !! TO do !! ---------------------------- 
http://jsbeautifier.org/
https://github.com/beautify-web/js-beautify

<#
$hljsPath = ".\..\highlight.pack.js"
$content = (Get-Content $hljsPath)[0]
$end = $content.indexOf(" |")
$start = $content.indexOf("highlight.js v") + 14
$comment = $content.Substring($start, $end - $start + 1)

$html = Invoke-WebRequest "https://highlightjs.org/"
$version = $html.ParsedHtml.querySelector("#download").innerText.Remove(0,12)

if ($comment -ne $version) {
    $ie = Invoke-InternetExplorer "https://highlightjs.org/download/"
    $ie.Visible = $true
    foreach ($item in $ie.Document.IHTMLDocument3_getElementsByTagName("input")) {
        if(!$item.checked) { $item.click() }
    }

    $ie.Document.IHTMLDocument3_getElementsByTagName("button")[0].click()
    <# Click save button ---- not working
    $obj = new-object -com WScript.Shell
    $obj.AppActivate('Internet Explorer')
    [Microsoft.VisualBasic.Interaction]::AppActivate('Internet Explorer')
    [System.Windows.Forms.SendKeys]::SendWait("S")
    $obj.SendKeys('s')
    #
    $zipPath = "$env:USERPROFILE\Downloads\highlight.zip"
    do {} until (Test-Path $zipPath)

    Expand-Archive $zipPath 
    Copy-Item "highlight\highlight.pack.js" "C:\github\"
    Remove-Item "highlight" -Recurse -Force
    Remove-Item $zipPath
}
#>

#>

<# 
----------------------------- Update CSS ---------------------------- 
# Update CSS
$html = Invoke-WebRequest "https://www.w3schools.com/w3css/4/w3.css"
$css = $html.ParsedHtml.body.innerText
$end = $css.indexOf("*/")
$start = $css.indexOf("/*")
$css = $css.Remove(0,$start)
$comment = $css.Substring($start, $end - $start + 2)
$cssPath = ".\..\w3.css"
$content = (Get-Content $cssPath)[0]

if($content -ne $comment) {
    $ie = Invoke-InternetExplorer "http://www.cssportal.com/format-css/index.php"
    $ie.Document.IHTMLDocument3_getElementsByTagName("textarea")[0].value = $content
    $ie.Document.IHTMLDocument3_getElementById("before_close").value = "nl" # new line
    $ie.Document.IHTMLDocument3_getElementsByTagName("input")[6].click()
    Start-Sleep 2
    Set-Content $cssPath $ie.Document.IHTMLDocument3_getElementsByTagName("textarea")[0].value
}
#>

git add .
git commit -m "Update"
git push -u origin master 
#>