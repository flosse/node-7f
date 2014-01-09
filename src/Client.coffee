###
Copyright (c) 2009 - 2014, Markus Kohlhase <mail@markus-kohlhase.de>
###

net         = require "net"
events      = require "events"

constants   = require "./Constants"

{ BasicHeader
  LoginRequest
  LoginResponse
} = require "./Messages"

{ LoginError
  Properties
} = constants

Processor = require "./Processor"

class Client extends events.EventEmitter

  constructor: (@id, opt={}) ->
    if typeof @id isnt "number" or @id < 0
      return throw new Error "invalid loaction ID"

    { @host
      @port
      @specificationNr
      @loginFunctionId
    } = opt

    @host             ?= "127.0.0.1"
    @port             ?= 5010
    @specificationNr  ?= Properties.DEFAULT_SPECIFICATION_NR
    @loginFunctionId  ?= Properties.DEFAULT_LOGIN_FUNCTION_ID

    @messageBuffer    = new Buffer 0

  connect: (cb) ->
    @socket = net.connect { @port, @host }, =>
      @isConnected = true
      @emit "connect"
      cb?()

    @socket.on "data", (data) =>
      @messageBuffer = Buffer.concat [@messageBuffer, new Buffer(data,'binary')]
      messages = Processor.checkMessageBuffer @
      if messages instanceof Error
        console.error messages.message
        # close the connection to protect the client
        @socket.end()
      if messages?.length > 0
        @processMessage m for m in messages

    @socket.on "error", (err) => @emit "error", err

  processMessage: (bin) ->
    msg = Processor.binToBasicMessage bin
    if @isLoggedIn
      @emit "message", Processor.basicMessageToAdvancedMessage msg
    else
      @onLogin msg if Processor.isLoginMessage msg

  onLogin: (msg) ->
    res = Processor.basicMessageToLoginResponse msg
    if Processor.isValidLoginResponse res, @specificationNr
      @isLoggedIn = true
      @emit "login"
    else
      errors = (id for id,bit of LoginError when (bit in res.errors))
      @emit "login-error", new Error errors.join(',')

    @socket.on "end", =>
      @isConnected = false
      @isLoggedIn  = false
      @emit "disconnect"

  disconnect: -> @socket.end()

  login: ->
    req = Processor.loginRequestToBasicMessage
      functionId: @loginFunctionId
      locationId: @id
      specificationNr: @specificationNr
    if @isConnected then @send req
    else @connect => @send req

  send: (msg) ->
    @socket.write Processor.messageToBin msg if @isConnected

module.exports = Client
