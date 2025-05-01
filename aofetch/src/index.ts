import { connect } from "@permaweb/aoconnect";
import { z } from "zod";

const TagSchema = z.object({
    name: z.string(),
    value: z.string()
});

const AoFetchOptionsSchema = z.object({
    method: z.enum(["GET", "POST"]).optional().default("GET"),
    body: z.record(z.string(), z.union([z.string(), z.number(), z.boolean()])).optional().default({}),
    params: z.record(z.string(), z.union([z.string(), z.number(), z.boolean()])).optional().default({})
});

const AoFetchResponseSchema = z.object({
    status: z.number().optional().default(-1),
    text: z.string().optional().default(""),
    json: z.record(z.string(), z.any()).optional().default({}),
    error: z.string().optional().default(""),
});

type Tag = z.infer<typeof TagSchema>;
type AoFetchOptions = z.infer<typeof AoFetchOptionsSchema>;
type AoFetchResponse = z.infer<typeof AoFetchResponseSchema>;

const ao = connect({ MODE: "legacy" });

// location has 2 parts:
// 1. process id (string of length 43)
// 2. endpoint route (default is "/")
// example: "3GxCscS3FWn6MQ4RfCxHdIOknPXwX3_99XNUmDvtGYw/name/1"
const aofetch = async (location: string, options?: AoFetchOptions): Promise<AoFetchResponse> => {
    if (!options) options = {};
    // Validate location format
    const locationParts = location.split("/");
    const pid = locationParts[0];
    const endpoint = "/" + locationParts.slice(1).join("/");

    if (locationParts[0].length !== 43)
        throw new Error("Invalid process ID length. Must be 43 characters.");

    // Validate and parse options
    const validatedOptions = AoFetchOptionsSchema.parse(options);

    try {
        switch (validatedOptions.method) {
            case "GET":
                const res = await ao.dryrun({
                    process: pid,
                    tags: [
                        { name: "Action", value: "Call-Route" },
                        { name: "Route", value: endpoint },
                        { name: "Method", value: "GET" }
                    ]
                });

                const message = res.Messages.find((m) => {
                    return m.Tags.find((t: Tag) => {
                        return t.name == "Action" && t.value == "Aoxpress-Response"
                    })
                });

                if (!message) {
                    throw new Error("No response message received")
                }

                // [{n,v},{n,v},{n,v}] to {n:v,n:v,n:v}
                const tags = (message.Tags as Tag[]).reduce((acc, t) => {
                    acc[t.name] = t.value;
                    return acc;
                }, {} as Record<string, string>);



                const response: AoFetchResponse = {};
                if (tags.Status) {
                    response.status = parseInt(tags.Status);
                }
                if (message.Data) {
                    response.text = message.Data;
                    try { response.json = JSON.parse(message.Data) } catch (err) { }
                }
                if (tags.Status != "200") {
                    response.error = tags.Error || message.Data;
                }

                return AoFetchResponseSchema.parse(response);
            case "POST":
                throw new Error("POST not implemented")
            default:
                throw new Error("Invalid method")
        }
    } catch (err) {
        throw err
    }
};

export { aofetch };