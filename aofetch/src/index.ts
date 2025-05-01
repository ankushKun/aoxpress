import { connect } from "@permaweb/aoconnect";

type Tag = {
    name: string;
    value: string;
}

type AoFetchOptions = {
    method?: "GET" | "POST";
    body?: Record<string, string | number | boolean>;
}

type AoFetchResponse = {
    status: number;
    data: any;
}

// location has 2 parts:
// 1. process id (string of length 43)
// 2. endpoint route (default is "/")
// example: "3GxCscS3FWn6MQ4RfCxHdIOknPXwX3_99XNUmDvtGYw/name/1"
const aofetch = async (location: string, options?: AoFetchOptions): Promise<AoFetchResponse> => {

    if (!options) options = { method: "GET" };

    const ao = connect({ MODE: "legacy" });

    const pid = location.split("/")[0];
    const endpoint = "/" + location.split("/").slice(1).join("/");


    console.log("pid", `'${pid}'`);
    console.log("endpoint", `'${endpoint}'`);

    try {
        switch (options.method) {
            case "GET":
                const res = await ao.dryrun({
                    process: pid,
                    tags: [
                        { name: "Action", value: "Call-Route" },
                        { name: "Route", value: endpoint },
                        { name: "Method", value: "GET" }
                    ]
                })

                const message = res.Messages.find((m) => {
                    return m.Tags.find((t: Tag) => {
                        return t.name == "Action" && t.value == "Aoxpress-Response"
                    })
                })

                if (!message) {
                    throw new Error("No messages returned")
                }

                try {
                    const response: AoFetchResponse = {
                        status: message.Tags.find((t: Tag) => t.name == "Status")?.value || -1,
                        data: JSON.parse(message.Data)
                    }
                    return response
                } catch (err) {
                    const response: AoFetchResponse = {
                        status: message.Tags.find((t: Tag) => t.name == "Status")?.value || -1,
                        data: message.Data
                    }
                    return response
                }
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