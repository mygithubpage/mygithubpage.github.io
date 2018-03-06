
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName Microsoft.VisualBasic


Function Wait-FileUnlock {
    Param(
        [Parameter()]
        [IO.FileInfo]$File,
        [int]$SleepInterval=500
    )
    while($true){
        try{
            $fs=$file.Open('open','read', 'Read')
            $fs.Close()
            return
        }
        catch{
            Start-Sleep -Milliseconds $SleepInterval
        }
	}
}

function Get-Html {
    <#
    .SYNOPSIS
    Short description
    
    .DESCRIPTION
    Long description
    
    .PARAMETER Name
    Parameter description
    
    .PARAMETER Uri
    Parameter description
    
    .EXAMPLE
    An example
    
    .NOTES
    General notes

    #>
    Param($Uri, $Name="test")  
    
    if (!(Test-Path -Path $PSScriptRoot\$Name.html))
    {
        $html = Invoke-WebRequest -Uri $Uri -OutFile $PSScriptRoot\$Name.html
    }

    $html = New-Object -ComObject "HTMLFile"
    $html.IHTMLDocument2_write($(Get-Content -Path $PSScriptRoot\$Name.html -Raw ))
    $html
}

function Resize-Image {
   <#
    .SYNOPSIS
        Resize-Image resizes an image file

    .DESCRIPTION
        This function uses the native .NET API to resize an image file, and optionally save it to a file or display it on the screen. You can specify a scale or a new resolution for the new image.
        
        It supports the following image formats: BMP, GIF, JPEG, PNG, TIFF 
 
    .EXAMPLE
        Resize-Image -InputFile "C:\kitten.jpg" -Display

        Resize the image by 50% and display it on the screen.

    .EXAMPLE
        Resize-Image -InputFile "C:\kitten.jpg" -Width 200 -Height 400 -Display

        Resize the image to a specific size and display it on the screen.

    .EXAMPLE
        Resize-Image -InputFile "C:\kitten.jpg" -Scale 30 -OutputFile "C:\kitten2.jpg"

        Resize the image to 30% of its original size and save it to a new file.

    .LINK
        Author: Patrick Lambert - http://dendory.net
    #>
    Param([Parameter(Mandatory=$true)][string]$InputFile, [string]$OutputFile, [int32]$Width, [int32]$Height, [int32]$Scale, [Switch]$Display)

    # Add System.Drawing assembly
    Add-Type -AssemblyName System.Drawing

    # Open image file
    $img = [System.Drawing.Image]::FromFile((Get-Item $InputFile))

    # Define new resolution
    if($Width -gt 0) { [int32]$new_width = $Width }
    elseif($Scale -gt 0) { [int32]$new_width = $img.Width * ($Scale / 100) }
    else { [int32]$new_width = $img.Width / 2 }
    if($Height -gt 0) { [int32]$new_height = $Height }
    elseif($Scale -gt 0) { [int32]$new_height = $img.Height * ($Scale / 100) }
    else { [int32]$new_height = $img.Height / 2 }

    # Create empty canvas for the new image
    $img2 = New-Object System.Drawing.Bitmap($new_width, $new_height)

    # Draw new image on the empty canvas
    $graph = [System.Drawing.Graphics]::FromImage($img2)
    $graph.DrawImage($img, 0, 0, $new_width, $new_height)

    # Create window to display the new image
    if($Display)
    {
        Add-Type -AssemblyName System.Windows.Forms
        $win = New-Object Windows.Forms.Form
        $box = New-Object Windows.Forms.PictureBox
        $box.Width = $new_width
        $box.Height = $new_height
        $box.Image = $img2
        $win.Controls.Add($box)
        $win.AutoSize = $true
        $win.ShowDialog()
    }

    # Save the image
    if($OutputFile -ne "")
    {
        $img2.Save($OutputFile);
    }
}

function Initialize-SendKeys{
    Param($programName, $seconds)
    Start-Sleep $seconds
    [Microsoft.VisualBasic.Interaction]::AppActivate($programName)
}

function Send-Keys {
    Param($string, $seconds)
    Start-Sleep $seconds
    [System.Windows.Forms.SendKeys]::SendWait($string)
}

function Submit-Website {
    
    Param($Uri, $selector, $credential)
    $ie = Start-InternetExplorer $Uri

    # Get Account, Password Input and SignIn Button, fill in and sig in
    $signInButton = $null
    while($ie.Busy) { Start-Sleep -Milliseconds 1000 }
    while($signInButton -eq $null) {$signInButton = $ie.Document.querySelector($selector.signin)}
    $ie.Document.querySelector($selector.account).value = $credential.account
    $ie.Document.querySelector($selector.password).value = $credential.account
    $ie.Document.querySelector($selector.signin).click()
}

