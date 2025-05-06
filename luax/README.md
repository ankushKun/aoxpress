# LuaX

A lightweight library for AO Lua that provides a JSX-like syntax for creating HTML elements programmatically.

Meant to be used with [aoxpress package](https://apm.betteridea.dev/pkg?id=@apm/aoxpress)

## Installation

```lua
.load-blueprint apm
apm.install("luax")
```

## Basic Usage

```lua
local luax = require("luax")

-- Create a simple div with text
local page = div({class = "text-xl text-center"}, {
    h1({}, { text("Welcome to LuaX") })
})

-- Render to HTML string
print(luax.render(page))

-- output
-- <div class="text-xl text-center">
--      <h1>Welcome to LuaX</h1>
-- </div>
```

### Built-in Elements

LuaX provides built-in helpers for common HTML elements:
- `div`, `span`, `p`
- `h1` through `h6`
- `a`, `img`, `input`, `button`
- `form`, `label`, `html_select`, `option`
- `textarea`, `ul`, `ol`, `li`
- `html_table`, `tr`, `td`, `th`
- `header`, `footer`, `nav`, `main`, `section`
- `strong`, `em`
- `br`, `hr`, `meta`, `link`, `script`, `style`

## Examples

### Creating Elements

```lua
-- Basic element with attributes
local button = button({
    class = "btn",
    type = "submit"
}, {
    luax.text("Click me")
})

-- Nested elements
local card = div({
    class = "card"
}, {
    h2({}, { text("Card Title") }),
    p({}, { text("Card content") })
})
```

### Creating Components

```lua
local Button = luax.component(function(props, children)
    return button({
        class = "btn " .. (props.class or ""),
        type = props.type or "button"
    }, children)
end)

-- Using the component
local myButton = Button({
    class = "primary",
    type = "submit"
}, {
    text("Submit")
})
```

## Notes

- Element names are automatically added to the global scope
- If an element name conflicts with an existing global, it's prefixed with "html_"
- All element creation functions include error handling
- The library is designed to be lightweight and performant

## API Reference

### Core Functions

#### `luax.element(name, attrs, children)`
Creates an HTML element.
- `name`: String - The HTML tag name
- `attrs`: Table - Element attributes
- `children`: Table - Child elements

#### `luax.text(text)`
Creates a text node.
- `text`: String - The text content

#### `luax.component(render)`
Creates a reusable component.
- `render`: Function - The component's render function

#### `luax.render(element)`
Renders an element to HTML string.
- `element`: Table - The element to render

## License

MIT