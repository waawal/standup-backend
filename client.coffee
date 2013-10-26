
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

send_set = (sock, time, duration, state) ->
  send_msg sock, 'set',
    time: time
    duration: duration
    state: state


# sock.js

srv_loc = window.location.href.split('/')
srv_loc = srv_loc[0] + '//' + srv_loc[2] + '/' + 'sock'
sock = new SockJS(srv_loc)


sock.onopen = (conn) ->
  console.log('open:', sock.protocol)

  # join
  send_join sock, conf_room, conf_name


sock.onmessage = (message) ->
  try
    o = JSON.parse(message.data)

    # handle JOIN
    if o.msg == 'join'
      console.log(o.name + ' joins the standup')
      send_set(sock, new Date().getTime(), duration=900, state='paused')

    # handle STATE
    else if o.msg == 'set'
      console.log('receive set: time=' + o.time +
                  ' duration=' + o.duration +
                  ' state=' + o.state)


  catch error
    console.log('error:', error, 'message:', message.data)


sock.onclose = ->
  console.log('close')
