var http = require('http');
var url = require('url');
var fs = require('fs');

http.createServer( (req, res) => {
    var q = url.parse(req.url, true);
    var filename = "." + q.path
    var type = q.path.split(".")[1]
    fs.readFile(filename, (err, data) => {
        if (err) {
            res.writeHead(404, {'Content': ('text/html')});
            return res.end("404 Not Found");
        }
        res.writeHead(200, {'Content': ('text/' + type)});
        res.write(data);
        return res.end();
    });
}).listen(8080);
// http://localhost:8080/index.html