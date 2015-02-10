Vector2 = require("./Vector2")
tempVector = new Vector2()
class module.exports
  velocityCap: 0.1
  friction: 0.002
  acceleration: 0.01
  constructor: ({@characterImage, @color, @name})->
    @kills = 0
    @position = new Vector2()
    @velocity = new Vector2()
    @joystick = new Vector2()
    @lastContact = null
    @dead = 0
    @deaths = 0
    @name = @name[0...10]
    # -1 means not invincible
    @invincibility = 1

  applyVelocity: (deltaTime)->
    tempVector.copy(@joystick)
    tempVector.multiplyScalar(@acceleration * deltaTime)
    tempVector.add(@velocity)
    newSpeed = tempVector.length()
    oldSpeed = @velocity.length()
    velocityCap = @joystick.length() * @velocityCap
    if newSpeed < oldSpeed
      @velocity.copy(tempVector)
    else
      if oldSpeed <= velocityCap
        if newSpeed > velocityCap
          @velocity.copy(tempVector).normalize().multiplyScalar(velocityCap)
        else
          @velocity.copy(tempVector)

    #Friction!
    length = Math.max(0, @velocity.length() - deltaTime * @friction) # Friction
    @velocity.normalize().multiplyScalar(length)

    tempVector.copy(@velocity)
    tempVector.multiplyScalar(deltaTime)
    @position.add(tempVector)

  collidesWith: (otherFighter)->
    return @position.distanceTo(otherFighter.position) <= 1

  die: (fighters)->
    if @dead is 0
      # Gives points to whoever did the deed
      @deaths++
      if @lastContact isnt null
        for fighter in fighters when fighter.id is @lastContact
          fighter.kills += Math.ceil(@kills/2) + 1
          break
      @dead = 3
      @kills = Math.floor(@kills/2)

  respawn: ()->
    @position.set(0, 0)
    @velocity.set(0, 0)
    @joystick.set(0, 0)
    @lastContact = null
    @invincibility = 1
    