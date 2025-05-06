

-- LuaX Module
local luax = {}

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

-- Create HTML elements
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

-- Helper function to create elements with a more JSX-like syntax
function luax.create(name)
  if type(name) ~= "string" then
    error("Element name must be a string, got " .. type(name))
  end

  return function(attrs, children)
    local success, result = pcall(function()
      if type(attrs) == "table" and not attrs.type then
        -- If first argument is a table and not already an element, it's attributes
        return luax.element(name, attrs, children)
      else
        -- If first argument is not a table or is an element, it's children
        return luax.element(name, {}, { attrs })
      end
    end)

    if not success then
      error("Failed to create element '" .. name .. "': " .. tostring(result))
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

local elements = {
  "div", "span", "p", "h1", "h2", "h3", "h4", "h5", "h6",
  "a", "img", "input", "button", "form", "label", "select",
  "option", "textarea", "ul", "ol", "li", "table", "tr",
  "td", "th", "thead", "tbody", "header", "footer", "nav",
  "main", "section", "strong", "em",
  "br", "hr", "meta", "link", "script", "style"
}

local reserved_names = {
  "table", "select"
}

-- Create elements with error handling
for _, name in ipairs(elements) do
  local success, result = pcall(function()
    elements[name] = luax.create(name)
    if not _G[name] then
      _G[name] = elements[name]
    else
      if reserved_names[name] then
        _G["html_" .. name] = elements[name]
      else
        _G[name] = elements[name]
      end
    end
  end)

  if not success then
    error("Failed to create element '" .. name .. "': " .. tostring(result))
  end
end

-- when importing luax, set e = luax.elements for shorthand usage
luax.elements = elements

return luax
