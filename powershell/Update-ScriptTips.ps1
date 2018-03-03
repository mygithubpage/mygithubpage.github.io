
#region # .Net Object

# FolderBrowserDialog https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.folderbrowserdialog
using namespace System.Windows.Forms
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


#region # ComObject 

# Word
$word = New-Object -ComObject Word.Application 
$file = $word.Documents.Add()
$range = $file.Content
$range.Find.Execute("<h?>*</h?>", $default, $default, $true) | Out-Null

# WdParagraphAlignment Enumeration
$range.ParagraphFormat.Alignment = 1 # Center-Alighed
# https://msdn.microsoft.com/en-us/vba/word-vba/articles/wdparagraphalignment-enumeration-word

$file.Content = $range.Paragraphs(1).Range.Text
#$file.SaveAs2($name)
$word.Quit() 
[void][Runtime.Interopservices.Marshal]::ReleaseComObject($word)

#endregion


#region # PowerShell Object 

# Test-CSharpFiles.ps1
# MatchInfo https://msdn.microsoft.com/en-us/library/microsoft.powershell.commands.matchinfo(v=vs.85).aspx
# Regular Expression Language - Quick Reference https://docs.microsoft.com/en-us/dotnet/standard/base-types/regular-expression-language-quick-reference
$regex = "\s+const\s+(?<type>.*)\s+(?<name>.*)\s+=\s+(?<value>.*);" # (?<name>subexpression)
$parseString = 
{
    foreach($match in $PSItem.Matches) # Match https://docs.microsoft.com/en-us/dotnet/api/system.text.regularexpressions.match
    {
        New-Object PSObject -Property `
        @{
            Name     = $match.Groups["name"].Value
            Value    = $match.Groups["value"].Value
            Type     = $match.Groups["type"].Value            
        }
    }
} 
Select-String $regex $cspath | ForEach-Object $parseString

# Replace Unicode Character
$string = [regex]::Replace($string, "\u2192", "&#8594;") # →

#endregion


#region # Array 

# Create Array of Object 
$array = @() # Create Empty Array
$property = ""
$element = New-Object PSObject
$element | Add-Member -type NoteProperty -name Property -Value $property
$array += $element

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

#endregion


# Variable use camelCase (first letter is lowercase)
$camel
$camelCase

# Script Block {} can be Assign to a Variable and Use the Variable to Replace Script Block for Parameter
$name = {$PSItem.Name}
Get-Process | ForEach-Object $name

# Hash Table can be used to replace Parameter List 
$parameters = @{Filter = "D*"; Depth = 1; Recurse = $true}
Get-ChildItem @parameters

# Pipeline Operator can be an indicator of line breaker
Get-ChildItem -Path $env:windir\*.log |
Select-String -List error |
Format-Table Path,LineNumber �AutoSize

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
	12. Don’t turn off pipeline errors ($ErrorActionPreference = "SilentlyContinue"). Implement structured error handling by using Try+Catch+Finally (or Trap) to handle errors.
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