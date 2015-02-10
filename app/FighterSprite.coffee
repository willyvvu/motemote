class module.exports extends PIXI.DisplayObjectContainer
  constructor: (@fighter) ->
    super()
    @sprite = PIXI.Sprite.fromImage(@fighter.characterImage)
    @sprite.scale.set(1/700, 1/700)
    @sprite.tint = @fighter.color
    @sprite.anchor.set(0.5, 0.5)
    @addChild(@sprite)

    @ghostSprite = PIXI.Sprite.fromImage("images/ghost2.png")
    @ghostSprite.scale.set(1/750, 1/750)
    @ghostSprite.anchor.set(0.5, 0.5)
    @ghostSprite.visible = false
    @addChild(@ghostSprite)

    @label = new PIXI.Text(@fighter.name, {font: "80px Karla", color: "black"})
    @label.updateText()
    @label.anchor.set(0.5, 0)
    @label.position.y = -1
    @label.scale.set(1/200, 1/200)
    @addChild(@label)

  update: ()->
    if @fighter.dead > 0
      @sprite.visible = false
      @ghostSprite.visible = true
      @ghostSprite.alpha = @fighter.dead / 3
    else
      @sprite.visible = true
      @ghostSprite.visible = false

    @label.setText("#{@fighter.name} #{@fighter.kills}")
    @position.x = @fighter.position.x
    @position.y = @fighter.position.y
    @sprite.alpha = if @fighter.invincibility is -1 then 1 else 0.3