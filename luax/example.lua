luax = require("source")

-- 1. Basic Layout Elements
local layout = div { class = "container mx-auto p-4" } {
    header { class = "bg-blue-500 text-white p-4" } {
        h1 { class = "text-2xl" } { "LuaX Examples" },
        nav { class = "mt-2" } {
            a { href = "#", class = "mr-4" } { "Home" },
            a { href = "#", class = "mr-4" } { "About" },
            a { href = "#" } { "Contact" }
        }
    },
    main { class = "mt-8" } {
        section { id = "text-elements", class = "mb-8" } {
            h2() { "Text Elements" },
            p() { "Regular paragraph text" },
            strong() { "Bold text" },
            em() { "Italic text" },
            p() {
                "Mixed ",
                strong() { "bold" },
                " and ",
                em() { "italic" },
                " text"
            }
        }
    }
}

-- 2. Form Elements
local form_example = form { method = "post", class = "space-y-4" } {
    div { class = "form-group" } {
        label { ["for"] = "name" } { "Name:" },
        input {
            type = "text",
            id = "name",
            name = "name",
            class = "form-input",
            placeholder = "Enter your name"
        } {}
    },
    div { class = "form-group" } {
        label { ["for"] = "country" } { "Country:" },
        html_select { id = "country", name = "country" } {
            option { value = "" } { "Select a country" },
            option { value = "us" } { "United States" },
            option { value = "uk" } { "United Kingdom" }
        }
    },
    div { class = "form-group" } {
        label { ["for"] = "message" } { "Message:" },
        textarea {
            id = "message",
            name = "message",
            rows = "4",
            class = "form-textarea"
        } { "Default text" }
    },
    div { class = "form-group" } {
        div { class = "checkbox" } {
            input {
                type = "checkbox",
                id = "subscribe",
                name = "subscribe"
            } {},
            label { ["for"] = "subscribe" } { "Subscribe to newsletter" }
        }
    },
    div { class = "form-group" } {
        div { class = "radio" } {
            input {
                type = "radio",
                id = "radio1",
                name = "radio_group",
                value = "1"
            } {},
            label { ["for"] = "radio1" } { "Option 1" }
        },
        div { class = "radio" } {
            input {
                type = "radio",
                id = "radio2",
                name = "radio_group",
                value = "2"
            } {},
            label { ["for"] = "radio2" } { "Option 2" }
        }
    },
    button {
        type = "submit",
        class = "btn btn-primary"
    } { "Submit Form" }
}

-- 3. Tables
local table_example = div { class = "table-container" } {
    html_table { class = "table-auto" } {
        thead {} {
            tr {} {
                th { class = "px-4 py-2" } { "Header 1" },
                th { class = "px-4 py-2" } { "Header 2" },
                th { class = "px-4 py-2" } { "Header 3" }
            }
        },
        tbody {} {
            tr {} {
                td { class = "border px-4 py-2" } { "Row 1, Cell 1" },
                td { class = "border px-4 py-2" } { "Row 1, Cell 2" },
                td { class = "border px-4 py-2" } { "Row 1, Cell 3" }
            },
            tr {} {
                td { class = "border px-4 py-2" } { "Row 2, Cell 1" },
                td { class = "border px-4 py-2" } { "Row 2, Cell 2" },
                td { class = "border px-4 py-2" } { "Row 2, Cell 3" }
            }
        }
    }
}

-- 4. Lists
local list_example = div { class = "lists-container" } {
    h3 {} { "Unordered List" },
    ul { class = "list-disc pl-5" } {
        li {} { "First item" },
        li {} { "Second item" },
        li {} {
            "Nested list",
            ul { class = "pl-5" } {
                li {} { "Nested item 1" },
                li {} { "Nested item 2" }
            }
        }
    },
    h3 {} { "Ordered List" },
    ol { class = "list-decimal pl-5" } {
        li {} { "First item" },
        li {} { "Second item" },
        li {} { "Third item" }
    }
}

-- 5. Media Elements
local media_example = div { class = "media-container" } {
    div { class = "image-wrapper" } {
        img {
            src = "example.jpg",
            alt = "Example image",
            class = "rounded-lg shadow-md"
        } {}
    },
    div { class = "video-wrapper mt-4" } {
        iframe {
            src = "https://www.youtube.com/embed/example",
            width = "560",
            height = "315",
            ["frameborder"] = "0",
            allowfullscreen = true
        } {}
    }
}

-- 6. Semantic Elements
local semantic_example = div { class = "semantic-container" } {
    article { class = "blog-post" } {
        header {} {
            h1 {} { "Blog Post Title" },
            time { datetime = "2024-01-01" } { "January 1, 2024" }
        },
        section { class = "content" } {
            p {} { "Article content goes here..." }
        },
        footer {} {
            p {} { "Author: John Doe" }
        }
    },
    aside { class = "sidebar" } {
        h2 {} { "Related Posts" },
        ul {} {
            li {} { a { href = "#" } { "Another post" } },
            li {} { a { href = "#" } { "Yet another post" } }
        }
    }
}

-- 7. Interactive Elements
local interactive_example = div { class = "interactive-container" } {
    dialog { id = "dialog-example" } {
        h2 {} { "Dialog Title" },
        p {} { "Dialog content" },
        button {
            onclick = "closeDialog()",
            class = "close-button"
        } { "Close" }
    },
    details {} {
        summary {} { "Click to expand" },
        p {} { "Hidden content revealed when expanded" }
    }
}

-- Print all examples
print("1. Layout Elements:")
print(luax.render(layout))
print("\n2. Form Elements:")
print(luax.render(form_example))
print("\n3. Table Example:")
print(luax.render(table_example))
print("\n4. List Example:")
print(luax.render(list_example))
print("\n5. Media Elements:")
print(luax.render(media_example))
print("\n6. Semantic Elements:")
print(luax.render(semantic_example))
print("\n7. Interactive Elements:")
print(luax.render(interactive_example))

-- Expected output:
-- <div>
--     <div class="header">
--         <h1>Welcome to LuaX</h1>
--     </div>
--     <div class="container">
--         <table>
--             <tr class="header-row">
--                 <th>Name</th>
--                 <th>Age</th>
--             </tr>
--             <tr class="data-row">
--                 <td>John</td>
--                 <td>25</td>
--             </tr>
--         </table>
--     </div>
--     <div>
--         <p style="color: blue">This is a blue paragraph</p>
--         <img src="image.jpg" alt="Example image"/>
--     </div>
-- </div>
