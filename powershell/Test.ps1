$content = Get-Content "C:\github\gre\notes\test.html" -Encoding UTF8
$content = $content -replace "<hr.*>" -replace "div.*>", "ol>"
$content = $content -replace "strong>", "b>" -replace "<span.*?/span>"
$content = $content -replace "p.*?`">", "li>" -replace "p>", "li>"
Set-Clipboard $content
function Get-ProgID {                       
    #.Synopsis            
    #   Gets all of the ProgIDs registered on a system            
    #.Description            
    #   Gets all ProgIDs registered on the system.  The ProgIDs returned can be used with New-Object -comObject            
    #.Example            
    #   Get-ProgID            
    #.Example            
    #   Get-ProgID.Where{ $_.ProgID -like "*Image*" }             
    param()            
    $paths = @("REGISTRY::HKEY_CLASSES_ROOT\CLSID")            
    if ($env:Processor_Architecture -eq "amd64") {            
        $paths+="REGISTRY::HKEY_CLASSES_ROOT\Wow6432Node\CLSID"            
    }             
    Get-ChildItem $paths -include VersionIndependentPROGID -recurse |            
    Select-Object @{            
        Name='ProgID'            
        Expression={$_.GetValue("")}                    
    }, @{            
        Name='32Bit'            
        Expression={            
            if ($env:Processor_Architecture -eq "amd64") {            
                $_.PSPath.Contains("Wow6432Node")                
            } else {            
                $true            
            }                        
        }            
    }            
}

<#
$content = Get-Content "C:\github\blog\ubuntu\bash-beginners-guide.html"
$content = $content -replace "<tt.*?>(.*?)</tt>", "<code class=`"bash w3-light-gray`">`$1</code>" 
$content = $content -replace "<table.*>", "<table class=`"w3-table-all`">"
$content = $content -replace "<font color=`"\#000000`">" -replace "</font>" -replace "<img.*?>"
$content = $content -replace " align=`"(.*?)`" valign=`"(.*?)`"", " style=`"text-align:`$1;vertical-align:`$2`""
$content = $content -replace " align=`"(.*?)`"", " style=`"text-align:`$1`""
$content = $content -replace "<pre class=.*?>", "<pre class=`"bash w3-panel w3-card w3-leftbar w3-light-gray`">"

Set-Content "C:\github\gre\notes\test.html" $content
#>