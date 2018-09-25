$prefix = '<svg width="640" height="480" xmlns="http://www.w3.org/2000/svg">

 <defs>
 '
$suffix = '
 </defs>
 <g>
  <use href="#svg_folder" x="-80" y="-80"/>
  <use href="#svg_file" x="40" y="40"/>
 </g>
</svg>'

$ext = "powershell" # choose color
$svgs = "", "_opened"
$colors = "#2b5797", "#2d89ef" # choose color
$directory = "$env:USERPROFILE\.vscode\extensions\robertohuertasm.vscode-icons-*\icons"
for ($i = 0; $i -lt $svgs.Count; $i++) {
    $svg = $prefix
    for ($j = 0; $j -lt 2; $j++) {
        $path = if($j -eq 0) {"$directory\default_folder$($svgs[$i]).svg"} else {"$directory\file_type_$ext.svg"}
        $type = if($j -eq 0) {"folder"} else {"file"}
        $file = Get-ChildItem $path
        $content = Get-Content $file
        $content = $content -replace "<svg", "<symbol id=`"svg_$($type)`""
        $content = $content -replace "svg>", 'symbol>'
        if($j -eq 0) { $content = $content -replace "fill:#\w{6}", "fill:$($colors[$i])"} 
        $svg += $content
    }
    $svg += $suffix
    Set-Content "$env:APPDATA\Code\User\vsicons-custom-icons\folder_type_$ext$($svgs[$i]).svg" $svg
}