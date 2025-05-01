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

_G.package.loaded["aoxpress"] = M
