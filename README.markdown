# lib7f

7F protocol library for Node.js

[![Build Status](https://secure.travis-ci.org/flosse/node-7f.png)](http://travis-ci.org/flosse/node-7f)
[![Dependency Status](https://gemnasium.com/flosse/node-7f.png)](https://gemnasium.com/flosse/node-7f)
[![NPM version](https://badge.fury.io/js/7f.png)](http://badge.fury.io/js/7f)

## Usage

```shell
npm install 7f
```

```coffeescript
lib7f  = require "7f"
server = new lib7f.Server
server.on "client", (client) ->
  client.on "message", (msg) ->
    console.log msg
    msg = new lib7f.Message
    client.send msg
server.connect()
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

## License

GPLv3
