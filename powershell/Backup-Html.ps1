$test = "toefl"
New-Item "temp" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

function Backup-Html {
    (Get-ChildItem "C:\github\$test\*\*\*.html").ForEach{
        $file = $_
        if ($test -eq "gre") {

        }
        else {
            if ($file.name -match "og|tpo") {
                Copy-Item $file "temp\"
            }
        }
    }
}

function Restore-Html {
    (Get-ChildItem "temp\*replay*.mp3").ForEach{
        $file = $_
        if ($test -eq "gre") {

        }
        else {
            $number = $file.Name -replace "-.*"
            $set = $number -replace "\d+"
            Copy-Item $file "C:\github\$test\$set\$number\" 
        }
    }
}

#Backup-Html
Restore-Html