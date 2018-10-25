function createSVG() {
    // Create SVG1
    var box = [0, 7, 7, -3];
    var height = Math.abs(box[1] - box[3]) * 50;
    var width = Math.abs(box[0] - box[2]) * 50;
    var id = "svg1";
    $(`#${id}`).height(`${height}px`).width(`${width}px`)
    var board = JXG.JSXGraph.initBoard(id, {
        boundingbox: box,
        showCopyright: false,
        showNavigation: false
    });

    //  Create Points
    var points = [{
            coordinates: {
                x: 0,
                y: 0
            },
            offset: {
                x: 0,
                y: -10
            }
        },
        {
            coordinates: {
                x: 5,
                y: 3
            },
            offset: {
                x: 0,
                y: 10
            }
        },
        {
            coordinates: {
                x: 6,
                y: 0
            },
            offset: {
                x: 0,
                y: -10
            }
        },
        {
            coordinates: {
                x: 3,
                y: 0
            },
            offset: {
                x: 0,
                y: -10
            }
        }
    ];
    var JXGPoints = [];
    $(points).each(function (i) {
        let letter = String.fromCharCode(80 + i)
        point = [this.coordinates.x, this.coordinates.y]
        JXGPoints.push(
            board.create('point', point, {
                name: letter,
                size: 0,
                strokeColor: `#${rgb2hex(bgColor)}`,
                label: {
                    offset: [this.offset.x, this.offset.y]
                }
            })
        );
    });

    // Create Triangle
    board.create('segment',
        [JXGPoints[1], JXGPoints[3]], {
            strokeColor: `#${rgb2hex(bgColor)}`,
            strokeWidth: 2
        });

    board.create('line', [JXGPoints[2], JXGPoints[0]], {
        strokeColor: `#${rgb2hex(bgColor)}`,
        strokeWidth: 2,
        straightFirst: false,
        straightLast: false
    });

    board.create('polygon', JXGPoints.slice(0, 3), {
        borders: {
            strokeColor: `#${rgb2hex(bgColor)}`,
            strokeWidth: 2
        },
        fillColor: "#ffffff"
    });
    board.create('text', [2, -1, "PQ = PR"]);

    $(".JXGtext").css({
        fontFamily: "tex",
        fontSize: "20px",
        color: bgColor
    });
}