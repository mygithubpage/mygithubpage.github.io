
exit

#region # Array 

# Create Array of Object 
$array = @() # Create Empty Array
$property = ""
$element = New-Object PSObject
$element | Add-Member Property $property
$element | Add-Member @{Property1 = $property1; Property2 = $property2}
$array += $element
#https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/add-member?view=powershell-6

# Array Operation
$animals = "cat", "dog", "bat"  # Create animal Array with 3 Elements
$animals += "bird" # Add one Element
$animals[0..1] # Get Continous Elements
$animals[-1] # Get the last element
$animals -ne 'cat' # Get Elements
$animals -like '*a*' # Find Elements
[array]::Reverse($animals)

# Assigning Values to Multiple Variables in an Array #
$items = "Doug", "Finke", "NY", "NY", 10017
$FirstName, $LastName, $Rest = $items # $FirstName = Doug; $LastName = Finke; $Rest = NY NY 10017 (Array)

#endregion


#region # String 

# Use Single Quotes to Quoting Double Quotes 
$s = "PowerShell" 
"A string with a variable: $s" # A string with a variable: PowerShell
"A string with a variable: $($s.ToLower())" # Use $() in Variable Property Dereference in Double Quotes

"A string with 'Quotes'" # A string with 'Quotes'
"A string with `"Escaped Quotes`"" # A string with "Escaped Quotes"
'Variables are not replaced inside single quotes: $s' # Variables are not replaced inside single quotes: $s

# Use -match to search so regular expression is available 
"Regular Expression" -match "Reg.*Ex.*"


# Regular Expression

# Regular Expression Language - Quick Reference https://docs.microsoft.com/en-us/dotnet/standard/base-types/regular-expression-language-quick-reference
$regex = "\s+const\s+(?<type>.*)\s+(?<name>.*)\s+=\s+(?<value>.*);" # (?<name>subexpression)
$parseString = {
    foreach ($match in $PSItem.Matches) {
        # Match https://docs.microsoft.com/en-us/dotnet/api/system.text.regularexpressions.match
        New-Object PSObject -Property @{
            Name  = $match.Groups["name"].Value
            Value = $match.Groups["value"].Value
            Type  = $match.Groups["type"].Value            
        }
    }
} 
Select-String $regex $cspath.ForEach$parseString

# Search and repalce words
$regex = "`"word`":`"(?<word>.*?)`",(`"hw`":true,)?(`"parent`":`"(?<parent>.*?)`")?"
foreach ($match in ($text | Select-String $regex -AllMatches -CaseSensitive).Matches) {
    $text = $text -replace $oldText, $newText
    New-Object PSObject -Property @{ Word = $match.Groups["word"].Value; Parent = $match.Groups["parent"].Value}
}

# Replace Unicode Character
$string = $string -replace "\u2192", "&#8594;" # →
$string = $string -replace "([A-F])(\w)", " `$1 `$2" 
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comparison_operators?view=powershell-6#substitutions-in-regular-expressions

#endregion


#region # CIM

# https://docs.microsoft.com/en-us/powershell/scripting/whats-new/breaking-changes-ps6?view=powershell-6#wmi-v1-cmdlets
Start-Service winrm # Run as administrator
Get-CimInstance # CIM aka WMI v2
Get-CimInstance Win32_BIOS
Get-CimInstance Win32_ComputerSystem
Get-CimInstance Win32_Processor
Get-CimInstance Win32_OperatingSystem # 
Get-CimInstance Win32_LocalTime
(Get-CimInstance Win32_LogicalDisk).Size[0] / (2 -shl 29) # GB

Get-CimClass *Network*
Get-CimInstance Win32_NetworkAdapterConfiguration
(Get-CimInstance Win32_NetworkAdapterConfiguration).Where{$_.IPEnabled -eq $true} | Format-Table IPAddress
# https://docs.microsoft.com/en-us/windows/desktop/CIMWin32Prov/win32-provider

#endregion


#region # Cmdlet

Get-Command -Noun Process
Get-Command -Noun Service
Get-Command -Noun Location
Get-Command -Noun Item

# Item Command
Rename-Item $path $newName # this cmdlet can not change the item's directory
Move-Item $path $destination  # this cmdlet can change the item's directory and it's name
Copy-Item $path $destination -Recurse # this cmdlet can change item's name
Remove-Item $path -Recurse

# Registry
$keys = Get-ItemProperty "HKLM:\SOFTWARE\$name"
$keys.Property = $value

# PnpDeice
(Get-PnpDevice).Where{ $_.FirendlyName -match $regex} | Disable-PnpDevice -Confirm:$false | Enable-PnpDevice -Confirm:$false

Set-ExecutionPolicy Undefined # to run powershell script

# Dynamically Call different Function
Invoke-Expression "Get-$name `$argument"

# https://docs.microsoft.com/en-us/powershell/developer/cmdlet/approved-verbs-for-windows-powershell-commands
Get-Verb

#endregion


