import { aofetch } from "aofetch"

const routes = [
    "3GxCscS3FWn6MQ4RfCxHdIOknPXwX3_99XNUmDvtGYw",
    "3GxCscS3FWn6MQ4RfCxHdIOknPXwX3_99XNUmDvtGYw/",
    "3GxCscS3FWn6MQ4RfCxHdIOknPXwX3_99XNUmDvtGYw/name",
    "3GxCscS3FWn6MQ4RfCxHdIOknPXwX3_99XNUmDvtGYw/name/1",
]


for (const route of routes) {
    console.log(await aofetch(route))
    console.log("--------------------------------")
}
