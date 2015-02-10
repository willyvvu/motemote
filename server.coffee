express = require("express")
app = express()
server = require('http').Server(app)
io = require('socket.io')(server)
Fighter = require("./app/Fighter.coffee")
Vector2 = require("./app/Vector2")
app.use("/m", express.static(__dirname + "/public/controller.html"))
app.use(express.static(__dirname + "/public"))
server.listen(process.env.PORT or 80)

tempVector = new Vector2()
tempVector2 = new Vector2()

screens = []
fighters = []
fighterSockets = []
emit = (socket, channel, data)->
  if socket?
    try
      socket.emit(channel, data)
    catch e
      console.warn(e)

io.on 'connection', (socket)->
  # Screen STUFF
  socket.on "screen", ()->
    socket.screen = true
    unless socket in screens
      screens.push(socket)
      console.log("#{screens.length} spectator#{if screens.length is 1 then "" else "s"}")
      emit(socket, "add", fighters)

  # Fighter STUFF

  socket.on 'join', (fighter)->
    socket.fighter = new Fighter(fighter)
    socket.fighter.id = socket.id
    unless socket.fighter in fighters
      fighters.push(socket.fighter)
      fighterSockets.push(socket)
      for screen in screens
        emit(screen, "add", [socket.fighter])
    #console.log("fighter #{socket.fighter.name} received", fighters)
      console.log("#{fighters.length} fighter#{if fighters.length is 1 then "" else "s"}")

  socket.on 'joystick', (joystick)->
    if socket.fighter?
      #set magnitude of the joystick between 0 and 1
      tempVector.copy(joystick)
      length = Math.min(tempVector.length(), 1)
      tempVector.normalize().multiplyScalar(length)
      socket.fighter.joystick.copy(tempVector)
  socket.on "disconnect", ()->
    if socket.fighter?
      # Remove the fighter from the list
      for screen in screens
        emit(screen, "remove", socket.fighter)
      index = fighters.indexOf socket.fighter
      if index isnt -1
        fighters.splice(index, 1)
        fighterSockets.splice(index, 1)
        console.log("#{fighters.length} fighter#{if fighters.length is 1 then "" else "s"}")
    else if socket.screen
      index = screens.indexOf socket
      if index isnt -1
        screens.splice(index, 1)
        console.log("#{screens.length} spectator#{if screens.length is 1 then "" else "s"}")

deltaTime = 1

update = ()->
  setTimeout(update, 1000/60)
  # Update all fighterSockets
  for fighter in fighters
    if fighter.dead > 0
      fighter.dead = Math.max(0, fighter.dead - deltaTime * 1/60)
      if fighter.dead is 0
        fighter.respawn()
    else
      fighter.applyVelocity(deltaTime)
    if fighter.invincibility is 0
      fighter.invincibility = -1
    else if fighter.invincibility isnt -1
      fighter.invincibility = 0

  for fighter1, i in fighters when fighter1.dead is 0
    for fighter2, j in fighters when j > i and fighter2.dead is 0
      if fighter1.collidesWith(fighter2)
        if fighter1.invincibility isnt -1
          fighter1.invincibility++
        if fighter2.invincibility isnt -1
          fighter2.invincibility++
        if fighter1.invincibility is -1 and fighter2.invincibility is -1
          resolveCollision(fighter1, fighter2)
          emit(fighterSockets[i], "collision")
          emit(fighterSockets[j], "collision")

  # Leave the screen
  for fighter, i in fighters
    if fighter.position.length() >= 5.35 and fighter.dead is 0
      fighter.die(fighters)
      if fighter.lastContact?
        for other, j in fighters when other.id is fighter.lastContact
          emit(fighterSockets[j], "update", other)
          break

      emit(fighterSockets[i], "update", fighter)
      emit(fighterSockets[i], "death", fighter)
      for screen in screens
        emit(screen, "death", fighter)

  # Update all screens
  for screen in screens
    emit(screen, "update", fighters)


resolveCollision = (fighter1, fighter2)->
  tempVector.copy(fighter1.position).sub(fighter2.position)
  distance = (1 - tempVector.length())/2
  tempVector.normalize()
  tempVector2.copy(tempVector).multiplyScalar(distance)
  fighter1.position.add(tempVector2)
  fighter2.position.sub(tempVector2)
  totalPush = -tempVector.dot(fighter1.velocity) + tempVector.dot(fighter2.velocity)
  if totalPush < 0
    totalPush -= Fighter::friction
  else
    totalPush += Fighter::friction

  fighter1.velocity.add(tempVector.multiplyScalar(1.4 * totalPush))
  fighter2.velocity.sub(tempVector)
  fighter1.lastContact = fighter2.id
  fighter2.lastContact = fighter1.id

update()
