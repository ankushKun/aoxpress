# aoxpress

A Lua-based web framework for AO processes, inspired by Express.js. Aoxpress provides a simple and intuitive way to handle HTTP-like requests in AO processes.

Best used with [ao-fetch](https://github.com/ankushKun/aoxpress/blob/main/ao-fetch/README.md)

## Installation

Use [APM](https://apm.betteridea.dev) to install aoxpress in your process

```lua
.load-blueprint apm
apm.install("aoxpress")
```

## Quick Start

```lua
app = require("aoxpress")

-- Create a new route
app.get("/hello", function(req, res)
    res:json({ message = "Hello, World!" }) -- default status is 200
    -- or
    res:status(401):send("User Unauthorised")
    -- or
    res:send("Helloooo")
end)

-- Start listening for requests
app.listen()
```

## Using with LuaX for HTML Responses

Aoxpress works great with [LuaX](../luax/README.md) for generating HTML responses programmatically:

```lua
local app = require("aoxpress")
local luax = require("luax")

app.get("/html", function(req, res)
    local page = div { class = "centered" } {
        h1 {} { "Welcome to LuaX + aoxpress!" },
        p {} { "This page was rendered using LuaX syntax." }
    }
    res:send(luax.render(page))
end)

app.listen()
```

## API Reference

### Request Object

```lua
local req = {
    body = {},      -- Request body
    query = {},     -- Query parameters
    method = "",    -- HTTP method
    route = "",     -- Request route
    hostname = "",  -- Request hostname
    msg = {...}        -- Original message
}
```

### Response Object

```lua
local res = {
    :status(code)   -- Set HTTP status code
    :send(data)     -- Send string response
    :json(data)     -- Send JSON response
}
```

### Route Handlers

```lua
-- GET route (for dryruns)
app.get("/path", function(req, res)
    -- Handle request
end)

-- POST route (for actual messages and modifying state)
app.post("/path", function(req, res)
    -- Handle request
end)
```

## Examples

See the [demo](https://github.com/ankushKun/aoxpress/tree/main/demo) directory for basic usage.

## License

MIT