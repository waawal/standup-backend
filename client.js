// Generated by CoffeeScript 1.6.3
var hash, params, q, query_str, sock, srv_loc;

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

srv_loc = window.location.href.split('/');

srv_loc = srv_loc[0] + '//' + srv_loc[2] + '/' + 'sock';

sock = new SockJS(srv_loc);

sock.onopen = function(conn) {
  console.log('open:', sock.protocol);
  return sock.send("hello server, I'm " + (hash['name'] || 'anonymous'));
};

sock.onmessage = function(e) {
  return console.log('recv:', e.data);
};

sock.onclose = function() {
  return console.log('close');
};
