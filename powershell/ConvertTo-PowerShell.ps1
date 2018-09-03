function Convert-TypeName {
    param ($type)
    $type -replace "Worksheet", "ws"
}
function Convert-FunctionName {
    param ($type)
    $type -replace "Worksheet", "ws"
}

$content = Get-Content "C:\github\powershell\files\Sales.vb" -Raw

($content | Select-String "Function(.*\r\n)*?End Function" -AllMatches).Matches.Value.ForEach{
    $function = $_
    ($function -split "\r\n").ForEach{
        $line = $_

        if ($line -match "Function") {
            $name = ($line | Select-String "(?<=Function )\w+").Matches.Value

            ( ($line | Select-String "(?<=Function \w+\().*(?=\))").Matches.Value | Select-String "By\w+ (?<parameter>\w+) As (?<type>\w+)").Matches.ForEach{
                $parameter = $_

                if($parameter.Value -match "ByRef") { $prefix = "[ref]" }
                $line -replace $parameter, ($prefix + "$" + (Convert-TypeName $parameter.Groups["type"].Value) + $parameter.Groups["parameter"].Value)
            }
        }
        elseif ($line -match "Dim") {
            
        }
        elseif ($line -match ":=") {

        }
        elseif ($line -match "End ") {
            
        }
    }
    
}
