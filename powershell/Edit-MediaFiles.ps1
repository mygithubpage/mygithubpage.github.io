
function Edit-MediaFile () {
    [Reflection.Assembly]::LoadFrom( (Resolve-Path "$PSScriptRoot\taglib-sharp.dll"))
    $files = Get-ChildItem "F:\*.mp4" 
    $files.ForEach{
        $media = [TagLib.File]::Create((Resolve-Path $_.FullName))
        if(!$media.Tag.Year) { $media.Tag.Year = $media.Name.Split("\")[-1].Split(".")[-3] }
        $media.Save()
    }
    
}
Edit-MediaFile