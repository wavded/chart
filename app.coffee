express = require 'express'
stylus = require 'stylus'
nib = require 'nib'
fs = require 'fs'
SongGenerator = require './lib/SongGenerator'
sample = fs.readFileSync(__dirname + '/data/Amazed')

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

global.render = (view,locals) -> (req,res) -> res.render(view,locals)

app.get '/', render 'index', sample: sample

app.get '/generate', (req,res) ->
  fs.readFile __dirname + '/data/' + req.query.title, 'utf8', (err, data) ->
    sg = new SongGenerator data
    if req.query.key
      sg.changeKey(req.query.key)
    res.local 'song', sg
    fs.readdir __dirname + '/data', (err, files) ->
      res.local 'songs', files.sort()
      res.local 'keys', SongGenerator.KEYS
      res.render 'generate'

app.post '/generate', (req,res) ->
  sg = new SongGenerator(req.body)
  res.local 'song', sg
  fs.readdir __dirname + '/data', (err, files) ->
    res.local 'songs', files
    res.render 'generate'

app.listen 3000
console.log "Express server listening on port %d", 3000
