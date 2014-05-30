chai    = require "chai"
expect  = chai.expect

describe "Processor", ->

  before ->
    @p = require "../src/Processor"

  it "is a class", ->
    (expect typeof @p).to.equal "function"

  describe "basicHeaderToBin", ->

    it "is a function", ->
      (expect typeof @p.basicHeaderToBin).to.equal "function"

    it "returns a buffer", ->
      h = { length:3, nr: 5, protocolId: 7 }
      buff = @p.basicHeaderToBin h
      (expect typeof buff).to.equal "object"
      (expect buff.length).to.equal 12

  describe "basicMessageToAdvancedMessage", ->

    it "is a function", ->
      (expect typeof @p.basicMessageToAdvancedMessage).to.equal "function"

    it "extracts three properties", ->
      d = new Buffer 10
      d.writeUInt32LE 66, 0
      d[4] = 33
      d[5] = 2
      d.writeUInt32LE 99, 6
      basicMsg = header: {length: 4, nr:5, protocolId: 4}, data: d
      a = @p.basicMessageToAdvancedMessage basicMsg
      (expect a.advancedHeader.logicalNr) .to.equal 66
      (expect a.advancedHeader.command)   .to.equal 33
      (expect a.advancedHeader.type)      .to.equal 2
      (expect a.advancedHeader.count)     .to.equal 99

  describe "advancedMessageToBasicMessage", ->

    it "is a function", ->
      (expect typeof @p.advancedMessageToBasicMessage).to.equal "function"

  describe "basicMessageToLoginRequest", ->

    it "is a function", ->
      (expect typeof @p.basicMessageToLoginRequest).to.equal "function"

    it "converts it", ->
      d = new Buffer 52
      d.writeUInt32BE 67, 8
      bm = header: { length: 52 }, data: d
      lr = @p.basicMessageToLoginRequest bm
      (expect lr.locationId).to.equal 67

  describe "basicMessageToLoginResponse", ->

    it "is a function", ->
      (expect typeof @p.basicMessageToLoginResponse).to.equal "function"

    it "converts it", ->
      d = new Buffer 52
      d.writeUInt32BE 8, 0
      d.writeUInt32BE 0, 4
      bm = header: { length: 52 }, data: d
      lr = @p.basicMessageToLoginResponse bm
      (expect lr.specificationNr).to.equal 8
      (expect lr.errors).to.eql []

      err = 0x3
      d.writeUInt32BE err, 4
      lr = @p.basicMessageToLoginResponse bm
      bm = header: { length: 52 }, data: d
      (expect lr.errors).to.eql [0, 1]

  describe "loginRequestToBasicMessage", ->

    it "is a function", ->
      (expect typeof @p.loginRequestToBasicMessage).to.equal "function"

    it "converts to a LoginRequest with default values if they are not specified", ->
      bm = @p.loginRequestToBasicMessage { locationId: 5 }
      (expect bm.header.length).to.equal 52
      (expect bm.header.nr).to.equal 1
      (expect bm.header.protocolId).to.equal 0x7f
      lreq = @p.basicMessageToLoginRequest bm
      (expect lreq.specificationNr).to.equal 1
      (expect @p.isValidLoginRequest lreq, 1).to.equal true
      (expect bm.data.length).to.equal 52
      (expect bm.data.readUInt32BE 0).to.equal 1 # specificationNr
      (expect bm.data.readUInt32BE 4).to.equal 1 # functionId
      (expect bm.data.readUInt32BE 8).to.equal 5 # locationId

  describe "loginRequestToLoginResponse", ->

    it "is a function", ->
      (expect typeof @p.loginRequestToLoginResponse).to.equal "function"

  describe "getErrorsFromLoginRequest", ->

    it "is a function", ->
      (expect typeof @p.getErrorsFromLoginRequest).to.equal "function"

  describe "isValidLoginRequest", ->

    it "is a function", ->
      (expect typeof @p.isValidLoginRequest).to.equal "function"

  describe "loginResponseToBasicMessage", ->

    it "is a function", ->
      (expect typeof @p.loginResponseToBasicMessage).to.equal "function"

  describe "isLoginMessage", ->

    it "is a function", ->
      (expect typeof @p.isLoginMessage).to.equal "function"

    it "tests the message", ->
      msg =
        header:
          length: 52
          nr: 1
        data: new Buffer 52
      (expect @p.isLoginMessage msg).to.equal true
      msg.data = new Buffer 33
      (expect @p.isLoginMessage msg).to.equal false
      msg.data = new Buffer 52
      msg.header.nr = 8
      (expect @p.isLoginMessage msg).to.equal false

  describe "binToBasicMessage", ->

    it "is a function", ->
      (expect typeof @p.binToBasicMessage).to.equal "function"

    it "takes a buffer with min. 12 bytes", ->
      (expect => @p.binToBasicMessage()).to.throw()
      (expect => @p.binToBasicMessage(new Buffer(3))).to.throw()
      d = new Buffer 13
      d.writeUInt32BE 44, 0
      d[12] = 5
      x = null
      (expect => x = @p.binToBasicMessage d).not.to.throw()
      (expect x.header.length).to.equal 44
      (expect x.data[0]).to.equal 5

  describe "messageToBin", ->

    it "is a function", ->
      (expect typeof @p.messageToBin).to.equal "function"

  describe "basicMessageToBin", ->

    it "is a function", ->
      (expect typeof @p.basicMessageToBin).to.equal "function"

    it "calculates the length if not specified", ->
      msg =
        header:
          nr: 5
          protocolId: 0x8f
        data: new Buffer(4)
      buff = @p.basicMessageToBin msg
      (expect typeof buff).to.equal "object"
      (expect buff.length).to.equal 16
      # CAUTION: the 'length' property defines the user data length!
      (expect buff.readUInt32BE 0).to.equal 4

      msg =
        header:
          nr: 5
          protocolId: 0x8f
      buff = @p.basicMessageToBin msg
      (expect typeof buff).to.equal "object"
      (expect buff.length).to.equal 12
      (expect buff.readUInt32BE 0).to.equal 0

  describe "getErrorByteFromLoginResponse", ->

    xit "is a function", ->
      (expect typeof @p.getErrorByteFromLoginResponse).to.equal "function"

  describe "checkMessageBuffer method", ->

    before ->
      @fn = @p.checkMessageBuffer
      @c  = {messageBuffer: null}

    it "returns an array", ->
      (expect @fn())  .to.eql []
      (expect @fn {}) .to.eql []

    it "recognizes a message", ->
      @c.messageBuffer = new Buffer 14
      @c.messageBuffer.writeUInt32BE 2,    0
      @c.messageBuffer.writeUInt32BE 3,    4
      @c.messageBuffer.writeUInt32BE 0x7f, 8
      @c.messageBuffer[12] = 0xa
      @c.messageBuffer[13] = 0xb
      msgs = @fn @c
      (expect msgs.length).to.equal 1
      (expect msgs[0].readUInt32BE 0).to.equal 2
      (expect msgs[0].length).to.equal 14
      (expect msgs[0][12]).to.equal 0xa

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
      (expect msgs.length).to.equal 2

    it "returns an error if the protocol id is not valid", ->
      @c.messageBuffer = new Buffer 14
      @c.messageBuffer.writeUInt32BE 2,    0
      @c.messageBuffer.writeUInt32BE 3,    4
      @c.messageBuffer.writeUInt32BE 0x33, 8
      @c.messageBuffer[12] = 0xa
      @c.messageBuffer[13] = 0xb
      msgs = @fn @c
      (expect msgs instanceof Error).to.equal true
