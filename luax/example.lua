luax = require("luax")

local page = div({
    class = "text-xl text-center"
}, {
    h1({}, { text("Welcome to LuaX Example") }),
})

print(luax.render(page))

-- result:
-- <div class="text-xl text-center">
--     <h1>Welcome to LuaX Example</h1>
-- </div>
