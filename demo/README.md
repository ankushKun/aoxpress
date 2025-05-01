# Demo Examples

This directory contains example applications demonstrating the usage of the AO Backend Framework.

## Running the Example

0. Get a wallet initialised for usage through node\
   `npx -y @permaweb/wallet > wallet.json`
1. Install [aoxpress](../aoxpress/) on AO process
2. Run [backend.lua](./backend.lua) on the AO process
3. Paste the process id in [index.js](./index.js)
4. Run `node index.js`

This will:

1. Fetch the variable name from /name endpoint with a GET request
2. Modify the variable name from /name endpoint with a POST request
3. Fetch the updated value of name 

We have used a wallet JWK in this example, for running this in the client side, change the `wallet` argument in aofetch options to `"web_wallet"` or just remove it entirely since web_wallet is used by default

## License

MIT
