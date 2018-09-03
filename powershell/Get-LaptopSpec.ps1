
function Remove-Characters($string) 
{
    $character = "[^0-9]"
    while ($string -and $string.Substring(0, 1) -match $character) { $string = $string.Remove(0, 1) } 
    while ($string -and $string.Substring($string.Length - 1, 1) -match $character) { $string = $string.Remove($string.Length - 1, 1) } 
    $string 
}

function Get-LaptopSpec()
{
    $laptops = @()
    $html = Invoke-WebRequest "https://www.intel.com/content/www/us/en/products/devices-systems/laptops/view-all.html?processors=1102"
    
    $products = $html.ParsedHtml.body.getElementsByTagName("div") | 
    ForEach-Object { if ($_.className -eq "content-wrap valign-btm") {$_} }
    
    foreach($product in $products)
    {
        $index = $product.innerText.IndexOf("lbs")
        if ($index -eq -1) 
        {
            $index = $product.innerText.IndexOf("kg")
            if ($index -eq -1) 
            { 
                $index = $product.innerText.IndexOf("g")
                if ($index -eq -1) 
                {
                    $weight = [double] (Remove-Characters $product.innerText.Substring($index - 5, 5)) * 2.2
                }
            }
            $weight = [double] (Remove-Characters $product.innerText.Substring($index - 5, 5)) * 2.2
        }
        else 
        {
            $weight = [double] (Remove-Characters $product.innerText.Substring($index - 5, 5)) 
        }

        if( $weight -lt 3) 
        { 
            
            $link = "https://www.intel.com" + $product.firstChild.nextSibling.firstChild.nextSibling.href.TrimStart("about:")

            $modelName = $link.Split("/")[-1].TrimEnd($link.Split("/")[-1].Split("-")[-1]) -replace "-", " "

            $index = $product.innerText.IndexOf("i7")
            $processor = $product.innerText.Substring($index, $product.innerText.IndexOf(" ", $index) - $index)
            
            $specifications = $product.getElementsByTagName('li')
            foreach($spec in $specifications)
            {
                if ($spec.innerText -like "*`" Screen Size") { $screen = $spec.innerText.TrimEnd("`" Screen Size")}
                if ($spec.innerText -like "* GB Memory") { $memory = $spec.innerText.TrimEnd(" GB Memory")}
            }

            $laptop = New-Object PSObject
            $laptop | Add-Member ModelName $modelName
            $laptop | Add-Member Processor $processor
            $laptop | Add-Member Memory $memory
            $laptop | Add-Member Screen $screen
            $laptop | Add-Member Weight $weight
            $laptop | Add-Member Link $link

            $laptops += $laptop
            remove-variable laptop
        }
    }
    $laptops | Export-Csv -Path "$PSScriptRoot\LaptopSpec.csv"
}
Get-LaptopSpec
$laptops = Import-Csv -Path "$PSScriptRoot\LaptopSpec.csv"
$laptops | Sort-Object Weight
