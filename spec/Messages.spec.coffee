chai    = require "chai"
expect  = chai.expect

describe "Messages", ->

  before ->
    @m = require "../src/Messages"

  it "contains classes", ->
    (expect typeof @m.BasicHeader     ).to.equal "function"
    (expect typeof @m.AdvancedHeader  ).to.equal "function"
    (expect typeof @m.BasicMessage    ).to.equal "function"
    (expect typeof @m.AdvancedMessage ).to.equal "function"
    (expect typeof @m.LoginResponse   ).to.equal "function"
    (expect typeof @m.LoginRequest    ).to.equal "function"

  describe "BasicHeader", ->

    it "has three properties", ->
      (expect (new @m.BasicHeader({length:4})).length).to.equal 4
      (expect (new @m.BasicHeader({nr:3})).nr).to.equal 3
      (expect (new @m.BasicHeader({protocolId:5})).protocolId).to.equal 5

  describe "AdvancedHeader", ->
    it "has four properties", ->
      (expect (new @m.AdvancedHeader({logicalNr:1})).logicalNr).to.equal 1
      (expect (new @m.AdvancedHeader({command:2})).command).to.equal 2
      (expect (new @m.AdvancedHeader({type:3})).type).to.equal 3
      (expect (new @m.AdvancedHeader({count:4})).count).to.equal 4

  describe "BasicMessage", ->
    it "has two properties", ->
      (expect (new @m.BasicMessage("foo")).header).to.equal "foo"
      (expect (new @m.BasicMessage "x", "y").data ).to.equal "y"
      (expect (new @m.BasicMessage("bar", "baz")).data).to.equal "baz"

  describe "AdvancedMessage", ->
    it "has three properties", ->
      m = new @m.AdvancedMessage "foo", "bar", "baz"
      (expect m.header).to.equal "foo"
      (expect m.data?).to.equal true
      (expect m.advancedHeader).to.equal "bar"

  describe "LoginRequest", ->
    it "has four properties", ->
      m = new @m.LoginRequest "foo",
        functionId: 1
        locationId: 2
        specificationNr: 3
      (expect m.header).to.equal "foo"
      (expect m.functionId).to.equal 1
      (expect m.locationId).to.equal 2
      (expect m.specificationNr).to.equal 3

  describe "LoginResponse", ->
    it "has three properties", ->
      m = new @m.LoginResponse "foo", specificationNr: 3
      (expect m.header).to.equal "foo"
      (expect m.specificationNr).to.equal 3
      (expect m.errors instanceof Array).to.equal true
