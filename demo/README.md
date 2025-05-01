# Demo Examples

This directory contains example applications demonstrating the usage of the AO Backend Framework.

## Examples

### Basic Server

A simple server that demonstrates basic route handling and response types.

```lua
-- server.lua
local aoxpress = require("aoxpress")

-- GET route with JSON response
aoxpress.get("/hello", function(req, res)
    res:json({ message = "Hello, World!" })
end)

-- GET route with text response
aoxpress.get("/text", function(req, res)
    res:send("Plain text response")
end)

-- Error handling example
aoxpress.get("/error", function(req, res)
    error("This is a test error")
end)

-- Start the server
aoxpress.listen()
```

### Client Example

A TypeScript client that demonstrates how to use aofetch to communicate with the server.

```typescript
// client.ts
import { aofetch } from 'aofetch';

async function main() {
    try {
        // Get JSON response
        const jsonResponse = await aofetch('processId/hello');
        console.log('JSON Response:', jsonResponse.json);

        // Get text response
        const textResponse = await aofetch('processId/text');
        console.log('Text Response:', textResponse.text);

        // Handle error
        const errorResponse = await aofetch('processId/error');
        if (errorResponse.error) {
            console.error('Error:', errorResponse.error);
        }
    } catch (error) {
        console.error('Request failed:', error);
    }
}

main();
```

## Running the Examples

1. Deploy the server code to an AO process
2. Update the process ID in the client code
3. Run the client code

```bash
# Install dependencies
pnpm install

# Run the client
pnpm start
```

## Features Demonstrated

- Basic route handling
- JSON responses
- Text responses
- Error handling
- Client-server communication
- Type safety
- Logging

## Best Practices

1. Always handle errors appropriately
2. Use type-safe responses
3. Implement proper logging
4. Validate input data
5. Use appropriate HTTP status codes

## License

MIT 