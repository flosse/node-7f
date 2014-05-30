# lib7f

7F protocol library for Node.js

[![Build Status](https://secure.travis-ci.org/flosse/node-7f.png)](http://travis-ci.org/flosse/node-7f)
[![Dependency Status](https://gemnasium.com/flosse/node-7f.png)](https://gemnasium.com/flosse/node-7f)
[![NPM version](https://badge.fury.io/js/7f.png)](http://badge.fury.io/js/7f)

## Usage

```shell
npm install 7f
```

### Server

```coffeescript
lib7f  = require "7f"
server = new lib7f.Server
server.on "client", (client) ->
  client.on "message", (msg) ->
    console.log msg
    header = {nr: 1}
    advancedHeader =
      logicalNr:  1245
      command:    lib7f.constants.Command.TO
      type:       lib7f.constants.DataType.BYTEARRAY
      count:      3
    data = new Buffer 7
    msg = new lib7f.Message header, advancedHeader, data
    client.send msg

server.on "reconnect", (client) ->
  console.log "client #{client.id} has reconnected"

server.connect -> # the server is ready
```

You can also specify the port, the server address to which the server should be
bound to, the servers specification number and it's login function ID:

```coffeescript
server = new lib7f.Server
  host: "192.168.10.30"
  port: 5010
  specificationNr: 8
  loginFunctionId: 5
```

### Client
```coffeescript

lib7f  = require "7f"

client = new lib7f.Client 7,
  host: "192.168.0.100"
  port: 5010
  specificationNr: 3
  loginFunctionId: 9

client.on "message", (msg) ->
  console.log msg
  header = {nr: 4}
  advancedHeader =
    logicalNr:  54
    command:    lib7f.constants.Command.FETCH
    type:       lib7f.constants.DataType.WORD
    count:      9
  data = new Buffer 33
  msg = new lib7f.Message header, advancedHeader, data
  client.send msg

client.on "error", (err) ->
  console.log "something went wrong"

client.on "login", ->
  console.log "client is now logged in"

client.on "connect", ->
  console.log "client is connected"
  client.login()

client.on "disconnect", ->
  console.log "client is now disconnected"

client.connect()
```

## License

GPLv3
