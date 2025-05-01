

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

end

_G.package.loaded["logger"] = _loaded_mod_logger()

local json = require("json")

local M = {}

-- Initialize endpoints table
M.endpoints = {}

-- Import logger
local logger = require("logger")

-- Request object
local Request = {}
Request.__index = Request

function Request:new(msg)
  local self = setmetatable({}, Request)
  self.body = {}
  self.headers = {}
  self.query = {}
  self.params = {}
  self.method = msg.Method
  self.route = msg.Route
  self.hostname = msg.Hostname
  self.msg = msg
  return self
end

-- Response object
local Response = {}
Response.__index = Response

function Response:new(msg)
  local self = setmetatable({}, Response)
  self._status = -1 -- default status code
  self.data = ""
  self.target = msg.From
  self.route = msg.Route
  self.completed = false
  return self
end

function Response:status(code)
  self._status = code
  return self -- return self for chaining
end

function Response:send(data)
  assert(not self.completed, "Already sent response")
  assert(type(data) == "string", "Response data must be a string")
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

function Response:json(data)
  assert(type(data) == "table", "Response data must be a table")
  self.data = tostring(json.encode(data))
  return self.send(self.data)
end

-- Router methods
function M.get(route, handler)
  assert(type(route) == "string", "Endpoint route must be a string")
  assert(type(handler) == "function", "Endpoint handler must be a function")
  M.endpoints["GET " .. route] = handler
end

local function ErrorBoundary(handler)
  return function(req, res)
    local success, err = pcall(handler, req, res)
    if not success then
      logger.error(req.route, req.method, err, 500)
      res:status(500):send("Internal Server Error: " .. err)
    else
      logger.info(req.route, req.method, "OK", res._status)
    end
  end
end

function M.listen()
  -- Set up handlers for each endpoint
  Handlers.add("Aoxpress-Listener", { Action = "Call-Route" }, function(msg)
    local route = msg.Route
    assert(type(route) == "string", "Endpoint route must be a string")
    local method = msg.Method
    -- method should be either GET / POST
    assert(method == "GET" or method == "POST", "Invalid method")

    local req = Request:new(msg)
    local res = Response:new(msg)
    assert(M.endpoints[method .. " " .. route], "Endpoint not found")
    local handler = M.endpoints[method .. " " .. route]
    ErrorBoundary(handler)(req, res)
  end)

  -- Set up log handler
  Handlers.add("Aoxpress-Log", { Action = "Aoxpress-Log" }, function(msg)
    local logEntry = json.decode(msg.Data or "{}")
    table.insert(logger.logs, logEntry)
  end)

  logger.info(nil, nil, "Started listening")
end

function M.unlisten()
  Handlers.remove("Aoxpress-Listener")
end

-- Expose logger instance
M.logger = logger

_G.package.loaded["aoxpress"] = M
