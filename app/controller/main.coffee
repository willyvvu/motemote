$color = $('#color')
$name = $('#name')
$character = $('#character')
$kills = $('#kills')
$deaths = $('#deaths')
$joystick = $("#joystick")
$circlepad = $("#circlepad")
$newchar = $("#newchar")
$death = $("#death")
$collision = $("#collision")
$window = $(window)
Fighter = require "Fighter"
Vector2 = require "Vector2"
tilt = false
try
  context = new AudioContext()
catch e
  context = null

sounds = {}
loadSound = (url)->
  request = new XMLHttpRequest()
  request.open('GET', url, true)
  request.responseType = 'arraybuffer'

  request.onload = ()->
    context.decodeAudioData request.response, (buffer) ->
      sounds[url] = buffer
  request.send()

loadSound("sounds/new-char.ogg")
loadSound("sounds/death.ogg")
loadSound("sounds/collision.ogg")

$(document).ready ()->
  $(document.body).show()

$('input[name="controlChoice"]').change ()->
  tilt = $('input[name="controlChoice"]:checked').val() is "tilt"
  resetJoystick()
  sendJoystick()


FighterSprite = require "FighterSprite"
Arena = require "Arena"
stage = new PIXI.Stage(0xff0000)

renderer = PIXI.autoDetectRenderer(500, 400, transparent: true)
$('#character').append(renderer.view)
renderer.render stage



names = [
  "Momo"
  "Mini"
  "Mimi"
  "Mira"
  "Mina"
  "Meme"
  "Mino"
  "Bobo"
]
$name.val(names[Math.floor(Math.random() * names.length)])
socket = null
fighterSprite = null
$('#join').click ->
  if socket?
    console.log("disconnecting")
    socket.disconnect()
  else
    console.log("joining")
    socket = io(multiplex: false)

    $kills.text('0')
    $deaths.text('0')
    socket.on "disconnect", ()->
      socket = null
      stage.removeChild(fighterSprite)
      $name.attr('readonly', false)
      $('#join').text("JOIN")
      $('#options').show()
      $('#stats').hide()
      $('#controls').hide()
      playSound("sounds/death.ogg")
      renderer.render stage

    $('#options').hide()
    $('#stats').show()
    $('#controls').show()

    socket.on 'death', (fighter)->
      playSound("sounds/death.ogg")
      #update kill/death count
    socket.on 'update', (fighter)->
      #update kill/death count
      $kills.text(fighter.kills)
      $deaths.text(fighter.deaths)
    socket.on 'collision', ()->
      #play sound
      playSound("sounds/collision.ogg")
      navigator.vibrate(50)

    name = $name.val() or 'Mo'
    $name.attr('readonly', true)

    color = parseInt($('input[name="colorChoice"]:checked').val(), 16)
    #color = Math.floor(0xffffff*Math.random())

    character = $('input[name="fighterChoice"]:checked').val()
    characterImage = "images/#{character}.png"

    $('#join').text('LEAVE')
    fighter  = new Fighter({color, name, characterImage})
    socket.emit('join', fighter)

    playSound("sounds/new-char.ogg")
    fighterSprite = new FighterSprite(fighter)
    scaleFactor = Math.min(500, 400)/2
    fighterSprite.position.set(500/2, 500/2)
    fighterSprite.scale.set(scaleFactor, scaleFactor)
    stage.addChild(fighterSprite)
    renderer.render stage
    fighterSprite.sprite.texture.baseTexture.on "loaded", ()->
      renderer.render stage

joystick = new Vector2()
tempVector = new Vector2()
sendJoystick = ()->
  if socket?
    socket.emit('joystick', joystick)

upKey = 38
upKeyPressed = 0
downKey = 40
downKeyPressed = 0
leftKey = 37
leftKeyPressed = 0
rightKey = 39
rightKeyPressed = 0
keys = [upKey, downKey, leftKey, rightKey]
handleKeyEvent = (event, down)->
  if event.keyCode in keys
    if tilt
      tilt = false
      updateTilt()
    if socket
      event.preventDefault()
    switch event.keyCode
      when upKey then upKeyPressed = (if down then 1 else 0)
      when downKey then downKeyPressed = (if down then 1 else 0)
      when leftKey then leftKeyPressed = (if down then 1 else 0)
      when rightKey then rightKeyPressed = (if down then 1 else 0)
    joystick.set(rightKeyPressed - leftKeyPressed, downKeyPressed - upKeyPressed)
    joystick.normalize()
    updateJoystick()
    sendJoystick()

window.addEventListener 'keydown', (event)->
  handleKeyEvent(event, true)
window.addEventListener 'keyup', (event)->
  handleKeyEvent(event, false)


window.addEventListener 'devicemotion', (event)->
  tempVector.set(
    -event.accelerationIncludingGravity.x / 3,
    event.accelerationIncludingGravity.y / 3
  )
  if tilt
    joystick.lerp(tempVector, 0.3)
    length = joystick.length()
    joystick.normalize().multiplyScalar(Math.min(1, length))
    updateJoystick()
    sendJoystick()
, true

playSound = (url) ->
  if context?
    source = context.createBufferSource()
    source.buffer = sounds[url]
    source.connect(context.destination)
    source.start(0)

moveJoystick = (event)->
  if tilt
    tilt = false
    updateTilt()
  joystick.set(event.originalEvent.touches[0].pageX, event.originalEvent.touches[0].pageY)
  offset = $joystick.offset()
  joystick.x -= offset.left + 112.5
  joystick.y -= offset.top + 112.5
  length = joystick.length()
  joystick.normalize().multiplyScalar(Math.min(1, length/62.5))
  updateJoystick()
  sendJoystick()
  return

updateJoystick = ()->
  $circlepad.css("left", 112.5 + joystick.x * 62.5).css("top", 112.5 + joystick.y * 62.5)

updateTilt = ()->
  $('input[name="controlChoice"]').removeAttr("checked")
  if tilt
    $('input[name="controlChoice"][value="tilt"]').attr("checked", "checked")[0].checked = true
  else
    $('input[name="controlChoice"][value="joystick"]').attr("checked", "checked")[0].checked = true


resetJoystick = (event)->
  joystick.set(0, 0)
  $circlepad.css("left", 112.5).css("top", 112.5)
  sendJoystick()

$joystick.on "touchstart", (event)->
  event.preventDefault()
  moveJoystick(event)
  $window.off "touchmove"
  $window.on "touchmove", (event)->
    # Joystick movement
    event.preventDefault()
    moveJoystick(event)
  $window.off "touchend"
  $window.on "touchend", (event)->
    resetJoystick(event)
    # Reset joystick
    $window.off "touchmove"
    $window.off "touchend"
