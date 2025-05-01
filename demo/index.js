import { aofetch } from "aofetch"
import fs from "fs"

const wallet = JSON.parse(fs.readFileSync("wallet.json", "utf8"))

const name = await aofetch("3GxCscS3FWn6MQ4RfCxHdIOknPXwX3_99XNUmDvtGYw/name")
console.log(name)

const updatename = await aofetch("3GxCscS3FWn6MQ4RfCxHdIOknPXwX3_99XNUmDvtGYw/name", {
    method: "POST",
    body: { name: "yayaayayayyaya" },
    wallet: wallet
})
console.log(updatename)

const name1 = await aofetch("3GxCscS3FWn6MQ4RfCxHdIOknPXwX3_99XNUmDvtGYw/name")
console.log(name1)
