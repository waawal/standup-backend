http = require('http')
sockjs = require('sockjs')
node_static = require('node-static')
_ = require('lodash-node')

sockjs_opts = sockjs_url: 'http://cdn.sockjs.org/sockjs-0.3.min.js'
sockjs_sock = sockjs.createServer(sockjs_opts)


# utility functions

get_or_create = (o, attr, default_fn) ->
  v = o[attr]
  if not v
    v = o[attr] = default_fn()
  return v


# handling connections

conns = {}
rooms = {}

add_conn = (conn, room) ->
  console.log(' * add conn ' + conn + ' to room ' + room.name)
  conns[conn] = room
  room.participants.push(conn)

remove_conn = (conn) ->
  room = conns[conn]
  console.log(' * remove conn ' + conn + ' from room ' + room?.name)
  if room
    _.remove(room.participants, (value, idx, array) -> value == conn)
  delete conns[conn]


# sockjs

sockjs_sock.on 'connection', (conn) ->

  interval = setInterval (->
    console.log 'keepalive'
    conn.write '{"msg": "keepalive"}'
  ),
        20 * 1000

  conn.on 'data', (msg) ->
    console.log('recv:', msg)
    try
      o = JSON.parse(msg)

      # handle join msg
      if o.msg == 'join'
        remove_conn conn
        room = get_or_create rooms, o.room, ->
          room =
            name: o.room
            participants: []
        add_conn conn, room
      else
        room = conns[conn]

      # forward msg to all other participants
      for participant in room?.participants
        if participant != conn
          participant.write(msg)


    catch error
      console.log('error:', error)

  conn.on 'close', ->
    remove_conn conn


# http server

server = http.createServer()

static_directory = new node_static.Server(__dirname)
server.addListener 'request', (req, res) ->
  static_directory.serve(req, res)

server.addListener 'upgrade', (req, res) ->
  res.end()

sockjs_sock.installHandlers(server,
    prefix: '/sock')


server_port = process.env.PORT or 9999
console.log(" [*] Listening on 0.0.0.0:#{ server_port }")
server.listen(process.env.PORT or 9999, '0.0.0.0')
