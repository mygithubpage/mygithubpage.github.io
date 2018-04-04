
. .\Utility.ps1
#$request = Invoke-WebRequest "https://www.naturalreaders.com/online/"
$ie = Invoke-InternetExplorer "https://www.naturalreaders.com/online/"
$ie.visible = $true
$document = $ie.Document
$document.IHTMLDocument3_getElementById("inputDiv").innerText = "The United States did not have a common culture 100 years ago because people in different regions of the country did not communicate much with each other. The automobile and the radio changed this situation. When automobiles became inexpensive, people from small towns could travel easily to cities or to other parts of the country. When they began to do this, they started acting like people from those other regions and started to dress and speak in the same way. When radio became popular, people from different parts of the country began listening to the same programs and the same news reports and began to speak alike and have similar experiences and ideas. These similar ways of speaking and dressing and thinking became the national culture of the United States.";
$div = $document.IHTMLDocument3_getElementById("circle")
$div.click()
$n = 1
while(!$div.parentNode.className.Contains(" pause") ) { Start-Sleep 1;$div.click()}
$links = @()
do {
    $result = $document.IHTMLDocument3_getElementById("audio").src
    if($temp -ne $result) {
        $links += $result
        $temp = $result
        $n++
    }
} while($div.parentNode.className.Contains(" pause"))
$links.ForEach{ $string += $_ + ";" }
Set-Clipboard $string.TrimEnd(";")
<#
$download = $document.IHTMLDocument3_getElementsByTagName("a")[0];
        $download.href = $result
        $download.download = "sample-respose$n.mp3"
        $download.click()#>
#>
"blob:1793B5F2-4C6A-4A72-8EDE-1D5BFEB468F8;blob:9F100A0C-986E-462D-A31F-178602B53681;blob:E51ABD21-BBFA-40A2-9E3A-9161520E816F;blob:165AF2A9-A646-4D4F-A774-5F0309D5715F;blob:ACF8680D-4477-4B76-8CF4-F62A10D72BB8;blob:7EE155E6-FD1A-4937-82EE-188EAAC6C4D7;blob:D64B6DB9-9E22-40A6-8936-F7C3834CB0ED;blob:92CEA7E6-C2E8-49B5-8217-E17D51BCDA5E;blob:8FB956AC-C79B-4C9B-8A84-F5E4069FF560;blob:1A77C04D-7FBC-4AC9-99EC-69B09693EF84;blob:041966FD-8FE3-4EE1-9FE3-1715EC093474;blob:F1E45DAF-FBD0-4524-A3A7-1D1F29764725;blob:CAA199E7-B349-4F75-83F6-3E2BB2A27810"
