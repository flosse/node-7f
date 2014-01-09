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

    it "returns a buffer", ->
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

    it "converts it", ->
      d = new Buffer 52
      d.writeUInt32BE 67, 8
      bm = header: { length: 52 }, data: d
      lr = @p.basicMessageToLoginRequest bm
      (expect lr.locationId).toEqual 67

  describe "basicMessageToLoginResponse", ->

    it "is a function", ->
      (expect typeof @p.basicMessageToLoginResponse).toEqual "function"

    it "converts it", ->
      d = new Buffer 52
      d.writeUInt32BE 8, 0
      d.writeUInt32BE 0, 4
      bm = header: { length: 52 }, data: d
      lr = @p.basicMessageToLoginResponse bm
      (expect lr.specificationNr).toEqual 8
      (expect lr.errors).toEqual []

      err = 0x3
      d.writeUInt32BE err, 4
      lr = @p.basicMessageToLoginResponse bm
      bm = header: { length: 52 }, data: d
      (expect lr.errors).toEqual [0, 1]

  describe "loginRequestToBasicMessage", ->

    it "is a function", ->
      (expect typeof @p.loginRequestToBasicMessage).toEqual "function"

    it "converts to a LoginRequest with default values if they are not specified", ->
      bm = @p.loginRequestToBasicMessage { locationId: 5 }
      (expect bm.header.length).toEqual 52
      (expect bm.header.nr).toEqual 1
      (expect bm.header.protocolId).toEqual 0x7f
      lreq = @p.basicMessageToLoginRequest bm
      (expect lreq.specificationNr).toEqual 1
      (expect @p.isValidLoginRequest lreq, 1).toEqual true
      (expect bm.data.length).toEqual 52
      (expect bm.data.readUInt32BE 0).toEqual 1 # specificationNr
      (expect bm.data.readUInt32BE 4).toEqual 1 # functionId
      (expect bm.data.readUInt32BE 8).toEqual 5 # locationId

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

  describe "isLoginMessage", ->

    it "is a function", ->
      (expect typeof @p.isLoginMessage).toEqual "function"

    it "tests the message", ->
      msg =
        header:
          length: 52
          nr: 1
        data: new Buffer 52
      (expect @p.isLoginMessage msg).toEqual true
      msg.data = new Buffer 33
      (expect @p.isLoginMessage msg).toEqual false
      msg.data = new Buffer 52
      msg.header.nr = 8
      (expect @p.isLoginMessage msg).toEqual false

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

    it "calculates the length if not specified", ->
      msg =
        header:
          nr: 5
          protocolId: 0x8f
        data: new Buffer(4)
      buff = @p.basicMessageToBin msg
      (expect typeof buff).toEqual "object"
      (expect buff.length).toEqual 16
      # CAUTION: the 'length' property defines the user data length!
      (expect buff.readUInt32BE 0).toEqual 4

      msg =
        header:
          nr: 5
          protocolId: 0x8f
      buff = @p.basicMessageToBin msg
      (expect typeof buff).toEqual "object"
      (expect buff.length).toEqual 12
      (expect buff.readUInt32BE 0).toEqual 0

  describe "getErrorByteFromLoginResponse", ->

    it "is a function", ->
      (expect typeof @p.getErrorByteFromLoginResponse).toEqual "function"

  describe "checkMessageBuffer method", ->

    before ->
      @fn = @p.checkMessageBuffer
      @c  = {messageBuffer: null}

    it "returns an array", ->
      (expect @fn()).toEqual []
      (expect @fn {}).toEqual []

    it "recognizes a message", ->
      @c.messageBuffer = new Buffer 14
      @c.messageBuffer.writeUInt32BE 2,    0
      @c.messageBuffer.writeUInt32BE 3,    4
      @c.messageBuffer.writeUInt32BE 0x7f, 8
      @c.messageBuffer[12] = 0xa
      @c.messageBuffer[13] = 0xb
      msgs = @fn @c
      (expect msgs.length).toEqual 1
      (expect msgs[0].readUInt32BE 0).toEqual 2
      (expect msgs[0].length).toEqual 14
      (expect msgs[0][12]).toEqual 0xa

    it "recognizes multiple messages", ->

      @c.messageBuffer = new Buffer 14 + 33

      # first message
      @c.messageBuffer.writeUInt32BE 2,    0
      @c.messageBuffer.writeUInt32BE 3,    4
      @c.messageBuffer.writeUInt32BE 0x7f, 8

      # second message
      @c.messageBuffer.writeUInt32BE 21,   14
      @c.messageBuffer.writeUInt32BE 5,    28
      @c.messageBuffer.writeUInt32BE 0x7f, 22

      msgs = @fn @c
      (expect msgs.length).toEqual 2

    it "returns an error if the protocol id is not valid", ->
      @c.messageBuffer = new Buffer 14
      @c.messageBuffer.writeUInt32BE 2,    0
      @c.messageBuffer.writeUInt32BE 3,    4
      @c.messageBuffer.writeUInt32BE 0x33, 8
      @c.messageBuffer[12] = 0xa
      @c.messageBuffer[13] = 0xb
      msgs = @fn @c
      (expect msgs instanceof Error).toEqual true
