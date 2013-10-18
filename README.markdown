# lib7f

7F protocol library for Node.js

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
```

You can also specify port and the address to which the server should be
bound to:

    server = new lib7f.Server "192.168.10.30", 5010

If you'd like to specify the servers specification number and it's login
function ID just append it:

    server = new lib7f.Server "192.168.10.30", 5010, 8, 5

## License

GPLv3