function Invoke-InternetExplorer {
    Param($Uri)
    $ie = (New-Object -COM "Shell.Application").Windows() | ForEach-Object { if($_.Name -like "*Internet Explorer*") {$_}}

    Get-Process -Name iexplore -ErrorAction Ignore | Stop-Process
    $ie = New-Object -ComObject InternetExplorer.Application
    if (!$ie) { $ie = New-Object -ComObject InternetExplorer.Application }
    if ($ie.LocationURL -ne $Uri) { $ie.Navigate($Uri) }

    while ($ie.Busy) { Start-Sleep -Milliseconds 100 }
    <#
    $ie.Visible = $true
    Initialize-SendKeys "Internet Explorer" 0
    Send-Keys "% " 1
    Send-Keys "x" 1
    #>
    $ie
}

function Format-Xml { 
    Param([xml]$Xml, $Indent=4)
    $StringWriter = New-Object System.IO.StringWriter 
    $XmlWriter = New-Object System.XMl.XmlTextWriter $StringWriter 
    $xmlWriter.Formatting = "indented"
    $xmlWriter.Indentation = $indent 
    $xml.WriteContentTo($XmlWriter) 
    $XmlWriter.Flush() 
    $StringWriter.Flush() 
    $StringWriter.ToString()
}

function New-Html {
    param($Content, $Path) 
    $xml = ConvertTo-Xml -InputObject $xml
    $xml.RemoveAll()

    # Create html Node and Set Attribute lang="en" <html lang="en"></html>
    $htmlNode = $xml.CreateElement("html")
    $htmlNode.innerText = ""
    $htmlNode.SetAttribute("lang", "en")
    $htmlNode = $xml.AppendChild($htmlNode)

    # Create head Node
    $headNode = $xml.CreateElement("head")
    $headNode.innerText = ""
    $htmlNode.AppendChild($headNode) | Out-Null

    # Create meat Node and Set attribute charset="UTF-8" <meta charset="UTF-8">
    $metaNode = $xml.CreateElement("meta")
    $metaNode.SetAttribute("charset", "utf-8") 
    $headNode.AppendChild($metaNode) | Out-Null

    # Create meat Node and Set Attributes to view in mobile device
    $metaNode = $xml.CreateElement("meta")
    $metaNode.SetAttribute("name", "viewport") 
    $metaNode.SetAttribute("content", "width=device-width, initial-scale=1.0")
    $headNode.AppendChild($metaNode) | Out-Null

    # Create title Node and Add title
    $titleNode = $xml.CreateElement("title")
    $titleNode.innerText = $Title
    $headNode.AppendChild($titleNode) | Out-Null

    # Create body Node
    $bodyNode = $xml.CreateElement("body") 
    $bodyNode.innerText = ""
    $htmlNode.AppendChild($bodyNode) | Out-Null

    # Add Content
    $cdata = $xml.CreateCDataSection($Content)
    $bodyNode.AppendChild($cdata) | Out-Null
    $xml.InnerXml = $xml.InnerXml.Replace("<![CDATA[", "").Replace("]]>", "")
    $string = (Format-Xml $xml 2).Tostring()
    ("<!DOCTYPE html>`n" + $string) | Out-File $Path -Encoding "utf8"
    $xml
}

function Update-Entity {
    param($Path, $Type)
    $content = ""
    foreach ($line in (Get-Content $Path)) {
        $content += $line + "`n"
    }

    if ($type -eq "Add") {
        $regex = "&(?<entity>.*?);" # (?<name>subexpression)
    }
    else {
        $regex = "%(?<entity>.*?)%"
    }
    
    $parseString = 
    {
        foreach ($match in $_.Matches) {
            if ($type -eq "Add") {
                $newValue = "%$($match.Groups["entity"].Value)%"
            }
            else {
                $newValue = "&$($match.Groups["entity"].Value);"
            }
            
            $content = $content -replace $match.Value, $newValue
        }
    } 
    Select-String $regex $path | ForEach-Object $parseString
    $content
}

function Get-AllIndexesOf {
    Param($string, $value)
    $indexes = @()
    for ($index = 0; ; $index += $value.Length) 
    {
        $index = $string.IndexOf($value, $index)
        if ($index -eq -1) {break}
        $indexes += $index
    }
    $indexes

}


