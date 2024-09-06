# REQUIRES #######################################

fsp = require 'fs/promises'

# UTILS ##########################################

compileCoffee = ->
  compileStart 'Coffee'
  esb = require 'esbuild'
  coffeePlugin = require 'esbuild-coffeescript'
  try
    await esb.build {
      entryPoints: ['src/app.coffee']
      bundle: on
      minify: on
      sourcemap: 'inline'
      outfile: 'dist/app.js'
      plugins: [coffeePlugin {bare: yes}]
    }
    compileSuccess 'Coffee'
  catch err
    console.error err

compilePug = ->
  compileStart 'Pug'
  pug = require 'pug'
  try
    out = pug.renderFile './src/index.pug'
    await fsp.writeFile './dist/index.html', out
    compileSuccess 'Pug'
  catch err
    console.error err

compileSass = ->
  compileStart 'Sass'
  sass = require 'sass'
  try
    out = sass.compile './src/style.sass', { style: 'compressed' }
    await fsp.writeFile './dist/style.css', out.css
    compileSuccess 'Sass'
  catch err
    console.error err

compileStart = (lg) ->
  console.log "[#{new Date().toLocaleString()}] Compiling #{lg} ..."
compileSuccess = (lg) ->
  console.log " => #{lg} compiled"

createDir = ->
  try
    await fsp.mkdir './dist'
  catch err
    if err.code is 'EEXIST' then console.log('dist already exists')
    else throw err

startServer = ->
  express = require 'express'
  port = 5001
  app = express()
  app.use express.static('./dist')
  app.listen(port, => console.log "Listening on port #{port}")

# TASKS ##########################################

task 'build', '', ->
  await createDir()
  compileCoffee()
  compilePug()
  compileSass()

task 'serve', '', ->
  chokidar = require 'chokidar'
  await createDir()
  compileCoffee()
  compilePug()
  compileSass()
  watcher = chokidar.watch 'src'
  watcher.on 'change', (path) =>
    console.log "watcher, path => #{path}"
    switch path.split('.')[1]
      when 'coffee' then compileCoffee()
      when 'pug'    then compilePug()
      when 'sass'   then compileSass()
  startServer()
