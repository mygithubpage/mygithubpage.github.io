
. .\Utility.ps1

# Kanto
<#
$base = "https://bulbapedia.bulbagarden.net"
$uri = $base + "/wiki/Kanto"

$html = Get-Html -Name "kanto" -Uri $uri
$locations = $html.links | ForEach-Object {$_.href}
foreach ($item in $locations) {
    
    $link = $base + $item.TrimStart("about:")

    $content = Get-Content .\base.txt
    $path = "Pokemon\" + $link.Split('//')[-1] + ".html"
    New-Item $path | Out-Null
    Set-Content $path $content.replace("Document", $link.Split('//')[-1].replace("_", " "))
    
    $html = Invoke-WebRequest -Uri $link 
    Add-Content $path $html.ParsedHtml.body.getElementsByTagName('table')[0].outerHTML
    Add-Content $path $html.ParsedHtml.getElementById('toc').outerHTML
    if ($link.IndexOf('Gym') -gt 0) {
        
        $heading = $html.ParsedHtml.getElementById('Appearance')
        
        Add-Content $path $heading.parentNode.outerHTML
        $element = $heading.parentNode.nextSibling
        
        while($element.innerText -notlike "Side series") {
            Add-Content $path $element.outerHTML
            $element = $element.nextSibling
        }
        $heading = $html.ParsedHtml.getElementById('Items')
        Add-Content $path $heading.parentNode.outerHTML
        Add-Content $path $heading.parentNode.nextSibling.outerHTML
    }
    else {
        $heading = $html.ParsedHtml.getElementById('Items')
        
        Add-Content $path $heading.parentNode.outerHTML
        $element = $heading.parentNode.nextSibling
        
        # Pokemon and Trainers
        while($true) {
            if ($element.tagName -ne $heading.parentNode.tagName) {
                Add-Content $path $element.outerHTML
                $element = $element.nextSibling
            }
            else {
                if($element.innerText -match "Trainers|Pok.*mon") {
                    Add-Content $path $element.outerHTML
                    $element = $element.nextSibling
                } 
                else {
                    break
                }
            }
            
        }

        $heading = $html.ParsedHtml.getElementById('Layout')
        if ($heading) {
            Add-Content $path $heading.parentNode.outerHTML
            $element = $heading.parentNode.nextSibling
            while($element.tagName -ne $heading.parentNode.tagName) {
                Add-Content $path $element.outerHTML
                $element = $element.nextSibling
            }
        }
    }
    
    $content = Get-Content $path -Encoding "utf8"
    $content = $content.replace('"//cdn', '"https://cdn') 

    Add-Content $path ($content + "</body></html>") -Encoding "utf8"
}
#>

function Update-Character ($string) {
    $string = [regex]::Replace($string, "\u00BC", "&#188;") # ¼
    $string = [regex]::Replace($string, "\u00BD", "&#189;") # ½
    $string = [regex]::Replace($string, "\u00D7", "&#215;") # ×
    $string = [regex]::Replace($string, "\u00E9", "&#233;") # é
    $string = [regex]::Replace($string, "\u2014", "&#8212;") # †
    $string = [regex]::Replace($string, "\u2020", "&#8224;") # ‡
    $string = [regex]::Replace($string, "\u2021", "&#8225;") # ‡
    $string = [regex]::Replace($string, "\u2190", "&#8592;") # ←
    $string = [regex]::Replace($string, "\u2192", "&#8594;") # →
    $string = [regex]::Replace($string, "\u2605", "&#9733;") # ★
    $string = [regex]::Replace($string, "\u2606", "&#9734;") # ☆
    $string = [regex]::Replace($string, "\u2640", "&#9792;") # ♀
    $string = [regex]::Replace($string, "\u2642", "&#9794;") # ♂
    $string = [regex]::Replace($string, "\u2665", "&#9829;") # ♥
    $string
}

