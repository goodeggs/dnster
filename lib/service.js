// Generated by CoffeeScript 1.6.3
(function() {
  var buildRoutes, configFile, fs, httpProxy, httpsProxy, os, sslCertBuilder, watcher;

  fs = require('fs');

  os = require('os');

  configFile = require('./config_file');

  httpProxy = require('./http_proxy');

  httpsProxy = require('./https_proxy');

  sslCertBuilder = require('./ssl_cert_builder');

  buildRoutes = function(config) {
    var alias, idx, iface, ip, localIP, localIPs, name, port, routes, site, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;
    routes = {};
    localIPs = [];
    _ref = os.networkInterfaces();
    for (name in _ref) {
      iface = _ref[name];
      for (idx = _i = 0, _len = iface.length; _i < _len; idx = ++_i) {
        ip = iface[idx];
        if (ip.family === 'IPv4' && !ip.internal) {
          localIPs.push(ip.address);
        }
      }
    }
    _ref1 = config.ports;
    for (port in _ref1) {
      site = _ref1[port];
      routes["" + site.name + ".dev"] = "127.0.0.1:" + port;
      for (alias in (_ref2 = site.aliases) != null ? _ref2 : {}) {
        routes["" + alias + "." + site.name + ".dev"] = "127.0.0.1:" + port;
        for (_j = 0, _len1 = localIPs.length; _j < _len1; _j++) {
          localIP = localIPs[_j];
          routes["" + alias + "." + site.name + "." + localIP + ".xip.io"] = "127.0.0.1:" + port;
        }
      }
      for (_k = 0, _len2 = localIPs.length; _k < _len2; _k++) {
        localIP = localIPs[_k];
        routes["" + site.name + "." + localIP + ".xip.io"] = "127.0.0.1:" + port;
      }
    }
    return routes;
  };

  watcher = null;

  module.exports = {
    run: function(configPath, watch) {
      var _this = this;
      return configFile.read(configPath, function(err, config) {
        if (err != null) {
          throw err;
        }
        _this.reload(config);
        if (watch) {
          return _this.watch(configPath);
        }
      });
    },
    stop: function() {
      return watcher != null ? watcher.close() : void 0;
    },
    watch: function(configPath) {
      return watcher = fs.watch(configPath, function() {
        var _this = this;
        return configFile.read(configPath, function(err, config) {
          if (err != null) {
            return console.error(err);
          }
          return _this.reload(config);
        });
      });
    },
    reload: function(config) {
      var routes;
      routes = buildRoutes(config);
      httpProxy.reload(routes);
      if (config.ssl) {
        return httpsProxy.reload(routes);
      } else {
        return httpsProxy.stop();
      }
    }
  };

}).call(this);