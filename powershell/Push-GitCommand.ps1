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
$html = Invoke-WebRequest "http://jQuery.com"
$jQueryVersion = $html.parsedHtml.querySelector("span.download").nextSibling.nextSibling.textContent
$content = Get-Content .\..\initialize.js
if (($content -like "*jquery*js*" -split "/")[-1] -like "*$($jQueryVersion.TrimStart("v"))*")
{$content -replace ($content -like "*jquery*js*" -split "/")[-1], "jquery-$($jQueryVersion.TrimStart("v")).js\`""}
#>

#$content = Get-Content .\..\initialize.js
#$content -like "*/github*")
<#
if (($content -like "*/github*" -split "/")[-1] -like "*$($jQueryVersion.TrimStart("v"))*")
{$content -replace ($content -like "*jquery*js*" -split "/")[-1], "jquery-$($jQueryVersion.TrimStart("v")).js\`""}
#>

# 31S4 31S6 36L5

git add .
git commit -m "Update"
git push -u origin master 
#>