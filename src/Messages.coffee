###
Copyright (c) 2009 - 2015 Markus Kohlhase <mail@markus-kohlhase.de>
###

class BasicHeader

  constructor: (opt={}) -> { @length, @nr, @protocolId } = opt

class AdvancedHeader

  constructor: (opt={}) ->

    { @logicalNr
      @command
      @type
      @count
    } = opt

class BasicMessage

  constructor: (@header, @data) ->

class AdvancedMessage extends BasicMessage

  constructor: (header, @advancedHeader, data) ->
    super header, data

class LoginRequest extends BasicMessage

  constructor: (header, opt={}) ->
    super header
    { @functionId, @locationId, @specificationNr } = opt

class LoginResponse extends BasicMessage

  constructor: (header, opt={}) ->
    super header
    { @specificationNr, @errors } = opt
    @errors  ?= []

module.exports =
  BasicHeader     : BasicHeader
  AdvancedHeader  : AdvancedHeader
  BasicMessage    : BasicMessage
  AdvancedMessage : AdvancedMessage
  LoginResponse   : LoginResponse
  LoginRequest    : LoginRequest
