import { connect, createDataItemSigner } from "@permaweb/aoconnect";
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
const AoFetchOptionsSchema = z.object({
    method: z.enum(["GET", "POST"]).optional().default("GET"),
    body: z.record(z.string(), z.union([z.string(), z.number(), z.boolean()])).optional().default({}),
    wallet: z.union([z.literal("web_wallet"), z.custom<JWKInterface>()]).optional().default("web_wallet"),
    CU_URL: z.string().optional().default("https://cu.ardrive.io")
});

/**
 * Schema for aofetch response
 */
const AoFetchResponseSchema = z.object({
    status: z.number().optional().default(-1),
    text: z.string().optional().default(""),
    json: z.union([z.array(z.any()), z.record(z.string(), z.any()).optional().default({})]),
    error: z.string().optional().default(""),
    id: z.string().optional().default("")
});

type Tag = { name: string; value: string; };
type AoFetchOptions = z.infer<typeof AoFetchOptionsSchema>;
type AoFetchResponse = z.infer<typeof AoFetchResponseSchema>;

interface AoMessage {
    Tags: Tag[];
    Data?: string;
    id?: string;
}

interface AoResult {
    Messages: AoMessage[];
}

interface AoDryrunResult {
    Messages: AoMessage[];
}

let ao = connect({ MODE: "legacy" });

/**
 * Convert an array of tags to a record
 * @param tags Array of tags
 * @returns Record of tag names to values
 */
const tagsToRecord = (tags: Tag[]): Record<string, string> => {
    return tags.reduce((acc, t) => {
        acc[t.name] = t.value;
        return acc;
    }, {} as Record<string, string>);
};

/**
 * Parse response data as JSON if possible
 * @param data String data to parse
 * @returns Parsed JSON or empty object
 */
const safeJsonParse = (data: string): Record<string, any> => {
    try {
        return JSON.parse(data);
    } catch {
        return {};
    }
};

/**
 * Create request tags for AO process
 * @param endpoint The endpoint route
 * @param method The HTTP method
 * @param body Optional request body
 * @returns Array of tags
 */
const createRequestTags = (
    endpoint: string,
    method: string,
    body?: Record<string, string | number | boolean>
): Tag[] => {
    const tags: Tag[] = [
        { name: "Action", value: "Call-Route" },
        { name: "Route", value: endpoint },
        { name: "Method", value: method }
    ];

    if (body) {
        Object.entries(body).forEach(([key, value]) => {
            tags.push({ name: `X-Body-${key}`, value: value.toString() });
        });
    }

    return tags;
};

/**
 * Process AO message response
 * @param message The AO message
 * @returns Processed response
 */
const processMessageResponse = (message: AoMessage): AoFetchResponse => {
    const tags = tagsToRecord(message.Tags);
    const response: AoFetchResponse = {};

    if (message.id) {
        response.id = message.id;
    }

    if (tags.Status) {
        response.status = parseInt(tags.Status);
    }

    if (message.Data) {
        response.text = message.Data;
        response.json = safeJsonParse(message.Data);
    }

    if (tags.Status !== "200") {
        response.error = tags.Error || message.Data;
    }

    return AoFetchResponseSchema.parse(response);
};

/**
 * Find response message from AO messages
 * @param messages Array of AO messages
 * @returns Found message or undefined
 */
const findResponseMessage = (messages: AoMessage[]): AoMessage | undefined => {
    const msg = messages.find((m) =>
        m.Tags.some((t) =>
            t.name === "Action" && t.value === "Aoxpress-Response"
        )
    );

    if (!msg) {
        throw new Error("No response message received");
    }

    return msg;
};

/**
 * Fetch data from an AO process
 * @param location Process ID and endpoint route (e.g., "processId/endpoint/route")
 * @param options Fetch options
 * @returns Promise resolving to the response
 * @throws Error if process ID is invalid or request fails
 */
const aofetch = async (location: string, options?: AoFetchOptions): Promise<AoFetchResponse> => {
    // Validate and parse options
    const validatedOptions = AoFetchOptionsSchema.parse(options || {});

    // Parse location
    const locationParts = location.split("/");
    const pid = locationParts[0];
    const endpoint = "/" + locationParts.slice(1).join("/");
    const CU_URL = validatedOptions.CU_URL;
    ao = connect({ MODE: "legacy", CU_URL });

    // Validate process ID
    if (pid.length !== 43) {
        throw new Error("Invalid process ID length. Must be 43 characters.");
    }

    try {
        const requestTags = createRequestTags(endpoint, validatedOptions.method, validatedOptions.body);

        switch (validatedOptions.method) {
            case "GET": {
                const res = await ao.dryrun({
                    process: pid,
                    tags: requestTags
                }) as AoDryrunResult;

                const message = findResponseMessage(res.Messages);

                return processMessageResponse(message);
            }
            case "POST": {
                const mid = await ao.message({
                    process: pid,
                    tags: requestTags,
                    signer: validatedOptions.wallet === "web_wallet"
                        ? createDataItemSigner(window.arweaveWallet)
                        : createDataItemSigner(validatedOptions.wallet)
                });

                if (!mid) {
                    throw new Error("Failed to send message");
                }

                const res = await ao.result({
                    process: pid,
                    message: mid
                }) as AoResult;

                if (!res) {
                    throw new Error("Failed to get result");
                }

                const message = findResponseMessage(res.Messages);
                message.id = mid;

                return processMessageResponse(message);
            }
            default: {
                throw new Error(`Invalid method: ${validatedOptions.method}`);
            }
        }
    } catch (error) {
        if (error instanceof Error) {
            throw new Error(`aofetch failed: ${error.message}`);
        }
        throw new Error("aofetch failed with unknown error");
    }
};

export { aofetch, type AoFetchOptions, type AoFetchResponse };