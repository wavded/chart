(function() {
  var FS, SongGenerator, assets, express, getSongs, port;

  express = require('express');

  global.app = express.createServer();

  FS = require('fs');

  assets = require('connect-assets');

  port = 3000;

  SongGenerator = require('./lib/SongGenerator');

  app.set('views', __dirname + '/views');

  app.configure('development', function() {
    return app.use(assets());
  });

  app.configure('production', function() {
    port = 8006;
    return app.use(assets({
      build: true,
      buildDir: false,
      src: __dirname + '/assets',
      detectChanges: false
    }));
  });

  app.use(express.bodyParser());

  app.use(express.methodOverride());

  app.use(express.static(__dirname + '/assets'));

  global.render = function(view, locals) {
    return function(req, res) {
      return res.render(view, locals);
    };
  };

  getSongs = function(req, res, next) {
    return FS.readdir(__dirname + '/data/songs', function(err, files) {
      res.local('songs', files.sort());
      return next();
    });
  };

  app.get('/', getSongs, function(req, res) {
    var songTitle;
    songTitle = req.query.title || res.local('songs')[0];
    return FS.readFile(__dirname + '/data/songs/' + songTitle, 'utf8', function(err, data) {
      var sg;
      sg = new SongGenerator(data);
      if (req.query.key) sg.changeKey(req.query.key);
      res.local('song', sg);
      res.local('keys', SongGenerator.KEYS);
      return res.render('viewer.jade');
    });
  });

  app.listen(port);

  console.log("Express server listening on port %d", port);

}).call(this);
