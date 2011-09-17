express = require 'express'
stylus  = require 'stylus'
nib     = require 'nib'
fs      = require 'fs'
sets    = require './data/Sets'

SongGenerator = require './lib/SongGenerator'
port = 3000

compile = (str, path, fn) -> stylus(str).set('filename', path).set('compress', true).use(nib())

global.app = module.exports = express.createServer()

app.configure ->
   app.set 'views', __dirname + '/views'
   app.set 'view engine', 'jade'

   app.use express.bodyParser()
   app.use express.methodOverride()
   app.use stylus.middleware
      src: __dirname + '/views',
      dest: __dirname + '/public',
      compile: compile
   app.use express.static(__dirname + '/public')
   app.use app.router

app.configure 'development', () ->
   app.use express.errorHandler({ dumpExceptions: true, showStack: true })

app.configure 'production', () ->
   port = 8006
   app.use express.errorHandler()

global.render = (view,locals) -> (req,res) -> res.render(view,locals)

getSongs = (req,res,next) ->
   fs.readdir __dirname + '/data/songs', (err, files) ->
      res.local 'songs', files.sort()
      next()

app.get '/', getSongs, (req,res) ->
   songTitle = req.query.title || res.local('songs')[0]
   fs.readFile __dirname + '/data/songs/' + songTitle, 'utf8', (err, data) ->
      sg = new SongGenerator data
      sg.changeKey(req.query.key) if req.query.key
      setDate = Object.keys(sets).pop()
      res.local 'song', sg
      res.local 'currentSetDate', setDate
      res.local 'currentSet', sets[setDate]
      res.local 'keys', SongGenerator.KEYS
      res.render 'viewer'

app.listen port
console.log "Express server listening on port %d", port
