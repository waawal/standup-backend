
# utility functions

hash = (pairs) ->
  hash = {}
  hash[key] = value for [key, value] in pairs
  return hash


# configuration

query_str = location.search.substr(1).split('&')
params = hash (q.split('=') for q in query_str)
conf_name = hash['name'] or 'anonymous'
conf_room = hash['room'] or 'default'


# messages

send_msg = (sock, msg, data) ->
  o =
    msg: msg
  o = _.defaults(o, data)
  msg = JSON.stringify(o)
  sock.send(msg)

send_join = (sock, room, name) ->
  send_msg sock, 'join',
    room: room
    name: name

send_welcome = (sock, name) ->
  send_msg sock, 'welcome',
    name: name

send_alive = (sock, name) ->
  send_msg sock, 'alive',
    name: name

send_set = (sock, time, duration, state) ->
  send_msg sock, 'set',
    time: time
    duration: duration
    state: state

send_start = (sock) ->
  send_msg sock, 'start'

send_stop = (sock) ->
  send_msg sock, 'stop'


# sock.js

srv_loc = window.location.href.split('/')
srv_loc = srv_loc[0] + '//' + srv_loc[2] + '/' + 'sock'
sock = new SockJS(srv_loc)


sock.onopen = (conn) ->
  console.log('Connection established:', sock.protocol)

  # join
  send_join sock, conf_room, conf_name


sock.onmessage = (message) ->
  try
    o = JSON.parse(message.data)

    # handle JOIN
    if o.msg == 'join'
      console.log(o.name + ' joins the standup.')
      send_welcome(sock, conf_name)
      send_set(sock, new Date().getTime(), duration=900, state='paused')

    # handle STATE
    else if o.msg == 'set'
      console.log('Receive set: time=' + o.time +
                  ' duration=' + o.duration +
                  ' state=' + o.state)

    # handle WELCOME
    else if o.msg == 'welcome'
      console.log(o.name + ' welcomes you.')

    # handle KEEPALIVE
    else if o.msg == 'keepalive'
      console.log('keepalive')
      send_alive(sock, conf_name)

    # handle ALIVE
    else if o.msg == 'alive'
      console.log(o.name + ' is alive.')


  catch error
    console.log('error:', error, 'message:', message.data)


sock.onclose = ->
  console.log('close')
