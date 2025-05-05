-- just visit https://arweave.net/process-id/path
-- URL works only if you have created the project/process through ide.betteridea.dev

app = require("aoxpress")

name = "Ankush"

app.get("/", function(req, res)
    res:send("OK")
end)

app.get("/name", function(req, res)
    res:json({ name = name })
end)

app.post("/name", function(req, res)
    name = req.body.name
    print("updated name to " .. name)
    res:send("Name Updated")
end)

app.listen()
