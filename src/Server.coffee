###
Copyright (c) 2009 - 2013, Markus Kohlhase <mail@markus-kohlhase.de>
###

net         = require "net"
events      = require "events"

constants   = require "./Constants"
messages    = require "./Messages"

Processor       = require "./Processor"
AdvancedMessage = messages.AdvancedMessage
Properties      = constants.Properties

class Client extends events.EventEmitter

  constructor: (@socket, @id) ->

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
      bmsg = Processor.binToBasicMessage data
      if client.isConnected
        client.emit "message", Processor.basicMessageToAdvancedMessage bmsg
      else
        @onLogin bmsg, client if Processor.isLoginMessage bmsg

  onLogin: (msg, client) ->
    req = Processor.basicMessageToLoginRequest msg
    if Processor.isValidLoginRequest req, @specificationNr
      client.id = req.locationId
      client.isConnected = true
      @addClient client
      @sendLoginResponse req, client.id
      @emit "client", client
    else
      @sendLoginResponse req, client.id, client.socket

  addClient: (client) ->
    if @clients[client.id]?
      console.info "Client with location id #{ client.id } has reconnected."
      @clients[client.id].isConnected = false
      @clients[client.id].socket.destroy()
      delete @clients[client.id]
    @clients[client.id] = client
    console.info "new client was added"

  sendLoginResponse: (req, id, socket) ->
    res  = Processor.loginRequestToLoginResponse req, @specificationNr
    bmsg = Processor.loginResponseToBasicMessage res
    @send bmsg, id, socket

  send: (msg, id, socket= @clients[id]?.socket) ->
    socket?.write Processor.messageToBin msg

module.exports = Server
