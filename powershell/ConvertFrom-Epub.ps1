function Expand-Epub {
    param (
        $Source,
        $Destination
    )
    Copy-Item $Source "$Destination.zip"
    Expand-Archive "$Destination.zip" $Destination 
    Remove-Item "$Destination.zip"
}

(Get-ChildItem "$env:USERPROFILE\Box Sync\GRE Books\*.epub").ForEach{
    $folder = "C:\github\temp\ebooks"
    $dir = $_.BaseName -replace "\.", " "
    if (!(Test-Path "$folder\$dir")) {
        Write-Host $dir
        Expand-Epub $_.FullName "$folder\$dir"
    }
    else {
        $xml = [xml](Get-Content "$folder\$dir\META-INF\container.xml")
        $opf = $xml.container.rootfiles.rootfile.'full-path'
        $xml = [xml](Get-Content "$folder\$dir\$opf")
    }
}
