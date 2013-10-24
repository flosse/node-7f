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

  constructor: (@host="127.0.0.1", @port=5010
  ,@specificationNr = Properties.DEFAULT_SPECIFICATION_NR
  ,@loginFunctionId = Properties.DEFAULT_LOGIN_FUNCTION_ID) ->

    console.info "Starting 7F server: #{@host}:#{@port}"
    console.info "SpecNr: #{@specificationNr}, LoginId: #{@loginFunctionId}"

    @clients = {}
    server = net.createServer @onSocket
    server.on "error", (err) ->
      if err.code is 'EADDRNOTAVAIL'
        console.error "Address not available"
      else console.error err
    server.listen @port, @host, -> console.info "server bound"

  onSocket: (socket) =>
    client = new Client socket
    socket.on "data", (data) =>
      msg = Processor.binToBasicMessage data
      if client.isConnected
        client.emit "message", Processor.basicMessageToAdvancedMessage msg
      else
        @onLogin msg, client if Processor.isLoginRequest msg

  onLogin: (msg, client) ->
    req = Processor.basicMessageToLoginRequest msg
    if Processor.isValidLoginRequest req, @specificationNr
      client.id = req.locationId
      client.isConnected = true
      @addClient client
      @sendLoginResponse req, client.id
      @emit "client", client

  addClient: (client) ->
    if @clients[client.id]?
      console.info "Client with location id #{ client.id } has reconnected."
      @clients[client.id].isConnected = false
      @clients[client.id].socket.destroy()
      delete @clients[client.id]
    @clients[client.id] = client
    console.info "new client was added"

  sendLoginResponse: (req, id) ->
    res = Processor.loginRequestToLoginResponse req, @specificationNr
    bmsg = Processor.loginResponseToBasicMessage res
    @send bmsg, id

  send: (msg, id) ->
    @clients[id].socket.write Processor.messageToBin msg

module.exports = Server
