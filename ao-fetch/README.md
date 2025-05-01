# ao-fetch

A client library for communicating with AO processes. ao-fetch provides a familiar HTTP-like interface for making requests to AO processes, similar to the `fetch` API.

Best used with [aoxpress](https://github.com/ankushKun/aoxpress/blob/main/aoxpress/README.md)


## Installation

```bash
# Using pnpm
pnpm add ao-fetch

# Using npm
npm install ao-fetch

# Using yarn
yarn add ao-fetch
```

## Quick Start

```typescript
import { aofetch } from 'ao-fetch';

// Make a GET request
const response = await aofetch('processId/endpoint');
console.log(response);
```

## API Reference

### aofetch(location: string, options?: AoFetchOptions): Promise<AoFetchResponse>

Makes a request to an AO process.

#### Parameters

- `location`: Process ID and endpoint route (e.g., "processId/endpoint")
- `options`: Optional request options

#### Options

```typescript
interface AoFetchOptions {
    method: 'GET' | 'POST';  // HTTP method, default GET
    body?: Record<string, string | number | boolean>;  // Request body
    params?: Record<string, string | number | boolean>;  // Query parameters
    headers?: Record<string, string>;  // Custom headers
    wallet?: 'web_wallet' | JWKInterface;  // Pass wallet JWK or just "web_wallet" to use window.arweaveWallet
}
```

#### Response

```typescript
interface AoFetchResponse {
    status: number;  // HTTP status code
    text?: string;    // Response text
    json?: Record<string, any>;  // Parsed JSON response
    error?: string;   // Error message
    id?: string;      // Message ID
}
```

## Examples

### Basic Usage

```typescript
const PID = "3GxCscS3FWn6MQ4RfCxHdIOknPXwX3_99XNUmDvtGYw";

// GET request
const response = await aofetch(`${PID}/name`);
console.log(response);

// POST request with body
const response = await aofetch(`${PID}/name`, {
    method: 'POST',
    body: {
        name: 'NEW NAME',
    }
});
console.log(response);
```

## License

MIT