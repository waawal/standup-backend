http = require('http')
sockjs = require('sockjs')
node_static = require('node-static')

sockjs_opts = sockjs_url: 'http://cdn.sockjs.org/sockjs-0.3.min.js'
sockjs_sock = sockjs.createServer(sockjs_opts)
sockjs_sock.on 'connection', (conn) ->
  conn.on 'data', (message) ->
    conn.write('re: ' + message)

server = http.createServer()

static_directory = new node_static.Server(__dirname)
server.addListener 'request', (req, res) ->
  static_directory.serve(req, res)

server.addListener 'upgrade', (req, res) ->
  res.end()

sockjs_sock.installHandlers(server,
    prefix: '/sock')

console.log(' [*] Listening on 0.0.0.0:9999')
server.listen(9999, '0.0.0.0')
