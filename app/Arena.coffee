class module.exports extends PIXI.DisplayObjectContainer
  constructor: ->
    super()
    @sprite = PIXI.Sprite.fromImage("images/dinnerplate.png")
    @sprite.scale.set(10/1000, 10/1000)
    @sprite.anchor.set(0.5, 0.5)
    @sprite.tint = 0xffffff
    @addChild(@sprite)

    
