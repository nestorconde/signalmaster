/*global console*/
var yetify = require('yetify'),
    config = require('getconfig'),
    fs = require('fs'),
    sockets = require('./sockets'),
    express = require('express'),
    port = parseInt(process.env.PORT || config.server.port, 10),
    server = null
    server_handler = express()
;

server_handler.get('/health-check', function (req, res) {
    console.log(Date.now(), 'healthcheck');
    return res.sendStatus(200);
});
server_handler.use(express.static('static'));

// Create an http(s) server instance to that socket.io can listen to
if (config.server.secure) {
    server = require('https').createServer({
        key: fs.readFileSync(config.server.key),
        cert: fs.readFileSync(config.server.cert),
        passphrase: config.server.password
    }, server_handler);
} else {
    server = require('http').createServer(server_handler);
}
server.listen(port);
sockets(server, config);

if (config.uid) process.setuid(config.uid);

var httpUrl;
if (config.server.secure) {
    httpUrl = "https://localhost:" + port;
} else {
    httpUrl = "http://localhost:" + port;
}
console.log(yetify.logo() + ' -- signal master is running at: ' + httpUrl);
