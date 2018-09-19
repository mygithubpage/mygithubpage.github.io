
function Edit-MediaFile () {
    [Reflection.Assembly]::LoadFrom( (Resolve-Path "$PSScriptRoot\taglib-sharp.dll"))
    $files = Get-ChildItem "F:\*.mp4" 
    $files.ForEach{
        $media = [TagLib.File]::Create((Resolve-Path $_.FullName))
        if(!$media.Tag.Year) { $media.Tag.Year = $media.Name.Split("\")[-1].Split(".")[-3] }
        $media.Save()
    }
    
}

function Rename-Episodes () {
    param ($Path)
    (Get-ChildItem $path -Recurse -File).ForEach{
        $episode = $_
        if ($episode.Name.Length -lt 7) {
            $newName = $path.Split("\")[-1] + " " + $episode.Directory.Name + " Episode " + $episode.Name
            Rename-Item $episode.PSPath $newName
        }
    }
}

# Edit-MediaFile
Rename-Episodes "D:\The Big Bang Theory"
