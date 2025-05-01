import { z } from "zod";
import { JWKInterface } from "arweave/node/lib/wallet";
declare global {
    interface Window {
        arweaveWallet: JWKInterface;
    }
}
/**
 * Schema for aofetch options
 */
declare const AoFetchOptionsSchema: z.ZodObject<{
    method: z.ZodDefault<z.ZodOptional<z.ZodEnum<["GET", "POST"]>>>;
    body: z.ZodDefault<z.ZodOptional<z.ZodRecord<z.ZodString, z.ZodUnion<[z.ZodString, z.ZodNumber, z.ZodBoolean]>>>>;
    wallet: z.ZodDefault<z.ZodOptional<z.ZodUnion<[z.ZodLiteral<"web_wallet">, z.ZodType<JWKInterface, z.ZodTypeDef, JWKInterface>]>>>;
}, "strip", z.ZodTypeAny, {
    method?: "GET" | "POST";
    body?: Record<string, string | number | boolean>;
    wallet?: JWKInterface | "web_wallet";
}, {
    method?: "GET" | "POST";
    body?: Record<string, string | number | boolean>;
    wallet?: JWKInterface | "web_wallet";
}>;
/**
 * Schema for aofetch response
 */
declare const AoFetchResponseSchema: z.ZodObject<{
    status: z.ZodDefault<z.ZodOptional<z.ZodNumber>>;
    text: z.ZodDefault<z.ZodOptional<z.ZodString>>;
    json: z.ZodUnion<[z.ZodArray<z.ZodAny, "many">, z.ZodDefault<z.ZodOptional<z.ZodRecord<z.ZodString, z.ZodAny>>>]>;
    error: z.ZodDefault<z.ZodOptional<z.ZodString>>;
    id: z.ZodDefault<z.ZodOptional<z.ZodString>>;
}, "strip", z.ZodTypeAny, {
    status?: number;
    text?: string;
    json?: any[] | Record<string, any>;
    error?: string;
    id?: string;
}, {
    status?: number;
    text?: string;
    json?: any[] | Record<string, any>;
    error?: string;
    id?: string;
}>;
type AoFetchOptions = z.infer<typeof AoFetchOptionsSchema>;
type AoFetchResponse = z.infer<typeof AoFetchResponseSchema>;
/**
 * Fetch data from an AO process
 * @param location Process ID and endpoint route (e.g., "processId/endpoint/route")
 * @param options Fetch options
 * @returns Promise resolving to the response
 * @throws Error if process ID is invalid or request fails
 */
declare const aofetch: (location: string, options?: AoFetchOptions) => Promise<AoFetchResponse>;
export { aofetch, type AoFetchOptions, type AoFetchResponse };
