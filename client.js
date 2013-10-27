// Generated by CoffeeScript 1.6.3
var conf_contact, conf_name, conf_room, hash, params, q, query_str, send_alive, send_call, send_hangup, send_join, send_msg, send_set, send_start, send_stop, send_welcome, sock, srv_loc;

hash = function(pairs) {
  var key, value, _i, _len, _ref;
  hash = {};
  for (_i = 0, _len = pairs.length; _i < _len; _i++) {
    _ref = pairs[_i], key = _ref[0], value = _ref[1];
    hash[key] = value;
  }
  return hash;
};

query_str = location.search.substr(1).split('&');

params = hash((function() {
  var _i, _len, _results;
  _results = [];
  for (_i = 0, _len = query_str.length; _i < _len; _i++) {
    q = query_str[_i];
    _results.push(q.split('='));
  }
  return _results;
})());

conf_room = hash['room'] || 'default';

conf_name = hash['name'] || 'anonymous';

conf_contact = hash['contact'] || null;

send_msg = function(sock, msg, data) {
  var o;
  o = {
    msg: msg
  };
  o = _.defaults(o, data);
  msg = JSON.stringify(o);
  return sock.send(msg);
};

send_join = function(sock, room, name) {
  return send_msg(sock, 'join', {
    room: room,
    name: name,
    contact: conf_contact
  });
};

send_welcome = function(sock, name) {
  return send_msg(sock, 'welcome', {
    name: name,
    contact: conf_contact
  });
};

send_alive = function(sock, name) {
  return send_msg(sock, 'alive', {
    name: name,
    contact: conf_contact
  });
};

send_set = function(sock, time, duration, state) {
  return send_msg(sock, 'set', {
    time: time,
    duration: duration,
    state: state
  });
};

send_start = function(sock) {
  return send_msg(sock, 'start');
};

send_stop = function(sock) {
  return send_msg(sock, 'stop');
};

send_call = function(sock) {
  return send_msg(sock, 'call');
};

send_hangup = function(sock) {
  return send_msg(sock, 'hangup');
};

srv_loc = window.location.href.split('/');

srv_loc = srv_loc[0] + '//' + srv_loc[2] + '/' + 'sock';

sock = new SockJS(srv_loc);

sock.onopen = function(conn) {
  console.log('Connection established:', sock.protocol);
  return send_join(sock, conf_room, conf_name);
};

sock.onmessage = function(message) {
  var duration, error, o, state;
  try {
    o = JSON.parse(message.data);
    if (o.msg === 'join') {
      console.log(o.name + ' joins the standup.');
      send_welcome(sock, conf_name);
      return send_set(sock, new Date().getTime(), duration = 900, state = 'paused');
    } else if (o.msg === 'set') {
      return console.log('Receive set: time=' + o.time + ' duration=' + o.duration + ' state=' + o.state);
    } else if (o.msg === 'welcome') {
      return console.log(o.name + ' welcomes you.');
    } else if (o.msg === 'keepalive') {
      console.log('keepalive');
      return send_alive(sock, conf_name);
    } else if (o.msg === 'alive') {
      return console.log(o.name + ' is alive.');
    }
  } catch (_error) {
    error = _error;
    return console.log('error:', error, 'message:', message.data);
  }
};

sock.onclose = function() {
  return console.log('close');
};