$games = "Black and White", "Black 2 and White 2", "Diamond and Pearl", "Platinum", "HeartGold and SoulSilver",  "Emerald", "Ruby and Sapphire", "FireRed and LeafGreen"
$sections = 18,22,33,26,30,21,20,18
for ($j = 0; $j -lt 0; $j++) {
    for ($i = 1; $i -le $sections[$j]; $i++) {
    
        $name = $games[$j] -replace " ", "_"
        $uri = "https://bulbapedia.bulbagarden.net/wiki/Appendix:$($name)_walkthrough/Section_$i"
        $html = Invoke-WebRequest -Uri $uri
    
        $content = Get-Content .\base.txt
        $path = "Walkthrough/$($name)_$i.html"
        
        if (!(Test-Path $path)) { New-Item $path | Out-Null }
        
        Set-Content $path $content.replace("Document", "$($name)_Walkthrough_Section_$i")
        Add-Content $path (Update-Character $html.ParsedHtml.getElementById("mw-content-text").outerHTML)
        
        $content = Get-Content $path
        Set-Content $path $content.replace("src=`"//cdn", "src=`"https://cdn")
        Add-Content $path "</body></html>"
        "$($name)_$i.html"
    }
}
<#
# Pokemon
$base = "https://bulbapedia.bulbagarden.net"
$html = Get-Html -Name "pokedex" -Uri $uri
$pokemons = $html.links | ForEach-Object {
    if($_.href.IndexOf("Pok%C3%A9mon") -gt 0 -and $_.title -match "`(pok.*mon`)" -and 
    $_.href.IndexOf("List_of_Pok%C3%A9mon_by") -lt 0) {$_.href} 
}


foreach ($item in $pokemons[851]) {
    $link = $base + $item.TrimStart("about:")
    
    $content = Get-Content .\base.txt
    $path = "Pokemon\" + $link.Split('//')[-1] + ".html"
    if (!(Test-Path $path)) { New-Item $path | Out-Null }
    Set-Content $path $content.replace("Document", $link.Split('//')[-1].replace("_", " "))
    
    $html = Invoke-WebRequest -Uri $link
    $item.TrimStart("about:")
    Add-Content $path (Update-Character $html.ParsedHtml.body.getElementsByTagName('table')[4].outerHTML)
    Add-Content $path (Update-Character $html.ParsedHtml.getElementById('toc').outerHTML)

    $element = $html.ParsedHtml.getElementById('Pok.C3.A9dex_entries_2')
    Add-Content $path (Update-Character $element.parentNode.outerHTML)
    Add-Content $path (Update-Character $element.parentNode.nextSibling.outerHTML)

    $element = $html.ParsedHtml.getElementById('Game_locations')
    Add-Content $path (Update-Character $element.parentNode.outerHTML)
    Add-Content $path (Update-Character $element.parentNode.nextSibling.outerHTML)
    
    $element = $html.ParsedHtml.getElementById('In_events')
    if($element) {
        Add-Content $path (Update-Character $element.parentNode.outerHTML)
        Add-Content $path (Update-Character $element.parentNode.nextSibling.outerHTML)
    }

    $element = $html.ParsedHtml.getElementById('Held_items')
    if(!$element) { $element = $html.ParsedHtml.getElementById('Stats') }

    Add-Content $path (Update-Character $element.parentNode.outerHTML)
    $element = $element.parentNode.nextSibling

    while($element.innerText -notlike "Learnset") {
        Add-Content $path (Update-Character $element.outerHTML)
        $element = $element.nextSibling
    }
    
    $learnset = $element.nextsibling.nextsibling
    $generations = $learnset.rows(0).innerText.split(":")[1] -replace " `r`n" -split " - "
    if($generations -like "*None*") { $generations = $null }
    foreach ($item in $generations) {
        $learnset = Invoke-WebRequest -Uri "$link/Generation_$($item)_learnset"
        "$link/Generation_$($item)_learnset"
        Add-Content $path ((Update-Character $learnset.ParsedHtml.body.getElementsByTagName('h1')[0].outerHTML) -replace "H1", "H3")

        $element = $learnset.ParsedHtml.getElementById('mw-content-text')
        $element.removeChild($element.firstChild) | Out-Null
        Add-Content $path (Update-Character $element.outerHTML)
    }

    # Learnset
    $element = $html.ParsedHtml.getElementById('Learnset')
    Add-Content $path (Update-Character $element.parentNode.outerHTML)
    $element = $element.parentNode.nextSibling

    while($element.innerText -notlike "Side game data" -and $element.innerText -notlike "Evolution" ) {
        Add-Content $path (Update-Character $element.outerHTML)
        $element = $element.nextSibling
    }

    # Evolotion and Sprites
    $element = $html.ParsedHtml.getElementById('Evolution')
    if(!$element) { $element = $html.ParsedHtml.getElementById('Sprites') }
    Add-Content $path (Update-Character $element.parentNode.outerHTML)
    $element = $element.parentNode.nextSibling


    while($element.innerText -notlike "Trivia" ) {
        Add-Content $path (Update-Character $element.outerHTML)
        $element = $element.nextSibling
    }
    
    
    $content = Get-Content $path -Encoding "utf8"
    Set-Content $path $content.replace("`"//cdn", "`"https://cdn").Replace("LINE-HEIGHT: 10px", "LINE-HEIGHT: 15px") 
    Add-Content $path "</body></html>" -Encoding "utf8"
}

# Items

#>