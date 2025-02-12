#https://www.kirilv.com/canvas-confetti/

reset = h: 19, m: 34

start = new Date()
start.setMilliseconds 0
start.setSeconds 0
start.setMinutes reset.m
start.setHours reset.h
start.setDate(start.getDate() + 1)

interval = null
duration = 60 * 1000
animationEnd = Date.now() + duration
defaults = startVelocity: 20, spread: 600, ticks: 30, zIndex: 0

randomInRange = (min, max) => Math.random() * (max - min) + min
byId = (id) => document.getElementById id
on2digit = (n) => if n < 10 then "0#{n}" else "#{n}"

update = ->
  diff = start - new Date()
  if diff > 0
    delta = Math.floor(diff / 1000)
    hours = (delta - (delta % 3600)) / 3600
    minutes = (delta - (hours * 3600) - (delta % 60)) / 60
    seconds = delta - hours * 3600 - minutes * 60
    byId('heures').innerText = on2digit hours
    byId('minutes').innerText = on2digit minutes
    byId('secondes').innerText = on2digit seconds
    window.setTimeout update, (1000 - (diff % 1000))
  else
    byId('compteur').style.display = 'none'
    byId('winner').style.display = 'block'
    interval = setInterval boom, 250

boom = ->
  timeLeft = animationEnd - Date.now()
  if timeLeft <= 0 then return clearInterval(interval)
  particleCount = 50 * (timeLeft / duration)
  confetti {
    ...defaults, particleCount,
    origin: {x: randomInRange(0.1, 0.3), y: Math.random() - 0.2}
  }
  confetti {
    ...defaults, particleCount,
    origin: {x: randomInRange(0.7, 0.9), y: Math.random() - 0.2}
  }

App =
  init: ->
    #start = new Date()
    #start.setSeconds(start.getSeconds() + 10)
    update()

window.App = App