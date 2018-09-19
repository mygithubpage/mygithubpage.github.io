function createSVG() {
    // Create SVG1
    var box = [0, 7, 7, -3];
    var height = Math.abs(box[1]-box[3]) * 50
    var width = Math.abs(box[0]-box[2]) * 50
    document.querySelector("#svg1").setAttribute("style",`height:${height}px;width:${width}px;`);
    var board = JXG.JSXGraph.initBoard('svg1', {boundingbox: box, showCopyright:false, showNavigation:false});
    var points = [
        {coordiantes:{x:0,y:0}, offset:{x:0,y:-10}}, 
        {coordiantes:{x:5,y:3}, offset:{x:0,y:10}}, 
        {coordiantes:{x:6,y:0}, offset:{x:0,y:-10}}, 
        {coordiantes:{x:3,y:0}, offset:{x:0,y:-10}}
    ];
    var JXGPoints = []
    for (let i = 0; i < points.length; i++) {
    let letter = String.fromCharCode(80 + i)
    point = [points[i].coordiantes.x, points[i].coordiantes.y]
    JXGPoints.push(board.create('point',point, {name:letter,size:0, strokeColor:`#${rgb2hex(bgColor)}`, label: {offset:[points[i].offset.x, points[i].offset.y]}}));
    }

    var seg1 = board.create('segment',[JXGPoints[1],JXGPoints[3]], {strokeColor:`#${rgb2hex(bgColor)}`, strokeWidth:2});
    var line2 = board.create('line',[JXGPoints[2],JXGPoints[0]], {strokeColor:`#${rgb2hex(bgColor)}`, strokeWidth:2, straightFirst:false, straightLast:false});
    var triangle = board.create('polygon',JXGPoints.slice(0,3), {borders: {strokeColor:`#${rgb2hex(bgColor)}`, strokeWidth:2}, fillColor:"#ffffff"});
    board.create('text',[2,-1,"PQ = PR"]);
    var dataArr = [4,1,3,2,5,7,1.5,2];
    //var a = board.create('chart', dataArr, {chartStyle:'line',strokeWidth:4,strokeColor:`#${rgb2hex(bgColor)}`});

    document.querySelectorAll(".JXGtext").forEach(text => { 
    text.style.fontFamily = "tex"; 
    text.style.fontSize = "20px";
    })
}