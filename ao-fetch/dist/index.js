var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
// import { connect, createDataItemSigner } from "@permaweb/aoconnect";
import { z } from "zod";
/**
 * Schema for aofetch options
 */
const AoFetchOptionsSchema = z.object({
    method: z.enum(["GET", "POST"]).optional().default("GET"),
    body: z.record(z.string(), z.union([z.string(), z.number(), z.boolean()])).optional().default({}),
    wallet: z.union([z.literal("web_wallet"), z.custom()]).optional().default("web_wallet"),
    CU_URL: z.string().optional().default("https://cu.ardrive.io"),
    AO: z.any().optional(),
    signer: z.any().optional()
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
/**
 * Convert an array of tags to a record
 * @param tags Array of tags
 * @returns Record of tag names to values
 */
const tagsToRecord = (tags) => {
    return tags.reduce((acc, t) => {
        acc[t.name] = t.value;
        return acc;
    }, {});
};
/**
 * Parse response data as JSON if possible
 * @param data String data to parse
 * @returns Parsed JSON or empty object
 */
const safeJsonParse = (data) => {
    try {
        return JSON.parse(data);
    }
    catch (_a) {
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
const createRequestTags = (endpoint, method, body) => {
    const tags = [
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
const processMessageResponse = (message) => {
    const tags = tagsToRecord(message.Tags);
    const response = {};
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
const findResponseMessage = (messages) => {
    const msg = messages.find((m) => m.Tags.some((t) => t.name === "Action" && t.value === "Aoxpress-Response"));
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
const aofetch = (location, options) => __awaiter(void 0, void 0, void 0, function* () {
    // Validate and parse options
    const validatedOptions = AoFetchOptionsSchema.parse(options || {});
    // Parse location
    const locationParts = location.split("/");
    const pid = locationParts[0];
    const endpoint = "/" + locationParts.slice(1).join("/");
    const CU_URL = validatedOptions.CU_URL;
    const ao = validatedOptions.AO ? validatedOptions.AO : (yield import("@permaweb/aoconnect")).connect({ MODE: "legacy", CU_URL });
    const signer = validatedOptions.signer;
    // Validate process ID
    if (pid.length !== 43) {
        throw new Error("Invalid process ID length. Must be 43 characters.");
    }
    try {
        const requestTags = createRequestTags(endpoint, validatedOptions.method, validatedOptions.body);
        switch (validatedOptions.method) {
            case "GET": {
                const res = yield ao.dryrun({
                    process: pid,
                    tags: requestTags
                });
                const message = findResponseMessage(res.Messages);
                return processMessageResponse(message);
            }
            case "POST": {
                const mid = yield ao.message({
                    process: pid,
                    tags: requestTags,
                    signer: signer !== null && signer !== void 0 ? signer : (validatedOptions.wallet === "web_wallet"
                        ? (yield import("@permaweb/aoconnect")).createDataItemSigner(window.arweaveWallet)
                        : (yield import("@permaweb/aoconnect")).createDataItemSigner(validatedOptions.wallet))
                });
                if (!mid) {
                    throw new Error("Failed to send message");
                }
                const res = yield ao.result({
                    process: pid,
                    message: mid
                });
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
    }
    catch (error) {
        if (error instanceof Error) {
            throw new Error(`aofetch failed: ${error.message}`);
        }
        throw new Error("aofetch failed with unknown error");
    }
});
export { aofetch };
//# sourceMappingURL=index.js.map