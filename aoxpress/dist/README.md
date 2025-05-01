# Aoxpress

A Lua-based web framework for AO processes, inspired by Express.js. Aoxpress provides a simple and intuitive way to handle HTTP-like requests in AO processes.

## Features

- Request/Response handling
- Route-based request handling
- JSON response support
- Built-in error handling
- Comprehensive logging system
- Type-safe request/response objects

## Installation

```bash
# In your AO process
local aoxpress = require("aoxpress")
```

## Quick Start

```lua
local aoxpress = require("aoxpress")

-- Create a new route
aoxpress.get("/hello", function(req, res)
    res:json({ message = "Hello, World!" })
end)

-- Start listening for requests
aoxpress.listen()
```

## API Reference

### Request Object

```lua
local req = {
    body = {},      -- Request body
    headers = {},   -- Request headers
    query = {},     -- Query parameters
    params = {},    -- Route parameters
    method = "",    -- HTTP method
    route = "",     -- Request route
    hostname = "",  -- Request hostname
    msg = {}        -- Original message
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
-- GET route
aoxpress.get("/path", function(req, res)
    -- Handle request
end)

-- POST route
aoxpress.post("/path", function(req, res)
    -- Handle request
end)
```

### Logging

```lua
local logger = aoxpress.logger

-- Set log level
logger.setLevel("debug")

-- Log messages
logger.error(route, method, message, status)
logger.warn(route, method, message, status)
logger.info(route, method, message, status)
logger.debug(route, method, message, status)
```

## Error Handling

Aoxpress provides built-in error handling through the `ErrorBoundary` wrapper. All route handlers are automatically wrapped in an error boundary that:

1. Catches any errors that occur during request handling
2. Logs the error with appropriate context
3. Sends a 500 Internal Server Error response

## Logging

The logging system provides:

- Multiple log levels (error, warn, info, debug)
- Colored console output
- JSON-formatted log entries
- Log persistence
- Remote logging capabilities

## Examples

See the [demo](./../demo) directory for complete examples.

## License

MIT
