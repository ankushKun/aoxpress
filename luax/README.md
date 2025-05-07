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

-- Simple div with text
local page = div {} { h1 {} { "Welcome to LuaX" } }

-- Render to HTML string
print(luax.render(page))

-- Output:
-- <div><h1>Welcome to LuaX</h1></div>
```

## Element Syntax

- All elements are called as functions twice:
  - First call: attributes table (use `{}` if no attributes)
  - Second call: children table (use `{}` if no children)
- Text nodes can be plain strings in the children table
- You can nest elements naturally

### Examples

#### Simple Elements
```lua
local hello = h1 {} { "Hello World!" }
local para = p {} { "This is a paragraph." }

-- Equivalent HTML:
-- <h1>Hello World!</h1>
-- <p>This is a paragraph.</p>
```

#### With Attributes
```lua
local btn = button { class = "btn-primary", type = "button" } { "Click Me" }
local imgEl = img { src = "logo.png", alt = "Logo" } {}

-- Equivalent HTML:
-- <button class="btn-primary" type="button">Click Me</button>
-- <img src="logo.png" alt="Logo"/>
```

#### Nested Elements
```lua
local card = div { class = "card" } {
    h2 {} { "Card Title" },
    p {} { "Card content goes here." }
}

-- Equivalent HTML:
-- <div class="card">
--   <h2>Card Title</h2>
--   <p>Card content goes here.</p>
-- </div>
```

#### Lists
```lua
local myList = ul { class = "list-disc" } {
    li {} { "Item 1" },
    li {} { "Item 2" },
    li {} { "Item 3" }
}

-- Equivalent HTML:
-- <ul class="list-disc">
--   <li>Item 1</li>
--   <li>Item 2</li>
--   <li>Item 3</li>
-- </ul>
```

#### Table
```lua
local myTable = html_table { class = "table" } {
    tr {} {
        th {} { "Header 1" },
        th {} { "Header 2" }
    },
    tr {} {
        td {} { "Cell 1" },
        td {} { "Cell 2" }
    }
}

-- Equivalent HTML:
-- <table class="table">
--   <tr>
--     <th>Header 1</th>
--     <th>Header 2</th>
--   </tr>
--   <tr>
--     <td>Cell 1</td>
--     <td>Cell 2</td>
--   </tr>
-- </table>
```

#### Components
```lua
local Button = luax.component(function(props, children)
    return button {
        class = "btn " .. (props.class or ""),
        type = props.type or "button"
    } (children)
end)

local myButton = Button { class = "primary", type = "submit" } { "Submit" }

-- Equivalent HTML:
-- <button class="btn primary" type="submit">Submit</button>
```

## Built-in Elements

LuaX provides built-in helpers for common HTML elements:
- `div`, `span`, `p`
- `h1` through `h6`
- `a`, `img`, `input`, `button`
- `form`, `label`, `html_select`, `option`
- `textarea`, `ul`, `ol`, `li`
- `html_table`, `tr`, `td`, `th`, `thead`, `tbody`
- `header`, `footer`, `nav`, `main`, `section`
- `strong`, `em`
- `br`, `hr`, `meta`, `link`, `script`, `style`
- `iframe`, `summary`, `details`, `article`, `time`, `aside`, `dialog`

> Reserved names like `table` and `select` are available as `html_table` and `html_select`.

## Notes

- Element names are automatically added to the global scope
- If an element name conflicts with an existing global, it's prefixed with `html_`

## API Reference

### Core Functions

#### `luax.element(name, attrs, children)`
Creates an HTML element.
- `name`: String - The HTML tag name
- `attrs`: Table - Element attributes
- `children`: Table - Child elements

#### `luax.text(text)`
Creates a text node (usually not needed, as strings are auto-converted).
- `text`: String - The text content

#### `luax.component(render)`
Creates a reusable component.
- `render`: Function - The component's render function

#### `luax.render(element)`
Renders an element to HTML string.
- `element`: Table - The element to render

## License

MIT