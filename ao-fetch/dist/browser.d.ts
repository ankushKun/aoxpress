import { aofetch, type AoFetchOptions, type AoFetchResponse } from './index';
declare global {
    interface Window {
        aofetch: typeof aofetch;
    }
}
export { aofetch, type AoFetchOptions, type AoFetchResponse };
