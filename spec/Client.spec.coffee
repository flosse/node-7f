global.buster = require "buster"
global.sinon  = require "sinon"
buster.spec.expose()

Client = require "../src/Client"

describe "Client", ->

  describe "constructor", ->
    it "throws an error if no locationId was specified", ->
      (expect -> new Client).toThrow()

    it "takes some properties as second argument", ->
      c = new Client 0,
        specificationNr: 3
        loginFunctionId: 4
        host: "192.168.2.1"
        port: 3333
      (expect c.id).toEqual 0
      (expect c.specificationNr).toEqual 3
      (expect c.loginFunctionId).toEqual 4
      (expect c.host).toEqual "192.168.2.1"
      (expect c.port).toEqual 3333

    it "has some default properties", ->
      c = new Client 0
      (expect c.specificationNr).toEqual 1
      (expect c.loginFunctionId).toEqual 1
      (expect c.host).toEqual "127.0.0.1"
      (expect c.port).toEqual 5010

  describe "connect & disconnect", ->

    it "is a function", ->
      (expect typeof new Client(0).connect).toEqual "function"
      (expect typeof new Client(0).disconnect).toEqual "function"

  describe "login", ->

    it "is a function", ->
      (expect typeof new Client(0).login).toEqual "function"
