start = new Date(1725725040278)

byId = (id) => document.getElementById id

update = ->
  diff = start - new Date()
  delta = Math.floor(diff / 1000)
  hours = (delta - (delta % 3600)) / 3600
  minutes = (delta - (hours * 3600) - (delta % 60)) / 60
  seconds = delta - hours * 3600 - minutes * 60
  byId('heures').innerText = hours
  byId('minutes').innerText = minutes
  byId('secondes').innerText = seconds
  window.setTimeout update, (1000 - (diff % 1000))

App =
  init: -> update()

window.App = App