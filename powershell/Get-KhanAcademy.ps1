. "$PSSCriptRoot\Utility.ps1"
$uri = "https://www.khanacademy.org/math/basic-geo/basic-geo-lines/lines-rays/e/recognizing_rays_lines_and_line_segments"
#$link = @{Subject = "math"; Course = "basic-geo"; Unit = "basic-geo-lines"; Lesson = "lines-rays"; $Exercise = "recognizing_rays_lines_and_line_segments"}
$website = "https://www.khanacademy.org"

$condition = "`$flag = `$ie.Document"
$ie = Invoke-InternetExplorer "$website/math" $condition 
$ie.Document.IHTMLDocument3_getElementById("/math")

$ie = Invoke-InternetExplorer $uri $condition
$ie.Document.IHTMLDocument3_getElementById("ka-videoPageTabs-tabbedpanel-tab-1").click()
$ie.Document.IHTMLDocument3_getElementsByTagName("ul") | ForEach-Object { if ($_.getAttribute("itemprop") -eq "transcript") { $_.outerHtml } }