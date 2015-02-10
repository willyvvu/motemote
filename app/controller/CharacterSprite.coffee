class module.exports extends PIXI.DisplayObjectContainer
  constructor: (@fighter) ->
    super()
    @sprite = PIXI.Sprite.fromImage(@fighter)
    @sprite.scale.set(1/700, 1/700)
    @sprite.tint = @fighter.color
    @sprite.anchor.set(0.5, 0.5)
    @addChild(@sprite)
    @label = new PIXI.Text(@fighter.name, {font: "20px Arial", color: "black"})
    @label.anchor.set(0.5, 0)
    @label.position.y = -1
    @label.scale.set(1/50, 1/50)
    @addChild(@label)