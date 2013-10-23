global.buster = require "buster"
global.sinon  = require "sinon"
buster.spec.expose()

describe "Processor", ->

  before ->
    @p = require "../src/Processor"

  it "is a class", ->
    (expect typeof @p).toEqual "function"

  describe "basicHeaderToBin", ->

    it "is a function", ->
      (expect typeof @p.basicHeaderToBin).toEqual "function"

    it "is returns a buffer", ->
      h = { length:3, nr: 5, protocolId: 7 }
      buff = @p.basicHeaderToBin h
      (expect typeof buff).toEqual "object"
      (expect buff.length).toEqual 12

  describe "basicMessageToAdvancedMessage", ->

    it "is a function", ->
      (expect typeof @p.basicMessageToAdvancedMessage).toEqual "function"

    it "extracts three properties", ->
      d = new Buffer 10
      d.writeUInt32LE 66, 0
      d[4] = 33
      d[5] = 2
      d.writeUInt32LE 99, 6
      basicMsg = header: {length: 4, nr:5, protocolId: 4}, data: d
      a = @p.basicMessageToAdvancedMessage basicMsg
      (expect a.advancedHeader.logicalNr).toEqual 66
      (expect a.advancedHeader.command).toEqual 33
      (expect a.advancedHeader.type).toEqual 2
      (expect a.advancedHeader.count).toEqual 99

  describe "advancedMessageToBasicMessage", ->

    it "is a function", ->
      (expect typeof @p.advancedMessageToBasicMessage).toEqual "function"

  describe "basicMessageToLoginRequest", ->

    it "is a function", ->
      (expect typeof @p.basicMessageToLoginRequest).toEqual "function"

  describe "loginRequestToLoginResponse", ->

    it "is a function", ->
      (expect typeof @p.loginRequestToLoginResponse).toEqual "function"

  describe "getErrorsFromLoginRequest", ->

    it "is a function", ->
      (expect typeof @p.getErrorsFromLoginRequest).toEqual "function"

  describe "isValidLoginRequest", ->

    it "is a function", ->
      (expect typeof @p.isValidLoginRequest).toEqual "function"

  describe "loginResponseToBasicMessage", ->

    it "is a function", ->
      (expect typeof @p.loginResponseToBasicMessage).toEqual "function"

  describe "isLoginRequest", ->

    it "is a function", ->
      (expect typeof @p.isLoginRequest).toEqual "function"

  describe "binToBasicMessage", ->

    it "is a function", ->
      (expect typeof @p.binToBasicMessage).toEqual "function"

    it "takes a buffer with min. 12 bytes", ->
      (expect => @p.binToBasicMessage()).toThrow()
      (expect => @p.binToBasicMessage(new Buffer(3))).toThrow()
      d = new Buffer 13
      d.writeUInt32BE 44, 0
      d[12] = 5
      x = null
      (expect => x = @p.binToBasicMessage d).not.toThrow()
      (expect x.header.length).toEqual 44
      (expect x.data[0]).toEqual 5

  describe "messageToBin", ->

    it "is a function", ->
      (expect typeof @p.messageToBin).toEqual "function"

  describe "basicMessageToBin", ->

    it "is a function", ->
      (expect typeof @p.basicMessageToBin).toEqual "function"

  describe "getErrorByteFromLoginResponse", ->

    it "is a function", ->
      (expect typeof @p.getErrorByteFromLoginResponse).toEqual "function"
