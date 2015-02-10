FighterSprite = require "FighterSprite"
Arena = require "Arena"
stage = new PIXI.Stage()

# Redirect

isMobile = ()->
  return navigator.userAgent.match(/mobile/i)

if isMobile()
  window.location = "/m"

renderer = PIXI.autoDetectRenderer(window.innerWidth, window.innerHeight, transparent: true)

document.body.appendChild(renderer.view)

socket = io()

backgroundTexture = PIXI.Texture.fromImage("images/bg.png")
window.backgroundSprite = new PIXI.TilingSprite(backgroundTexture, window.innerWidth, window.innerHeight)
stage.addChild(backgroundSprite)


sprites = []
arena = new Arena()
stage.addChild(arena)

socket.emit "screen"

socket.on "add", (fighters) ->
  #add new fighter sprites to screen
  for fighter in fighters
    tempSprite = new FighterSprite(fighter)
    arena.addChild(tempSprite)
    sprites.push(tempSprite)

socket.on "update", (fighters)->
  #update all fighter sprites' x and y
  for fighter in fighters
    for sprite in sprites
      if sprite.fighter.id is fighter.id
        sprite.fighter = fighter
        break


socket.on "remove", (fighter)->
  for sprite,i in sprites
    if sprite.fighter.id is fighter.id
      arena.removeChild(sprite)
      sprites.splice(i, 1)
      break


# player =
#   x: 0
#   y: 0

# document.addEventListener 'keydown', (event) ->
#   if event.keyCode == 39
#     player.x += 5
#   else if event.keyCode == 37
#     player.x -= 5
#   else if event.keyCode == 40
#     player.y += 5
#   else if event.keyCode == 38
#     player.y -= 5

# FighterSprite = require("FighterSprite")
# fighter1 = new FighterSprite()
# stage.addChild(fighter1)

# FighterSprite = require("FighterSprite")
# fighter2 = new FighterSprite()
# stage.addChild(fighter2)
# # graphics = new PIXI.Graphics()
# # stage.addChild(graphics)



 animate = ->
#   fighter2.position.x = player.x
#   fighter2.position.y = player.y
  for sprite in sprites
    # if Math.abs(sprite.position.x - sprite.fighter.position.x) + Math.abs(sprite.position.y - sprite.fighter.position.y) < 10
    #   sprite.position.x = sprite.position.x * 0.5 + sprite.fighter.position.x * 0.5
    #   sprite.position.y = sprite.position.y * 0.5 + sprite.fighter.position.y * 0.5
    # else
    sprite.update()
  renderer.render stage
  requestAnimationFrame animate

#   # graphics.clear()
#   # for i in [0...107] by 1
#   #   graphics.beginFill(0x009900 * (i))
#   #   graphics.lineStyle(10, 0x0066CC + (i * 0x5))
#   #   graphics.drawRect(
#   #     300 + (Math.cos((frame_count+(i*2))*0.025) * (1000 / 1000 * Math.PI * 4)) * 20,
#   #     200 + (Math.sin((frame_count+(i*2))*0.025) * (1000 / 1000 * Math.PI * 4)) * 10,
#   #     100,
#   #     100
#   #   )


requestAnimationFrame animate

resize = ()->
  renderer.resize(window.innerWidth, window.innerHeight)
  backgroundSprite.width = window.innerWidth
  backgroundSprite.height = window.innerHeight
  arena.position.set(window.innerWidth / 2, window.innerHeight / 2)
  scaleFactor = Math.min(window.innerWidth, window.innerHeight) / 12
  arena.scale.set(scaleFactor, scaleFactor)

resize()
window.addEventListener "resize", resize
