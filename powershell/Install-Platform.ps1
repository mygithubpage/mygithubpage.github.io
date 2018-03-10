# Node.js

$name = "Node.js"
$path = "C\$name"
$installer = "$HOME\Downloads\$name.msi"
if (!(Test-Path $path)) 
{ 
    if (!(Test-Path $installer)) 
    {
        Write-Host "`nDownloading $name..."
        $html = Invoke-WebRequest "https://nodejs.org/en/"
        $link = $html.ParsedHtml.body.getElementsByClassName("home-downloadbutton")[1].href
        $uri = $link + "node-$($link.Split("/")[-2])-x64.msi"
        Invoke-WebRequest $uri -OutFile $installer
        while (!(Test-Path $installer)) {}
    }
    else 
    {
        Write-Host "`n$name is already downloaded."
    }
    Write-Host "`nInstalling $name..."
    Invoke-Item $installer 
}