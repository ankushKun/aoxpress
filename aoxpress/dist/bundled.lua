

-- module: "logger"
local function _loaded_mod_logger()
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
    local ts = os.time()
    local date = os.date("*t", ts)
    return string.format("%04d-%02d-%02d %02d:%02d:%02d", date.year, date.month, date.day, date.hour, date.min, date.sec)
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

end

_G.package.loaded["logger"] = _loaded_mod_logger()

local json = require("json")

local M = {}

-- Initialize endpoints table
M.endpoints = {}

-- Import logger
local logger = require("logger")

-- Type definitions
local Request = {}
Request.__index = Request

--- Create a new Request object
-- @param msg table The message object containing request details
-- @return table A new Request instance
function Request:new(msg)
  assert(type(msg) == "table", "msg must be a table")
  local self = setmetatable({}, Request)
  self.body = {}
  self.query = {}
  self.method = msg.Method
  self.route = msg.Route
  self.hostname = msg.Hostname
  self.msg = msg

  -- Parse body parameters from TagArray
  if type(msg.TagArray) == "table" then
    for _, tag in ipairs(msg.TagArray) do
      local tagName = tag.name
      local tagValue = tag.value

      if tagName and tagValue and type(tagName) == "string" and tagName:sub(1, 7) == "X-Body-" then
        local key = tagName:sub(8) -- Remove "X-Body-" prefix
        -- Try to convert string values to their proper types
        local value = tagValue
        -- Try to convert to number if possible
        local num = tonumber(value)
        if num then
          value = num
          -- Try to convert to boolean if possible
        elseif value == "true" then
          value = true
        elseif value == "false" then
          value = false
          -- Try to parse JSON if it looks like a JSON string
        elseif type(value) == "string" and (value:sub(1, 1) == "{" or value:sub(1, 1) == "[") then
          local success, parsed = pcall(json.decode, value)
          if success then
            value = parsed
          end
        end
        self.body[key] = value
      end
    end
  end

  return self
end

-- Response object
local Response = {}
Response.__index = Response

--- Create a new Response object
-- @param msg table The message object containing response details
-- @return table A new Response instance
function Response:new(msg)
  assert(type(msg) == "table", "msg must be a table")
  local self = setmetatable({}, Response)
  self._status = -1 -- default status code
  self.data = ""
  self.target = msg.From
  self.route = msg.Route
  self.completed = false
  return self
end

--- Set the HTTP status code
-- @param code number The HTTP status code
-- @return table The Response instance for chaining
function Response:status(code)
  assert(type(code) == "number", "status code must be a number")
  assert(code >= 100 and code <= 599, "invalid status code")
  self._status = code
  return self
end

--- Send a response
-- @param data string The response data
-- @return table The Response instance for chaining
function Response:send(data)
  assert(not self.completed, "response already sent")
  assert(type(data) == "string", "response data must be a string")
  self.data = data
  if self._status == -1 then
    self._status = 200
  end
  ao.send({
    Target = self.target,
    Action = "Aoxpress-Response",
    Data = tostring(self.data),
    Status = tostring(self._status),
    Route = self.route
  })
  self.completed = true
  return self
end

--- Send a JSON response
-- @param data table The response data to be JSON encoded
-- @return table The Response instance for chaining
function Response:json(data)
  assert(type(data) == "table", "response data must be a table")
  local success, str_data = pcall(json.encode, data)
  if not success then
    error("Failed to encode JSON: " .. tostring(str_data))
  end
  return self:send(str_data)
end

--- Register a GET route handler
-- @param route string The route path
-- @param handler function The route handler function
function M.get(route, handler)
  assert(type(route) == "string", "route must be a string")
  assert(type(handler) == "function", "handler must be a function")
  M.endpoints["GET " .. route] = handler
end

--- Register a POST route handler
-- @param route string The route path
-- @param handler function The route handler function
function M.post(route, handler)
  assert(type(route) == "string", "route must be a string")
  assert(type(handler) == "function", "handler must be a function")
  M.endpoints["POST " .. route] = handler
end

--- Error boundary wrapper for route handlers
-- @param handler function The route handler to wrap
-- @return function The wrapped handler
local function ErrorBoundary(handler)
  return function(req, res)
    local success, err = pcall(handler, req, res)
    if not success then
      logger.error(req.route, req.method, err, 500)
      res:status(500):send("Internal Server Error: " .. tostring(err))
    else
      logger.info(req.route, req.method, "OK", res._status)
    end
  end
end

--- Start listening for requests
function M.listen()
  -- Set up handlers for each endpoint
  Handlers.add("Aoxpress-Listener", { Action = "Call-Route" }, function(msg)
    local route = msg.Route
    assert(type(route) == "string", "route must be a string")
    local method = msg.Method
    assert(method == "GET" or method == "POST", "invalid method")

    local req = Request:new(msg)
    local res = Response:new(msg)

    local handler = M.endpoints[method .. " " .. route]
    if not handler then
      res:status(404):send("Not Found")
      return
    end

    ErrorBoundary(handler)(req, res)
  end)

  -- Set up log handler
  Handlers.add("Aoxpress-Log", { Action = "Aoxpress-Log" }, function(msg)
    assert(msg.From == ao.id, "invalid logging source")
    local success, logEntry = pcall(json.decode, msg.Data or "{}")
    if success then
      table.insert(logger.logs, logEntry)
    else
      logger.error(nil, nil, "Failed to parse log entry: " .. tostring(logEntry))
    end
  end)

  logger.info(nil, nil, "Started listening")
end

--- Stop listening for requests
function M.unlisten()
  Handlers.remove("Aoxpress-Listener")
  Handlers.remove("Aoxpress-Log")
end

-- Expose logger instance
M.logger = logger

-- _G.package.loaded["aoxpress"] = M

return M