#region # Misc.
# Variable use camelCase (first letter is lowercase)
$camel
$camelCase

# Script Block {} can be Assign to a Variable and Use the Variable to Replace Script Block for Parameter
$name = {$PSItem.Name}
Get-Process.ForEach$name

# Hash Table can be used to replace Parameter List 
$parameters = @{Filter = "D*"; Depth = 1; Recurse = $true}
Get-ChildItem @parameters

# Pipeline Operator can be an indicator of line breaker
Get-ChildItem -Path $env:windir\*.log |
    Select-String -List error |
    Format-Table Path, LineNumber -AutoSize

# First Letter Uppercase
(Get-Culture).TextInfo.ToTitleCase($category)

# Get MD5 Checksum
$fileHash = Get-FileHash $iso -Algorithm MD5
$fileHash.Hash
[regex]::Unescape("\u2013")
#endregion


#region # .Net Object

# FolderBrowserDialog https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.folderbrowserdialog
#using namespace System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms

$folderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog # Create
$folderBrowserDialog.SelectedPath = $initialDirectory # Set Folder
#$folderBrowserDialog.ShowDialog() | Out-Null # Show Folder
$folderBrowserDialog.SelectedPath # Get Selected Folder Path in String

# Create new .net object and use method
$xml = [xml] [System.Net.WebClient]::new().DownloadString('http://www.microsoft.com/')  

# create form with initial value
$form = [Form] `
@{
    Text = 'My First Form'
}
$button = [Button] `
@{
    Text = 'Push Me!'
    Dock = 'Fill'
}
$button.add_Click{$form.Close()}

$form.Controls.Add($button)

#endregion


<#
	1. Start your scripts with a standard set of comments (name, date, author, purpose and keywords) to easily find them later.
	2. Add comments as much as possible, but not too much.
	3. Use the #Requires tag for the minimum version of Windows PowerShell required, required Modules, PSSnapin or Administrative rights.
	4. Use the Set-StrictMode -Version Latest command to ensure that you cannot reference things such as  uninitialized variables and non-existent properties of an object.
	5. Use simple but meaningful variable names. (e.g. $ServiceName or $Counter, and not $s and $c).
	6. Place user-defined variables at the top of script. It makes it easier for you or anyone making changes to those script variables.
	7. Use code signing (and the RemoteSigned or AllSigned execution policy).
	8. Don't use aliases in scripts. Use the full cmdlet name with its named parameters.
	9. Avoid using backticks, they are easy to miss since they might look like dirt on the screen. Instead, use the pipeline (|) character where appropriate, or even splatting the parameters to the cmdlet.
	10. "Filter left, format right".
	11. Add the .exe extension to external commands and applications (e.g. there is a big difference between sc and sc.exe).
	12. Don't turn off pipeline errors ($ErrorActionPreference = "SilentlyContinue"). Implement structured error handling by using Try+Catch+Finally (or Trap) to handle errors.
	13. Do not "pollute" the Windows PowerShell environment by changing preference variables globally (e.g. $ConfirmPreference, $WhatIfPreference, etc.).
	14. Use cmdletBinding and add support for the -WhatIf, -Verbose and -Debug parameters.
	15. Use Advanced Functions.
	16. Use the Verb-Noun naming convention for your functions and filters. When picking out verbs, always use standard verbs. Use Get-Verb to see what verbs are available.
	17. Use standard parameter naming (e.g. ComputerName and not Machine or Server), and set them a default value if relevant (e.g. $ComputerName = $ENV:ComputerName).
	18. A function should do one thing, and do it well.
	19. A function should always return an object or array of objects, not formatted text.
	20. Avoid using the Return keyword. Functions automatically return output to the calling process through the pipeline.
	21. Avoid using Write-Host. It writes to the host, not the pipeline. Prefer using Write-Output over using Write-Host. Write-Host writes to the host, not the pipeline.
	22. Use comment-based help. The minimum items to add are the Synopsis, Description, and Example nodes.
	23. Use Test-Connection (with the -Quiet switch) to ensure a computer is online prior to connecting to it.
	24. Make sure your script is lined up, indented properly, and easy to read. If you can read and understand your script, you will simplify your debugging process.
	25. Keep your script independent from the place you run it (Use $myInvocation.MyCommand.Path or $PSScriptRoot for PowerShell 3.0 and above).
	26. Make sure you test your functions and scripts in a clean environment with no dependencies on profiles, admin rights, and versions to ensure compatibility.
	27. Test scripts in test environment before they are released to production.
	28. Re-use scripts (Package modules, create a script repository).
	29. Implement some processes around script lifecycle (change process)
	    Who can request the creation of scripts?
	    Who is responsible for writing the scripts?
	    Who is responsible for maintaining the scripts?
	    Who is responsible for reviewing (quality control) the scripts?
	30. Follow a simple but organized script flow:
	    #Requires comments
	    Define your params
	    Create your functions
	    Setup any variables
	    Run your code
        Comment based help
#>