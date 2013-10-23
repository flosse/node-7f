global.buster = require "buster"
global.sinon  = require "sinon"
buster.spec.expose()

describe "Messages", ->

  before ->
    @m = require "../src/Messages"

  it "contains classes", ->
    (expect typeof @m.BasicHeader     ).toEqual "function"
    (expect typeof @m.AdvancedHeader  ).toEqual "function"
    (expect typeof @m.BasicMessage    ).toEqual "function"
    (expect typeof @m.AdvancedMessage ).toEqual "function"
    (expect typeof @m.LoginResponse   ).toEqual "function"
    (expect typeof @m.LoginRequest    ).toEqual "function"

  describe "BasicHeader", ->

    it "has three properties", ->
      (expect (new @m.BasicHeader({length:4})).length).toEqual 4
      (expect (new @m.BasicHeader({nr:3})).nr).toEqual 3
      (expect (new @m.BasicHeader({protocolId:5})).protocolId).toEqual 5

  describe "AdvancedHeader", ->
    it "has fife properties", ->
      (expect (new @m.AdvancedHeader({logicalNr:1})).logicalNr).toEqual 1
      (expect (new @m.AdvancedHeader({command:2})).command).toEqual 2
      (expect (new @m.AdvancedHeader({type:3})).type).toEqual 3
      (expect (new @m.AdvancedHeader({count:4})).count).toEqual 4
      (expect (new @m.AdvancedHeader({timestamp:5})).timestamp).toEqual 5

  describe "BasicMessage", ->
    it "has two properties", ->
      (expect (new @m.BasicMessage("foo")).header).toEqual "foo"
      (expect (new @m.BasicMessage).data instanceof Buffer).toEqual true
      (expect (new @m.BasicMessage("bar", "baz")).data).toEqual "baz"

  describe "AdvancedMessage", ->
    it "has three properties", ->
      m = new @m.AdvancedMessage "foo", "bar"
      (expect m.header).toEqual "foo"
      (expect m.data instanceof Buffer).toEqual true
      (expect m.advancedHeader).toEqual "bar"

  describe "LoginRequest", ->
    it "has four properties", ->
      m = new @m.LoginRequest "foo",
        functionId: 1
        locationId: 2
        specificationNr: 3
      (expect m.header).toEqual "foo"
      (expect m.functionId).toEqual 1
      (expect m.locationId).toEqual 2
      (expect m.specificationNr).toEqual 3

  describe "LoginResponse", ->
    it "has three properties", ->
      m = new @m.LoginResponse "foo", specificationNr: 3
      (expect m.header).toEqual "foo"
      (expect m.specificationNr).toEqual 3
      (expect m.errors instanceof Array).toEqual true
