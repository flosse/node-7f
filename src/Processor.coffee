###
Copyright (c) 2009 - 2013, Markus Kohlhase <mail@markus-kohlhase.de>
###

bits            = require "bits"
messages        = require "./Messages"
constants       = require "./Constants"

{
  BasicMessage
  BasicHeader
  AdvancedMessage
  AdvancedHeader
  LoginRequest
  LoginResponse
} = messages

{ LoginError
  Properties
} = constants

class Processor

  @basicHeaderToBin: (h) ->

    bmsg = new Buffer 12
    bmsg.writeUInt32BE h.length, 0
    bmsg.writeUInt32BE h.nr, 4
    bmsg.writeUInt32BE h.protocolId, 8
    bmsg

  @basicMessageToAdvancedMessage: (msg) ->

    h = new AdvancedHeader
      logicalNr : msg.data.readUInt32LE 0
      command   : msg.data.readUInt8 4
      type      : msg.data.readUInt8 5
      count     : msg.data.readUInt32LE 6

    data = new Buffer msg.data.length - 10
    msg.data.copy data, 0, 10

    new AdvancedMessage msg.header, h, data

  @advancedMessageToBasicMessage: (msg) ->
    bmsg = new BasicMessage msg.header
    bmsg.data = new Buffer(msg.data.length + 10)
    h = msg.advancedHeader
    bmsg.data.writeUInt32LE h.logicalNr, 0
    bmsg.data.writeUInt8 h.command, 4
    bmsg.data.writeUInt8 h.type, 5
    bmsg.data.writeUInt32LE h.count, 6
    msg.data.copy bmsg.data, 10, 0
    bmsg

  @basicMessageToLoginRequest: (msg) ->
    new LoginRequest msg.header,
      specificationNr: msg.data.readUInt32BE 0
      functionId:      msg.data.readUInt32BE 4
      locationId:      msg.data.readUInt32BE 8

  @loginRequestToBasicMessage: (req) ->

    { specificationNr
      functionId
      locationId
    } = req

    specificationNr ?= Properties.DEFAULT_SPECIFICATION_NR
    functionId      ?= Properties.DEFAULT_LOGIN_FUNCTION_ID

    len = Properties.DEFAULT_LOGIN_REQUEST_MESSAGE_LENGTH
    data = new Buffer len - 12
    data.writeUInt32BE specificationNr, 0
    data.writeUInt32BE functionId,      4
    data.writeUInt32BE locationId,      8
    h = req.header ?= {}
    h.length       =  len
    h.nr          ?=  Properties.DEFAULT_LOGIN_REQUEST_MESSAGE_NR
    h.protocolId  ?=  Properties.DEFAULT_PROTOCOL_ID

    new BasicMessage h, data

  @loginRequestToLoginResponse: (req, specNr) ->

    throw new Error "login request must not be null" unless req?

    header = new BasicHeader
      length           : Properties.DEFAULT_LOGIN_RESPONSE_MESSAGE_LENGTH
      nr               : Properties.DEFAULT_LOGIN_RESPONSE_MESSAGE_NR
      protocolId       : Properties.DEFAULT_PROTOCOL_ID

    new LoginResponse header,
      errors           : Processor.getErrorsFromLoginRequest req, specNr
      specificationNr  : specNr

  @getErrorsFromLoginRequest: (req, specNr) ->

    throw new Error "login request must not be null" unless req?
    err = []

    if req.specificationNr isnt specNr
      err.push LoginError.INVALID_SPECIFICATION_NUMBER

    #if req.functionId isnt @functionId
      # !! ATTENTION !
      # HERE IS A BUG IN THE DEVICE IMPLEMENATION.
      # DUE TO THIS, IT WILL BE IGNORED !!
      # err.add( LoginError.INVALID_FUNCION_ID );

    if req.locationId > Properties.DEFAULT_LOCATION_ID_MAX or
       req.locationId < Properties.DEFAULT_LOCATION_ID_MIN
        err.push LoginError.INVALID_LOCATION_ID

    if req.header.protocolId isnt Properties.DEFAULT_PROTOCOL_ID
      err.push LoginError.INVALID_PROTOCOL_ID

    err

  @isValidLoginRequest: (msg, specNr) ->

    return false unless msg?
    h = msg.header

    if h.length isnt Properties.DEFAULT_LOGIN_REQUEST_MESSAGE_LENGTH
      console.warn "Non valid message length: #{ h.length }"
      return false

    if h.nr isnt Properties.DEFAULT_LOGIN_REQUEST_MESSAGE_NR
      console.warn "Non valid message number: #{ h.nr }"
      return false

    if h.protocolId isnt Properties.DEFAULT_PROTOCOL_ID
      console.warn "Non valid protocol id: #{ h.protocolId }"
      return false

    if msg.specificationNr isnt specNr
      console.warn "Non valid specification number: #{ msg.specificationNr }"
      return false

    if Properties.DEFAULT_LOCATION_ID_MAX < msg.locationId < Properties.DEFAULT_LOCATION_ID_MIN
      console.warn "location id: #{ msg.locationId }"
      return false

    true

  @loginResponseToBasicMessage: (res) ->

    msg = new BasicMessage res.header
    msg.data = new Buffer 52 # 12 + 40
    msg.data.writeUInt32BE res.specificationNr, 0
    msg.data.writeUInt32BE Processor.getErrorByteFromLoginResponse(res), 4
    msg

  @isLoginMessage: (msg) ->
    msg.header.length is Properties.DEFAULT_LOGIN_REQUEST_MESSAGE_LENGTH  and
    msg.header.nr     is Properties.DEFAULT_LOGIN_REQUEST_MESSAGE_NR      and
    msg.data.length   is Properties.DEFAULT_LOGIN_REQUEST_MESSAGE_LENGTH - 12

  @binToBasicMessage: (msg) ->
    throw new Error "byte array must not be null" unless msg?
    throw new Error "message length is too short" unless msg.length >= 12

    new BasicMessage(new BasicHeader(
        length: msg.readUInt32BE(0)
        nr: msg.readUInt32BE(4)
        protocolId: msg.readUInt32BE(8)),
      msg.slice 12)

  @messageToBin: (msg) ->
    if msg.advancedHeader?
      msg = Processor.advancedMessageToBasicMessage msg
    Processor.basicMessageToBin msg

  @basicMessageToBin: (msg) ->
    len = 12 + (msg.data?.length or 0)
    msg.header.length ?= len
    header = Processor.basicHeaderToBin msg.header
    bin = new Buffer len
    header.copy bin
    msg.data.copy bin, header.length if msg.data?
    bin

  @getErrorByteFromLoginResponse: (res) ->
    if res.errors.length is 0 then 0
    else
      byte = 0
      for err in res.errors
        byte = bits.set byte, err
      byte

module.exports = Processor
