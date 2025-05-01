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

--- Set the current log level
-- @param level string The log level to set (error, warn, info, debug)
function M.setLevel(level)
    assert(type(level) == "string", "level must be a string")
    assert(M.levels[level], "invalid log level: " .. tostring(level))
    M.currentLevel = level
end

--- Format the current timestamp
-- @return string Formatted timestamp
function M.formatTimestamp()
    return os.date("%Y-%m-%d %H:%M:%S")
end

--- Format a log message
-- @param level string The log level
-- @param route string|nil The route path
-- @param method string|nil The HTTP method
-- @param message string|nil The log message
-- @param status number|nil The HTTP status code
-- @return string Formatted log message
function M.formatMessage(level, route, method, message, status)
    assert(type(level) == "string", "level must be a string")
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

--- Print a message to console with color
-- @param level string The log level
-- @param formattedMessage string The formatted message to print
function M.printToConsole(level, formattedMessage)
    assert(type(level) == "string", "level must be a string")
    assert(type(formattedMessage) == "string", "formattedMessage must be a string")
    local color = colors[level] or colors.reset
    print(color .. formattedMessage .. colors.reset)
end

--- Create a log entry
-- @param level string The log level
-- @param route string|nil The route path
-- @param method string|nil The HTTP method
-- @param message string|nil The log message
-- @param status number|nil The HTTP status code
-- @return table The log entry
function M.createLogEntry(level, route, method, message, status)
    return {
        timestamp = M.formatTimestamp(),
        level = level,
        route = route,
        method = method,
        message = message,
        status = status
    }
end

--- Log a message
-- @param level string The log level
-- @param route string|nil The route path
-- @param method string|nil The HTTP method
-- @param message string|nil The log message
-- @param status number|nil The HTTP status code
function M.log(level, route, method, message, status)
    -- Check if level is enabled
    if M.levels[level] > M.levels[M.currentLevel] then
        return
    end

    -- Create and store log entry
    local logEntry = M.createLogEntry(level, route, method, message, status)
    table.insert(M.logs, logEntry)

    -- Format and print log
    local formattedMessage = M.formatMessage(level, route, method, message, status)
    M.printToConsole(level, formattedMessage)

    -- Send log to process
    local success, encoded = pcall(json.encode, logEntry)
    if success then
        ao.send({
            Target = ao.id,
            Action = "Aoxpress-Log",
            Data = encoded
        })
    else
        -- If JSON encoding fails, send a basic log
        ao.send({
            Target = ao.id,
            Action = "Aoxpress-Log",
            Data = json.encode({
                timestamp = logEntry.timestamp,
                level = level,
                error = "Failed to encode log entry"
            })
        })
    end
end

--- Log an error message
-- @param route string|nil The route path
-- @param method string|nil The HTTP method
-- @param message string|nil The error message
-- @param status number|nil The HTTP status code
function M.error(route, method, message, status)
    M.log("error", route, method, message, status)
end

--- Log a warning message
-- @param route string|nil The route path
-- @param method string|nil The HTTP method
-- @param message string|nil The warning message
-- @param status number|nil The HTTP status code
function M.warn(route, method, message, status)
    M.log("warn", route, method, message, status)
end

--- Log an info message
-- @param route string|nil The route path
-- @param method string|nil The HTTP method
-- @param message string|nil The info message
-- @param status number|nil The HTTP status code
function M.info(route, method, message, status)
    M.log("info", route, method, message, status)
end

--- Log a debug message
-- @param route string|nil The route path
-- @param method string|nil The HTTP method
-- @param message string|nil The debug message
-- @param status number|nil The HTTP status code
function M.debug(route, method, message, status)
    M.log("debug", route, method, message, status)
end

return M
