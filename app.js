var FS = require('fs')
var PORT = process.env['NODE_PORT'] || 3000
var ENV = process.env['NODE_ENV'] || 'development'
var express = require('express')
var stylus = require('stylus')

var app = express.createServer()
var assets  = require('connect-assets')
var SongGenerator = require('./lib/SongGenerator')

app.set('views', __dirname+'/views')

app.use(stylus.middleware({
   src: __dirname + '/assets',
   compile: function (str, path) {
      return stylus(str)
         .set('filename', path)
         .set('compress', true)
         .use(require('nib')())
   }
}))

app.use(express.static(__dirname + '/assets'))

var getSongs = function (req,res,next) {
   FS.readdir(__dirname + '/data/songs', function (err, files) {
      res.local('songs', files.sort())
      next()
   })
}

app.get('/', getSongs, function (req,res) {
   var songTitle = req.query.title || res.local('songs')[0]
   FS.readFile(__dirname+'/data/songs/'+songTitle, 'utf8', function (err, data) {
      var sg = new SongGenerator(data)
      if (req.query.key) sg.changeKey(req.query.key)
      res.local('song', sg)
      res.local('keys', SongGenerator.KEYS)
      res.render('viewer.jade')
   })
})

app.listen(PORT)
console.log("Express server listening on port %d", PORT)
