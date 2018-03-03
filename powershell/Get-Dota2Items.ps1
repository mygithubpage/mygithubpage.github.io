. $PSScriptRoot\Utility.ps1
function Get-Dota2Items()
{
    $ie = Start-InternetExplorer "http://steamcommunity.com/profiles/76561198161389877/inventory/#570"
    $links = $ie.Document.links
    while (!$links) { $links = $ie.Document.links }
    $links = $ie.Document.getElementsByTagName('a') 
    $links = $links | ForEach-Object { if($_.ClassName -eq "inventory_item_link" ) {$_} }

    $items = @()
    foreach($link in $links)
    {
        $link.Click()
        Start-Sleep 1
        
        $tags = $ie.Document.getElementById('iteminfo0_item_tags_content').innerText.Split(',')
        $name = $ie.Document.getElementById('iteminfo0_item_name').innerText.TrimStart("$($tags[0]) ")
        $descriptor = $ie.Document.getElementById('iteminfo0_item_descriptors').lastChild.innerText
        
        while ($descriptor.Contains("`r`n`r`n")) {$descriptor = $descriptor -replace "`r`n`r`n", "`r`n"}
        if (!$descriptor.Contains("`r`n`r`n")) { $descriptor = "" }

        $item = New-Object PSObject
        $item | Add-Member -type NoteProperty -name Name -Value $name
        $item | Add-Member -type NoteProperty -name Quality -Value $tags[0]
        $item | Add-Member -type NoteProperty -name Rarity -Value $tags[1]
        $item | Add-Member -type NoteProperty -name Slot -Value $tags[3]
        $item | Add-Member -type NoteProperty -name Hero -Value $tags[4]
        $item | Add-Member -type NoteProperty -name Availibility -Value $tags[5]
        $item | Add-Member -type NoteProperty -name Descriptor -Value $descriptor
        $item | Add-Member -type NoteProperty -name Link -Value $link.href
        
        $items += $item
    }
    # $items | Export-Csv -Path "$PSScriptRoot\Dota2Item.csv"
}
#Get-Dota2Items

#$items  = Import-Csv -Path "$PSScriptRoot\Dota2Item.csv"
#$items | Select-Object Name, Quality, Rarity, Slot, Hero | Sort-Object Hero, Slot | Format-Table

