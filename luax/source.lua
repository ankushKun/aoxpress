-- LuaX Module
local luax = {}

-- Safe element creation with error handling
local function safeCreateElement(name, attrs, children)
  local success, result = pcall(function()
    -- Convert children to array if it's a single value
    if children and type(children) ~= "table" then
      children = { children }
    end

    -- Handle text nodes directly
    if type(name) == "string" and name:match("^[a-zA-Z]") then
      return {
        type = "html",
        name = name,
        atts = attrs or {},
        children = children or {}
      }
    else
      -- If name is not a string or doesn't start with a letter, treat as text
      return {
        type = "text",
        text = tostring(name or "")
      }
    end
  end)

  if not success then
    error("Failed to create element '" .. tostring(name) .. "': " .. tostring(result))
  end
  return result
end

-- Create HTML elements with JSX-like syntax
function luax.element(name, attrs, children)
  if type(name) == "function" then
    -- Handle component rendering
    return name(attrs, children)
  end

  return safeCreateElement(name, attrs, children)
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
          -- Handle boolean attributes
          if type(v) == "boolean" then
            if v then
              attrs = attrs .. string.format(' %s', k)
            end
          else
            -- Convert htmlFor to for in output
            local attrName = k == "htmlFor" and "for" or k
            attrs = attrs .. string.format(' %s="%s"', attrName, tostring(v))
          end
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

local elements = {
  "div", "span", "p", "h1", "h2", "h3", "h4", "h5", "h6",
  "a", "img", "input", "button", "form", "label", "select",
  "option", "textarea", "ul", "ol", "li", "table", "tr",
  "td", "th", "thead", "tbody", "header", "footer", "nav",
  "main", "section", "strong", "em",
  "br", "hr", "meta", "link", "script", "style"
}

local reserved_names = { "table", "select" }

-- Create element constructor with table syntax
local function createElementConstructor(name)
  return function(attrs)
    return function(children)
      if type(attrs) == "table" and not attrs.type then
        return luax.element(name, attrs, children)
      else
        return luax.element(name, {}, { attrs })
      end
    end
  end
end

function luax.init()
  luax.elements = {}
  -- Create elements with error handling
  for _, name in ipairs(elements) do
    luax.elements[name] = createElementConstructor(name)

    if not _G[name] then
      _G[name] = luax.elements[name]
    else
      if reserved_names[name] then
        _G["html_" .. name] = luax.elements[name]
      end
    end
  end

  print("Luax initialized")
end

function luax.cleanup()
  for _, name in ipairs(elements) do
    if _G[name] and not reserved_names[name] then
      _G[name] = nil
    else
      _G["html_" .. name] = nil
    end
  end

  print("Luax cleaned up")
end

luax.init()
return luax
