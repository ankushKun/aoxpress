local json = require("json")

local M = {}

-- Logger configuration
M.levels = {
    error = 0,
    warn = 1,
    info = 2,
    debug = 3
}
M.currentLevel = "info"
M.format = "[%s] %s | %s %s | %s" -- [timestamp] level | method route | message
M.logs = {}

-- ANSI color codes for console output
local colors = {
    error = "\27[31m", -- red
    warn = "\27[33m",  -- yellow
    info = "\27[32m",  -- green
    debug = "\27[36m", -- cyan
    reset = "\27[0m"   -- reset
}

function M.setLevel(level)
    assert(M.levels[level], "Invalid log level")
    M.currentLevel = level
end

function M.formatTimestamp()
    return os.date("%Y-%m-%d %H:%M:%S")
end

function M.formatMessage(level, route, method, message, status)
    return string.format(
        M.format,
        M.formatTimestamp(),
        string.upper(level),
        method or "-",
        route or "-",
        message or "-",
        status or "-"
    )
end

function M.printToConsole(level, formattedMessage)
    local color = colors[level] or colors.reset
    print(color .. formattedMessage .. colors.reset)
end

function M.log(level, route, method, message, status)
    -- Check if level is enabled
    if M.levels[level] > M.levels[M.currentLevel] then
        return
    end

    local logEntry = {
        timestamp = M.formatTimestamp(),
        level = level,
        route = route,
        method = method,
        message = message,
        status = status
    }

    -- Format and print log
    local formattedMessage = M.formatMessage(level, route, method, message, status)
    M.printToConsole(level, formattedMessage)

    -- Store log
    table.insert(M.logs, logEntry)

    -- Send log to process
    ao.send({
        Target = ao.id,
        Action = "Aoxpress-Log",
        Data = json.encode(logEntry)
    })
end

-- Convenience methods
function M.error(route, method, message, status)
    M.log("error", route, method, message, status)
end

function M.warn(route, method, message, status)
    M.log("warn", route, method, message, status)
end

function M.info(route, method, message, status)
    M.log("info", route, method, message, status)
end

function M.debug(route, method, message, status)
    M.log("debug", route, method, message, status)
end

return M
