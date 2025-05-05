import { aofetch, type AoFetchOptions, type AoFetchResponse } from './index';

// Export everything as a global variable
declare global {
    interface Window {
        aofetch: typeof aofetch;
    }
}

// Assign to window
window.aofetch = aofetch;

// Also export as default for module usage
export { aofetch, type AoFetchOptions, type AoFetchResponse }; 