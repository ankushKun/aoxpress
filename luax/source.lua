-- LuaX Module
local luax = {}
luax.elements = {}

-- Safe element creation with error handling
local function safeCreateElement(name, attrs, children)
  local success, result = pcall(function()
    return {
      type = "html",
      name = name,
      atts = attrs or {},
      children = children or {}
    }
  end)

  if not success then
    error("Failed to create element '" .. tostring(name) .. "': " .. tostring(result))
  end
  return result
end

-- Create HTML elements with a more elegant syntax
function luax.element(name, attrs, children)
  if type(name) ~= "string" then
    error("Element name must be a string, got " .. type(name))
  end
  return safeCreateElement(name, attrs, children)
end

-- Create text nodes with error handling
function luax.text(text)
  local success, result = pcall(function()
    return {
      type = "text",
      text = tostring(text or "")
    }
  end)

  if not success then
    error("Failed to create text node: " .. tostring(result))
  end
  return result
end

-- Create a component with error handling
function luax.component(render)
  if type(render) ~= "function" then
    error("Component render must be a function, got " .. type(render))
  end

  return function(props, children)
    local success, result = pcall(function()
      -- If first argument is not a table, it's children
      if type(props) ~= "table" or props.type then
        children = props
        props = {}
      end
      -- Call the render function with props and children
      return render(props, children)
    end)

    if not success then
      error("Component render failed: " .. tostring(result))
    end
    return result
  end
end

-- Helper function to create elements with the new syntax
function luax.create(name)
  if type(name) ~= "string" then
    error("Element name must be a string, got " .. type(name))
  end

  -- Return a function that handles both attributes and children
  return function(attrs)
    -- If attrs is a table of elements (children), treat it as children
    if type(attrs) == "table" then
      local isChildren = false
      for _, v in pairs(attrs) do
        if type(v) == "table" and v.type then
          isChildren = true
          break
        end
      end

      if isChildren then
        return safeCreateElement(name, {}, attrs)
      end
    end

    -- Return a function that takes children
    return function(children)
      if type(children) == "table" then
        -- If children is a table of elements, use it directly
        local isElementList = true
        for _, v in pairs(children) do
          if type(v) ~= "table" or not v.type then
            isElementList = false
            break
          end
        end

        if isElementList then
          return safeCreateElement(name, attrs, children)
        end

        -- If children is a table of strings, convert to text nodes
        local textChildren = {}
        for _, child in pairs(children) do
          if type(child) == "string" then
            table.insert(textChildren, luax.text(child))
          else
            table.insert(textChildren, child)
          end
        end
        return safeCreateElement(name, attrs, textChildren)
      end
      -- If children is a string, convert to text node
      return safeCreateElement(name, attrs, { luax.text(children) })
    end
  end
end

-- Function to render HTML elements to string with error handling
function luax.render(element)
  local success, result = pcall(function()
    if type(element) ~= "table" then
      return tostring(element or "")
    end

    if element.type == "text" then
      return tostring(element.text or "")
    end

    if not element.name then
      return ""
    end

    local attrs = ""
    if element.atts then
      for k, v in pairs(element.atts) do
        if v ~= nil then
          attrs = attrs .. string.format(' %s="%s"', k, tostring(v))
        end
      end
    end

    if not element.children or #element.children == 0 then
      return string.format("<%s%s/>", element.name, attrs)
    end

    local children = ""
    for _, child in ipairs(element.children) do
      if child then
        children = children .. luax.render(child)
      end
    end

    return string.format("<%s%s>%s</%s>", element.name, attrs, children, element.name)
  end)

  if not success then
    error("Failed to render element: " .. tostring(result))
  end
  return result
end

-- Initialize global element functions with a more elegant syntax
function luax.init()
  local elements = {
    "div", "span", "p", "h1", "h2", "h3", "h4", "h5", "h6",
    "a", "img", "input", "button", "form", "label",
    "option", "textarea", "ul", "ol", "li", "tr",
    "td", "th", "thead", "tbody", "header", "footer", "nav",
    "main", "section", "strong", "em",
    "br", "hr", "meta", "link", "script", "style",
    "iframe", "summary", "details", "article", "time", "aside", "dialog"
  }

  local reserved_names = { "table", "select" }

  -- Create elements with error handling
  for _, name in ipairs(elements) do
    local success, result = pcall(function()
      local element_func = luax.create(name)
      luax.elements[name] = element_func
      if not _G[name] then
        _G[name] = element_func
      else
        -- print(name .. " already exists in global scope")
      end
    end)

    if not success then
      error("Failed to create element '" .. name .. "': " .. tostring(result))
    end
  end

  -- Handle reserved names separately
  for _, name in ipairs(reserved_names) do
    local success, result = pcall(function()
      local element_func = luax.create(name)
      luax.elements["html_" .. name] = element_func
      if not _G["html_" .. name] then
        _G["html_" .. name] = element_func
      else
        -- print("html_" .. name .. " already exists in global scope")
      end
    end)

    if not success then
      error("Failed to create element '" .. name .. "': " .. tostring(result))
    end
  end

  -- luax.elements = elements
end

luax.init()
return luax
