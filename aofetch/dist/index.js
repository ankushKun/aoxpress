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
// location has 2 parts:
// 1. process id (string of length 43)
// 2. endpoint route (default is "/")
// example: "3GxCscS3FWn6MQ4RfCxHdIOknPXwX3_99XNUmDvtGYw/name/1"
const aofetch = (location, options) => __awaiter(void 0, void 0, void 0, function* () {
    var _a, _b;
    if (!options)
        options = { method: "GET" };
    const ao = connect({ MODE: "legacy" });
    const pid = location.split("/")[0];
    const endpoint = "/" + location.split("/").slice(1).join("/");
    console.log("pid", `'${pid}'`);
    console.log("endpoint", `'${endpoint}'`);
    try {
        switch (options.method) {
            case "GET":
                const res = yield ao.dryrun({
                    process: pid,
                    tags: [
                        { name: "Action", value: "Call-Route" },
                        { name: "Route", value: endpoint },
                        { name: "Method", value: "GET" }
                    ]
                });
                const message = res.Messages.find((m) => {
                    return m.Tags.find((t) => {
                        return t.name == "Action" && t.value == "Aoxpress-Response";
                    });
                });
                if (!message) {
                    throw new Error("No messages returned");
                }
                try {
                    const response = {
                        status: ((_a = message.Tags.find((t) => t.name == "Status")) === null || _a === void 0 ? void 0 : _a.value) || -1,
                        data: JSON.parse(message.Data)
                    };
                    return response;
                }
                catch (err) {
                    const response = {
                        status: ((_b = message.Tags.find((t) => t.name == "Status")) === null || _b === void 0 ? void 0 : _b.value) || -1,
                        data: message.Data
                    };
                    return response;
                }
            case "POST":
                throw new Error("POST not implemented");
            default:
                throw new Error("Invalid method");
        }
    }
    catch (err) {
        throw err;
    }
});
export { aofetch };
//# sourceMappingURL=index.js.map