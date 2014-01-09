net     = require "net"
async   = require "async"
cluster = require "cluster"
usage   = require 'usage'
lib7f   = require "./src/7f"

# `ulimit -n` tells us that we can open max. 1024 files per process.
# Creating a socket means opening a file so we are limited
# to 1024 sockets.
CLIENTS             = 1000
MESSAGES            = 2000
MESSAGE_LENGTH      = 64

TOTAL               = CLIENTS * MESSAGES
PORT                = 5010
HOST                = "127.0.0.1"
DELAY_SERVER_RESP   = 0
DELAY_CLIENT_REQ    = 0
DELAY_CLIENT_CREATE = 0

if cluster.isMaster

  pid     = process.pid
  count   = 0
  scount  = 0
  maxMem  = 0
  currMem = 0
  maxCpu  = 0
  currCpu = 0
  start   = new Date

  checkUsage = ->

    usage.lookup pid, {keepHistory: yes}, (err, res) ->

      currCpu = res.cpu
      maxCpu  = res.cpu if res.cpu > maxCpu
      currMem = Math.floor process.memoryUsage().rss / 1024 / 1024
      maxMem  = currMem if currMem > maxMem

  printUsage = ->
    msgProgress = Math.floor count * 100 / TOTAL
    mem = Math.floor currMem
    cpu = Math.floor currCpu
    msg = "\r messages: #{msgProgress}%, memory: #{mem}MB, cpu: #{cpu}%"
    process.stdout.write msg

  checkUsage()

  usageCheckInterval = setInterval checkUsage, 100
  printInterval      = setInterval printUsage, 500

  checkTotal = ->
    if count is TOTAL
      clearInterval usageCheckInterval
      clearInterval printInterval
      t = (new Date) - start
      console.log """\n
        -----
        Messages received & sent by the server: #{count}
               Clients connected to the server: #{scount}
                                    Total time: #{Math.round(t * 100/1000)/100 } s
           Average processing time per message: #{Math.round(t * 100/TOTAL)/100 } ms
                           messages per second: #{Math.round(TOTAL * 1000/t)}
                              Max memory usage: #{maxMem} MB
                              Max cpu    usage: #{Math.round(100 * maxCpu)/100} %
        """
      process.exit()

  server = new lib7f.Server
    host: HOST
    port: PORT

  advancedHeader =
    logicalNr:  1245
    command:    lib7f.constants.Command.TO
    type:       lib7f.constants.DataType.BYTEARRAY

  someData = new Buffer 2

  server.on "client", (client) ->

    scount++
    client.on "message", (x) ->
      count++
      msg = new lib7f.Message {nr: 1}, advancedHeader, someData
      send = -> client.send msg
      # simulate a delay
      setTimeout send, DELAY_SERVER_RESP
      checkTotal()

  server.connect()

  # run clients within a separate process
  cluster.fork()

else

  advancedHeader =
    logicalNr:  45
    command:    lib7f.constants.Command.FETCH
    type:       lib7f.constants.DataType.WORD

  run = (i) ->

    start     = new Date
    counter   = 0
    someData  = new Buffer 64

    c = new lib7f.Client i,
      host: HOST
      port: PORT

    c.on "message", (msg) ->
      counter++
      if counter is MESSAGES
        c.disconnect()

    tasks = for x in [1..MESSAGES] then do (x) ->

      (next) ->
        send = ->
          c.send new lib7f.Message {nr: 4}, advancedHeader, someData
          next()

        # Here we simulate a delay
        setTimeout send, DELAY_CLIENT_REQ

    c.on "login", ->
      async.series tasks, (err) ->
        if err then console.error err

    c.on "error", (err)->
      console.error "an error occoured on client #{i}: ", err

    c.on "connect", c.login

    c.connect()

  for i in [1..CLIENTS] then do (i) ->

    # simulate a delay
    setTimeout (-> run i), DELAY_CLIENT_CREATE
