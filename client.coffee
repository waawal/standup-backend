srv_loc = window.location.href.split('/')
srv_loc = srv_loc[0] + '//' + srv_loc[2] + '/' + 'sock'
sock = new SockJS(srv_loc)

sock.onopen = (conn) ->
  console.log('open:', sock.protocol)
  sock.send('hello SERVER')

sock.onmessage = (e) ->
  console.log('recv:', e.data)

sock.onclose = ->
  console.log('close')
