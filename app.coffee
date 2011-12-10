express = require 'express'
global.app = express.createServer()

FS      = require 'fs'
sets    = require './data/Sets'
assets  = require 'connect-assets'
port    = 3000

SongGenerator = require './lib/SongGenerator'

app.set 'views', __dirname + '/views'

app.configure 'development', -> app.use assets()
app.configure 'production',  -> port = 8006; app.use assets( build: true, buildDir: false, detectChanges: false )

app.use express.bodyParser()
app.use express.methodOverride()
app.use express.static(__dirname + '/assets')

global.render = (view,locals) -> (req,res) -> res.render(view,locals)

getSongs = (req,res,next) ->
   FS.readdir __dirname + '/data/songs', (err, files) ->
      res.local 'songs', files.sort()
      next()

app.get '/', getSongs, (req,res) ->
   songTitle = req.query.title || res.local('songs')[0]
   FS.readFile __dirname + '/data/songs/' + songTitle, 'utf8', (err, data) ->
      sg = new SongGenerator data
      sg.changeKey(req.query.key) if req.query.key
      setDate = Object.keys(sets).pop()
      res.local 'song', sg
      res.local 'currentSetDate', setDate
      res.local 'currentSet', sets[setDate]
      res.local 'keys', SongGenerator.KEYS
      res.render 'viewer.jade'

app.listen port
console.log "Express server listening on port %d", port
