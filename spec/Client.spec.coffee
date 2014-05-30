chai   = require "chai"
expect = chai.expect

Client = require "../src/Client"

describe "Client", ->

  describe "constructor", ->
    it "throws an error if no locationId was specified", ->
      (expect -> new Client).to.throw()

    it "takes some properties as second argument", ->
      c = new Client 0,
        specificationNr: 3
        loginFunctionId: 4
        host: "192.168.2.1"
        port: 3333
      (expect c.id).to.equal 0
      (expect c.specificationNr).to.equal 3
      (expect c.loginFunctionId).to.equal 4
      (expect c.host).to.equal "192.168.2.1"
      (expect c.port).to.equal 3333

    it "has some default properties", ->
      c = new Client 0
      (expect c.specificationNr).to.equal 1
      (expect c.loginFunctionId).to.equal 1
      (expect c.host).to.equal "127.0.0.1"
      (expect c.port).to.equal 5010

  describe "connect & disconnect", ->

    it "is a function", ->
      (expect typeof new Client(0).connect).to.equal "function"
      (expect typeof new Client(0).disconnect).to.equal "function"

  describe "login", ->

    it "is a function", ->
      (expect typeof new Client(0).login).to.equal "function"
