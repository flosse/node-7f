###
Copyright (c) 2009 - 2013 Markus Kohlhase <mail@markus-kohlhase.de>
###

class BasicHeader

  constructor: (opt={}) ->
    @length          = opt.length     if opt.length?
    @nr              = opt.nr         if opt.nr?
    @protocolId      = opt.protocolId if opt.protocolId?

class AdvancedHeader

  constructor: (opt={}) ->
    @logicalNr       = opt.logicalNr  if opt.logicalNr?
    @command         = opt.command    if opt.command?
    @type            = opt.type       if opt.type?
    @count           = opt.count      if opt.count?
    @timestamp       = opt.timestamp  or new Date().getTime()

class BasicMessage

  constructor: (@header, @data = new Buffer 0) ->

class AdvancedMessage extends BasicMessage

  constructor: (@header, @advancedHeader, @data = new Buffer 0) ->
    super @header, @data

class LoginRequest extends BasicMessage

  constructor: (header, opt={}) ->
    super header
    @functionId      = opt.functionId
    @locationId      = opt.locationId
    @specificationNr = opt.specificationNr

class LoginResponse extends BasicMessage

  constructor: (header, opt={}) ->
    super header
    @specificationNr = opt.specificationNr
    @errors          = opt.erros or []

module.exports =
  BasicHeader     : BasicHeader
  AdvancedHeader  : AdvancedHeader
  BasicMessage    : BasicMessage
  AdvancedMessage : AdvancedMessage
  LoginResponse   : LoginResponse
  LoginRequest    : LoginRequest
