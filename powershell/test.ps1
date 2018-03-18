$match = "Geographic isolation creates opportunities for new species to develop, but it does not necessarily lead to new species because speciation occurs only when the gene pool undergoes enough changes to establish reproductive barriers between the isolated population and its parent population."

$pattern = " ?(</span>)?\.?\)?,?;?`"? ?`"?\(?(<span class=`"(highlight|question[0-9])`">)?"
$highlight = $match.Replace(",", "").Replace("`"", "").Replace(".", "\.?").Replace("(", "\(?").Replace(")", "\)?").Replace("'", "(</span>)?'").Replace("-", "(</span>)?-").Replace(" ", $pattern)
$highlight = "$highlight$pattern"

$content = "Geographic isolation creates opportunities for new <span class=`"highlight`">species</span> to develop, but it does not necessarily <span class=`"highlight`">lead</span> to new <span class=`"highlight`">species</span> because <span class=`"highlight`">speciation</span> occurs only when the <span class=`"highlight`">gene</span> pool <span class=`"question7`">undergoes </span>enough changes to <span class=`"highlight`">establish</span> <span class=`"highlight`">reproductive</span> barriers between the <span class=`"highlight`">isolated</span> <span class=`"highlight`">population</span> and its parent <span class=`"highlight`">population</span>."
$content | Select-String $highlight