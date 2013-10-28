###
Copyright (c) 2009 - 2013, Markus Kohlhase <mail@markus-kohlhase.de>
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

  connect: (cb)->
    @socket = net.connect { @port, @host }, =>
      @isConnected = true
      console.log "client #{@id} is now connected"
      cb?()

    @socket.on "data", (binMsg) =>
      msg = Processor.binToBasicMessage binMsg
      if @isLoggedIn
        @emit "message", Processor.basicMessageToAdvancedMessage msg
      else
        @onLogin msg if Processor.isLoginMessage msg

  onLogin: (msg) ->
    res = Processor.basicMessageToLoginResponse msg
    if Processor.isValidLoginResponse res, @specificationNr
      console.log "client #{@id} is now logged in"
      @isLoggedIn = true
      @emit "login"
    else
      errors = (id for id,bit of LoginError when (bit in res.errors))
      @emit "login-error", new Error errors.join(',')

    @socket.on "end", =>
      console.log "client #{@id} is now disconnected"
      @isConnected = false
      @isLoggedIn  = false

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
