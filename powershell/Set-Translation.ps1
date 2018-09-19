. $PSScriptRoot\Utility.ps1


function Start-ComObject {
    param($path)

    Invoke-ComObject {
        param($com)
    }
    
    # select object
    if ( $path.Split(".")[-1] -match "xls") {
        $comObject = "Excel.Application"
    }
    elseif ($path.Split(".")[-1] -match "doc") {
        $comObject = "Word.Application"
    }
    elseif ($path.Split(".")[-1] -match "doc") {
        $comObject = "Powerpoint.Application"
    }

    $com = New-Object -ComObject $comObject
    $com.Visible = $true

    Invoke-ComObject $com

    $com.Quit() 
    [void][Runtime.Interopservices.Marshal]::ReleaseComObject($com)
}

function Set-Translation {
    param (
        $path
    )
    
    # replace Chinese with English
    function Edit-Content {
        param($content)

        ($content | Select-String $pattern -AllMatches).Matches.Value.ForEach{
            $translation = Edit-TranslationTable $path.split("\")[-1] $_
            $content = $content -replace $_, $translation
        }
        $content
    }


    # Get Chinese 
    if ( $path.Split(".")[-1] -match "xls|doc|ppt") {
        Start-ComObject $path
    }
    else {
        $content = Get-Content $path -Raw -Encoding UTF8
        $content = Edit-Content $content
        Set-Content $path $content -Encoding UTF8
    }
}

function Edit-TranslationTable {
    param (
        $file,
        $content
    )

    # create html
    $parts = $file.Split(".")
    $name = $parts[0..($parts.Length - 2)] -join "."
    $path = "$PSScriptroot\html\$name.html"
    if (!(Test-Path $path)) { New-Item $path | Out-Null}

    # Create Translation table
    $html = [xml]((Get-Content $path) -replace "&#")
    $table = (Select-Xml "//table" $html).Node
    if (!$table) { 
        $table = Add-XmlNode ("table", @{class="w3-table-all w3-section"}) (Select-Xml "//main" $html).Node
        $tr = Add-XmlNode ("tr", @{class="my-color"}) $table
        Add-XmlNode ("td", "Chinese") $tr
        Add-XmlNode ("td", "English") $tr
    }

    # Get unicode

    $content.ToCharArray().ForEach{
        if ($_ -match $group) { 
            $unicode += "&x" + (ConvertTo-UnicodeNumber $_) + ";"
        }
        else {
            $unicode += $_
        }
    }
    $id = $unicode -replace "&" -replace ";"

    # Get-Translateion if no translation in table
    if (!(Select-Xml "//tr[@id=`"$id`"]" $html).Node) {
        
        $translation = Get-Translation $content

        # Create table row
        $tr = Add-XmlNode ("tr", @{id=$id}) $table 
        Add-XmlNode ("td", ($unicode -replace "&")) $tr
        Add-XmlNode ("td", $translation) $tr
    }
    
    $html = $html.OuterXml
    $html = $html -replace "x([A-F0-9]{4};)", "&#x`$1"
    Set-Content $path $html
    
    $translation
}


$ie = Invoke-InternetExplorer "https://translate.google.cn/#zh_CN/en"

$global:group = "\p{IsCJKUnifiedIdeographs}|\p{IsHalfwidthandFullwidthForms}|\p{IsEnclosedAlphanumerics}"
$global:pattern = "($group)+" # Select String Literal with chinese character

(Get-ChildItem "$PSScriptRoot\file\" -Recurse -File).ForEach{
    $file = $_
    Edit-TranslationTable "translation.html" "$([char]0x9500)$([char]0x552E).vb" | Out-Null
    if ($file.Name -match $pattern) {
        $translation = Edit-TranslationTable "translation.html" $file.Name
        Set-Translation $_
        Rename-Item $_ $translation
    }
}