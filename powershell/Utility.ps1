Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName Microsoft.VisualBasic


function ConvertTo-UnicodeNumber {
    param($character)

    function ConvertTo-HexNumber {
        param($number)
        $number = '{0:X}' -f [int]$number
        $number = if ($number.Length -lt 2) { "0$number" } else { $number }
        $number
    }
    
    $byteString = "$([Text.Encoding]::Unicode.GetBytes($character))"
    $characters = $_
    for ($i = 0; $i -lt $byteString.Split(" ").Count; $i += 2) {
        $byte1 = $byteString.Split(" ")[$i]
        $byte2 = $byteString.Split(" ")[$i + 1]
        $character = $character -replace $characters , ($prefix + (ConvertTo-HexNumber $byte2) + (ConvertTo-HexNumber $byte1))
    }
    $character
}

function Invoke-InternetExplorer {
    Param($Uri, $Condition)
    foreach ($item in (New-Object -COM "Shell.Application").Windows()) {
        if($item.Name -like "*Internet Explorer*") {
            $ie = $item
        }
    }

    if (!$ie) { $ie = New-Object -ComObject InternetExplorer.Application }
    if ($ie.LocationURL -ne $Uri) { $ie.Navigate($Uri) }
    $flag = $false
    while ($ie.Busy -and !$flag) { 
        Start-Sleep -Milliseconds 100 
        if($Condition) { Invoke-Expression $Condition}
        if($flag) { break }
    }
    $ie
}

function Get-Translation {
    param (
        $Content
    )
    
    function Start-Translation {
        param ($Content, $Count)
        if (!$Count) { 
            $textarea.value = $Content
            $ie.Document.IHTMLDocument3_getElementById("gt-submit").click() 
        }
        do { 
            if (!$textarea.value) { $textarea.value = $Content }
            Start-Sleep -Milliseconds 1500 
            $result = $ie.Document.IHTMLDocument3_getElementById("result_box")
            if ($Count -lt 2) { $Count++ }
            elseif ($Count -ge 2) { return }

        } until ($result.innerText -and !$result.innerText.Contains("Translating...") )

        $result.innerText
    }
    do {
        Start-Sleep 1
        $textarea = $ie.Document.IHTMLDocument3_getElementById("source")
        if ( $ie.Document.Title.Contains("connect securely to this page") ) {
            $ie.Navigate("https://translate.google.cn/#zh_CN/en")
        }
    } until ($textarea)

    do {
        Start-Sleep 1
        $textarea.value = $Content
    } until ($textarea.value)

    if (!$ie.LocationURL.Contains("#zh-CN")) { 
        if ($ie.LocationURL.Split("/")[3]) { 
            $ie.Navigate($ie.LocationURL.Replace($ie.LocationURL.Split("/")[3], "#zh-CN")) 
        }
    }

    $ie.Document.IHTMLDocument3_getElementById("gt-submit").click()
    $translation = Start-Translation $Content 0

    if (!$translation) { 
        $translation = Start-Translation $Content 0
    }

    if ($result.innerText -match "[\u4E00-\u9FFF]") {
        $result.innerText
    }
    
    $translation
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

function Add-XmlNode {
    # Example: Add-XmlNode ($tag, @{attribute = $value}, $innerXml) $before | Out-Null
    # $tag = $Node[0], $attributes = $Node[1], $innerXml = $Node[2]
    Param($Node, $Parent, $Before)
    if (!$Parent) { $Parent = $Xml }

    if ($Node.Count -gt 1) {
        $element = $Parent.OwnerDocument.createElement($Node[0])
        if ($Node[1].GetType().Name -eq "Hashtable") {
            foreach ($attribute in $Node[1].GetEnumerator()) { 
                $element.SetAttribute($attribute.Name, $attribute.Value) 
            }

            if ($Node[2]) {
                if ($Node[2].Contains("</") -or $Node[2].Contains("</")) { $element.InnerXml = $Node[2] }
                else { $element.InnerXml = $Node[2] }
                $element.InnerXml = $Node[2]
            }
            else {
                $element.InnerText = ""
            }
        }
        elseif ($Node[1].GetType().Name -eq "String") {
            $element.InnerXml = $Node[1]
        }

    }
    else {
        $element = $Parent.OwnerDocument.createElement($Node)
        $element.InnerText = ""
    }

    if (!$Before) {$element = $Parent.appendChild($element)}
    else {
        $element = $Parent.InsertBefore($element, $Parent.FirstChild)
    }
    
    $element
}

function Format-Html { 
    Param([xml]$Xml, $Indent=2)
    $StringWriter = New-Object System.IO.StringWriter 
    $XmlWriter = New-Object System.XMl.XmlTextWriter $StringWriter 
    $xmlWriter.Formatting = "indented"
    $xmlWriter.Indentation = $indent 
    $xml.WriteContentTo($XmlWriter) 
    $XmlWriter.Flush() 
    $StringWriter.Flush() 
    $String = $StringWriter.ToString()
    $String -replace "(?<=<p>)`r`n\s+"
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
    Select-String $regex $path.ForEach$parseString
    $content
}

function Get-Html {
    Param($Uri, $Name="test")  
    
    if (!(Test-Path -Path $PSScriptRoot\$Name.html))
    {
        $html = Invoke-WebRequest -Uri $Uri -OutFile $PSScriptRoot\$Name.html
    }

    $html = New-Object -ComObject "HTMLFile"
    $html.IHTMLDocument2_write($(Get-Content -Path $PSScriptRoot\$Name.html -Raw ))
    $html
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

# slow
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

# usage?
function Wait-FileUnlock {
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
 