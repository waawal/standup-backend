# utility functions

hash = (pairs) ->
  hash = {}
  hash[key] = value for [key, value] in pairs
  return hash


# configuration

query_str = location.search.substr(1).split('&')
params = hash (q.split('=') for q in query_str)


# sock.js

srv_loc = window.location.href.split('/')
srv_loc = srv_loc[0] + '//' + srv_loc[2] + '/' + 'sock'
sock = new SockJS(srv_loc)

sock.onopen = (conn) ->
  console.log('open:', sock.protocol)
  sock.send("hello server, I'm " + (hash['name'] or 'anonymous'))

sock.onmessage = (e) ->
  console.log('recv:', e.data)

sock.onclose = ->
  console.log('close')
