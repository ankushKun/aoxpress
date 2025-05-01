var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
import { connect } from "@permaweb/aoconnect";
import { z } from "zod";
/**
 * Schema for AO process tags
 */
const TagSchema = z.object({
    name: z.string(),
    value: z.string()
});
/**
 * Schema for aofetch options
 */
const AoFetchOptionsSchema = z.object({
    method: z.enum(["GET", "POST"]).optional().default("GET"),
    body: z.record(z.string(), z.union([z.string(), z.number(), z.boolean()])).optional().default({}),
    params: z.record(z.string(), z.union([z.string(), z.number(), z.boolean()])).optional().default({})
});
/**
 * Schema for aofetch response
 */
const AoFetchResponseSchema = z.object({
    status: z.number().optional().default(-1),
    text: z.string().optional().default(""),
    json: z.record(z.string(), z.any()).optional().default({}),
    error: z.string().optional().default(""),
});
const ao = connect({ MODE: "legacy" });
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
    // Validate process ID
    if (pid.length !== 43) {
        throw new Error("Invalid process ID length. Must be 43 characters.");
    }
    try {
        switch (validatedOptions.method) {
            case "GET": {
                const res = yield ao.dryrun({
                    process: pid,
                    tags: [
                        { name: "Action", value: "Call-Route" },
                        { name: "Route", value: endpoint },
                        { name: "Method", value: "GET" }
                    ]
                });
                const message = res.Messages.find((m) => m.Tags.some((t) => t.name === "Action" && t.value === "Aoxpress-Response"));
                if (!message) {
                    throw new Error("No response message received");
                }
                const tags = tagsToRecord(message.Tags);
                const response = {};
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
            }
            case "POST": {
                throw new Error("POST method not implemented yet");
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