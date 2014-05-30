###
Copyright (c) 2009 - 2014, Markus Kohlhase <mail@markus-kohlhase.de>
###

net         = require "net"
events      = require "events"

constants   = require "./Constants"
messages    = require "./Messages"

Processor       = require "./Processor"
AdvancedMessage = messages.AdvancedMessage
Properties      = constants.Properties

class Client extends events.EventEmitter

  constructor: (@socket, @id) -> @messageBuffer = new Buffer 0

  send: (msg) ->
    @socket.write Processor.messageToBin msg if @isConnected

  isConnected: false

class Server extends events.EventEmitter

  constructor: (opt={}) ->

    { @port, @host, @specificationNr, @loginFunctionId } = opt

    @port             ?= 5010
    @specificationNr  ?= Properties.DEFAULT_SPECIFICATION_NR
    @loginFunctionId  ?= Properties.DEFAULT_LOGIN_FUNCTION_ID

    console.info "Starting 7F server with SpecNr: #{@specificationNr} and LoginId: #{@loginFunctionId}"

    @clients = {}
    @_socket = net.createServer @onSocket
    @_socket.on "error", (err) ->
      if err.code is 'EADDRNOTAVAIL'
        console.error "Host address is not available"
      else console.error err

  connect: (cb)->
    if @host?
      @_socket.listen @port, @host, (err) =>
        if err then console.error err
        else console.info "server bound to #{@host}:#{@port}"
        cb? err
    else
      @_socket.listen @port, (err) =>
        if err then console.error err
        else console.info "7F server is listening on port #{@port}"
        cb? err

  onSocket: (socket) =>
    client = new Client socket
    socket.on "data", (data) =>
      client.messageBuffer = Buffer.concat [client.messageBuffer, new Buffer(data,'binary')]
      messages = Processor.checkMessageBuffer client
      if messages instanceof Error
        console.error messages.message
        # close the connection to protect the server
        console.info "Resetting connection"
        socket.destroy()
        client.socket.destroy()
      if messages?.length > 0
        @processMessage client, m for m in messages

    socket.on "error", (err) ->
      console.error "An 7F client error occourred: ", err.message
      console.info "Resetting connection"
      socket.destroy()

  processMessage: (client, bin) ->
    bmsg = Processor.binToBasicMessage bin
    if client.isConnected
      client.emit "message", Processor.basicMessageToAdvancedMessage bmsg
    else
      @onLogin bmsg, client if Processor.isLoginMessage bmsg

  onLogin: (msg, client) ->
    req = Processor.basicMessageToLoginRequest msg
    if Processor.isValidLoginRequest req, @specificationNr
      client.id = req.locationId.toString()
      client.isConnected = true
      @addClient client
      @sendLoginResponse req, client.id
      @emit "client", client
    else
      @sendLoginResponse req, client.id, client.socket

  addClient: (client) ->
    if @clients[client.id]?
      reconnected = yes
      @clients[client.id].isConnected = false
      @clients[client.id].socket.destroy()
      delete @clients[client.id]
    @clients[client.id] = client
    @emit "reconnect", client if reconnected

  sendLoginResponse: (req, id, socket) ->
    res  = Processor.loginRequestToLoginResponse req, @specificationNr
    bmsg = Processor.loginResponseToBasicMessage res
    @send bmsg, id, socket

  send: (msg, id, socket= @clients[id]?.socket) ->
    socket?.write Processor.messageToBin msg

module.exports = Server
