# sakenlang Branding & Marketing Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebrand sakenlang with professional "Academic Modern" marketing — new README, landing page, language guide, and social preview.

**Architecture:** Four independent deliverables (README.md, index.html, docs/README.md, .github/social.html), all sharing one visual identity (Swift Blue palette, Inter + JetBrains Mono typography). No build step — all files are static. Content is English-primary with Russian secondary.

**Tech Stack:** HTML/CSS (landing page), Markdown (README, docs), Google Fonts CDN (Inter, JetBrains Mono)

**Design Spec:** `docs/superpowers/specs/2026-04-30-sakenlang-branding-design.md`

---

## File Map

| Deliverable | File | Action |
|---|---|---|
| README | `README.md` | Rewrite (overwrite existing) |
| Landing page | `index.html` | Create new |
| Language Guide | `docs/README.md` | Rewrite (overwrite existing) |
| Social preview | `.github/social.html` | Create new (+ create `.github/` dir) |
| Gitignore update | `.gitignore` | Append `.superpowers/` |

---

### Task 1: Update .gitignore

**Files:**
- Modify: `.gitignore`

- [ ] **Step 1: Append .superpowers/ to .gitignore**

Add this line to the end of `.gitignore`:

```
.superpowers/
```

- [ ] **Step 2: Verify**

Run: `cat .gitignore`

Expected: the file contains `.superpowers/` at the end.

---

### Task 2: README.md — Complete Rewrite

**Files:**
- Rewrite: `README.md`

**Reference:** Spec section 4 (README.md)

**Rules:**
- English primary, one Russian section
- No emojis in headings
- Under 150 lines total
- First code block within first 10 lines

- [ ] **Step 1: Write the new README.md**

Overwrite `README.md` with this exact content:

```markdown
# sakenlang

> From hello world to web apps. One language.
>
> *От hello world до веб-приложений. Один язык.*

A modern teaching language with Swift-like syntax, built-in HTTP server, and error messages in Russian.

```
func greet(name) {
    print("Привет, " + name + "!")
}

greet("мир")    // Привет, мир!
```

## Features

- **Swift-like syntax** — familiar, clean syntax students already recognize
- **Built-in HTTP server** — `route()`, `serve()`, `param()` for web apps out of the box
- **SQLite database** — `model()`, `migrate()`, `create()`, `find()` with zero setup
- **REPL** — interactive mode for experimenting line by line
- **Error messages in Russian** — with line numbers, no language barrier
- **VS Code support** — syntax highlighting for `.sl` files

## Get Started

```bash
# Run a program
./sakenlang examples/hello.sl

# Interactive mode
./sakenlang
```

## Code Examples

**Variables & Control Flow**

```
var temperature = 35

if temperature > 30 {
    print("Жарко!")
} else {
    print("Нормально")
}
```

**Web Server**

```
route("GET", "/", func() {
    return "<h1>sakenlang web</h1>"
})

route("GET", "/hello", func() {
    let name = param("name")
    return "Привет, " + name + "!"
})

serve(3000)
```

**Working with Data**

```
var scores = [85, 92, 78, 95, 88]
var i = 0
var total = 0

while i < len(scores) {
    total = total + scores[i]
    i = i + 1
}

print(total)    // 438
```

## Why sakenlang?

sakenlang occupies the space between Scratch and Python. Unlike Scratch, it uses real text-based syntax that prepares students for industry languages. Unlike Python or JavaScript, it has zero ecosystem complexity — no package managers, no virtual environments, no toolchain. One binary, one language, from basics to web apps.

## Language Guide

The complete language reference is in [The sakenlang Book](docs/README.md) — from variables to building MVC web applications.

## Для преподавателей

sakenlang создан для использования в учебных курсах по основам программирования. Один исполняемый файл, никаких зависимостей — студенты начинают писать код за минуту. В папке [`examples/`](examples/) — 11 готовых примеров от hello world до полноценного ERP-приложения с MVC-архитектурой.

## Development

```bash
make build      # build executable (requires Racket)
make clean      # clean build artifacts
```

```
sakenlang/
├── sakenlang              # executable binary
├── src/                   # interpreter source (Racket)
│   ├── lexer.rkt          # tokenizer
│   ├── parser.rkt         # parser (AST)
│   ├── evaluator.rkt      # evaluator
│   ├── http-server.rkt    # built-in HTTP server
│   ├── db.rkt             # SQLite integration
│   └── controller.rkt     # MVC controllers
├── examples/              # 11 example programs
├── tests/                 # test suite
├── docs/                  # language guide
└── vscode-sakenlang/      # VS Code extension
```

## License

MIT
```

- [ ] **Step 2: Verify line count**

Run: `wc -l README.md`

Expected: under 150 lines.

- [ ] **Step 3: Verify first code block is within first 10 lines**

Run: `head -10 README.md`

Expected: the code fence opening (```) appears by line 9-10.

---

### Task 3: Landing Page — index.html

**Files:**
- Create: `index.html`

**Reference:** Spec section 3 (Landing Page)

**Rules:**
- Single HTML file, no dependencies besides Google Fonts CDN
- Responsive (mobile-first)
- No JavaScript required
- Page weight under 50KB
- Colors: Primary #0A84FF, Accent #5E5CE6, Dark #1C1C1E, Light #F2F2F7
- Fonts: Inter (headings/body), JetBrains Mono (code)

- [ ] **Step 1: Create index.html**

Write the file `index.html` with the following content. This is a single self-contained HTML file with embedded CSS:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>sakenlang — From hello world to web apps. One language.</title>
    <meta name="description" content="A modern teaching language with Swift-like syntax, built-in HTTP server, and error messages in Russian.">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }

        :root {
            --primary: #0A84FF;
            --accent: #5E5CE6;
            --dark: #1C1C1E;
            --light: #F2F2F7;
            --white: #FFFFFF;
            --text: #333333;
            --muted: #888888;
        }

        body {
            font-family: 'Inter', system-ui, -apple-system, sans-serif;
            color: var(--text);
            line-height: 1.6;
            background: var(--white);
        }

        /* Hero */
        .hero {
            background: linear-gradient(135deg, var(--primary), var(--accent));
            padding: 80px 24px 64px;
            text-align: center;
            color: var(--white);
        }

        .hero-eyebrow {
            font-size: 12px;
            font-weight: 600;
            letter-spacing: 2px;
            text-transform: uppercase;
            opacity: 0.8;
            margin-bottom: 12px;
        }

        .hero-title {
            font-size: 48px;
            font-weight: 700;
            letter-spacing: -1px;
            margin-bottom: 8px;
        }

        .hero-tagline {
            font-size: 20px;
            font-weight: 400;
            opacity: 0.9;
            max-width: 480px;
            margin: 0 auto 32px;
        }

        .hero-buttons {
            display: flex;
            gap: 12px;
            justify-content: center;
            flex-wrap: wrap;
        }

        .btn-primary {
            background: var(--white);
            color: var(--primary);
            padding: 12px 28px;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 600;
            text-decoration: none;
            transition: opacity 0.2s;
        }

        .btn-outline {
            border: 1.5px solid rgba(255,255,255,0.5);
            color: var(--white);
            padding: 12px 28px;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 600;
            text-decoration: none;
            transition: border-color 0.2s;
        }

        .btn-primary:hover { opacity: 0.9; }
        .btn-outline:hover { border-color: var(--white); }

        /* Sections */
        .section {
            max-width: 720px;
            margin: 0 auto;
            padding: 64px 24px;
        }

        .section-title {
            font-size: 28px;
            font-weight: 700;
            letter-spacing: -0.5px;
            margin-bottom: 24px;
            color: var(--dark);
        }

        /* Code Block */
        .code-block {
            background: var(--dark);
            border-radius: 12px;
            overflow: hidden;
            max-width: 720px;
            margin: -32px auto 0;
            position: relative;
            z-index: 1;
            box-shadow: 0 8px 32px rgba(0,0,0,0.2);
        }

        .code-tab {
            background: #2C2C2E;
            padding: 10px 16px;
            font-family: 'JetBrains Mono', monospace;
            font-size: 12px;
            color: var(--muted);
        }

        .code-body {
            padding: 20px 24px;
            font-family: 'JetBrains Mono', monospace;
            font-size: 14px;
            line-height: 1.7;
            color: #F2F2F7;
            overflow-x: auto;
        }

        .code-body .kw { color: #FF79C6; }
        .code-body .fn { color: #8BE9FD; }
        .code-body .str { color: #F1FA8C; }
        .code-body .cm { color: #6272A4; }
        .code-body .num { color: #BD93F9; }

        /* Features */
        .features {
            background: var(--light);
            padding: 64px 24px;
        }

        .features-grid {
            max-width: 720px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
        }

        .feature-card {
            background: var(--white);
            padding: 24px;
            border-radius: 12px;
        }

        .feature-icon {
            font-size: 28px;
            margin-bottom: 8px;
        }

        .feature-card h3 {
            font-size: 16px;
            font-weight: 700;
            margin-bottom: 4px;
            color: var(--dark);
        }

        .feature-card p {
            font-size: 14px;
            color: var(--muted);
            line-height: 1.4;
        }

        /* Why */
        .why p {
            font-size: 16px;
            color: var(--text);
            line-height: 1.7;
            max-width: 640px;
        }

        /* Quick Start */
        .quickstart {
            background: var(--dark);
            border-radius: 12px;
            padding: 24px;
            margin-top: 16px;
        }

        .quickstart code {
            font-family: 'JetBrains Mono', monospace;
            font-size: 14px;
            color: #F2F2F7;
            line-height: 2;
        }

        .quickstart .prompt { color: #30D158; }
        .quickstart .cm { color: #6272A4; }

        /* Footer */
        .footer {
            text-align: center;
            padding: 32px 24px;
            font-size: 14px;
            color: var(--muted);
        }

        .footer a {
            color: var(--primary);
            text-decoration: none;
        }

        /* Responsive */
        @media (max-width: 600px) {
            .hero { padding: 56px 20px 48px; }
            .hero-title { font-size: 36px; }
            .hero-tagline { font-size: 17px; }
            .features-grid { grid-template-columns: 1fr; }
            .code-body { font-size: 13px; padding: 16px; }
        }
    </style>
</head>
<body>

    <!-- Hero -->
    <section class="hero">
        <div class="hero-eyebrow">A Modern Teaching Language</div>
        <h1 class="hero-title">sakenlang</h1>
        <p class="hero-tagline">From hello world to web apps. One language.</p>
        <div class="hero-buttons">
            <a href="#quickstart" class="btn-primary">Get Started</a>
            <a href="https://github.com/sakentukenov/sakenlang" class="btn-outline">GitHub</a>
        </div>
    </section>

    <!-- Code Example -->
    <div class="code-block">
        <div class="code-tab">hello.sl</div>
        <div class="code-body">
<span class="kw">func</span> greet(name) {
    <span class="fn">print</span>(<span class="str">"Привет, "</span> + name + <span class="str">"!"</span>)
}

<span class="kw">let</span> message = <span class="str">"мир"</span>
greet(message)    <span class="cm">// Привет, мир!</span>
        </div>
    </div>

    <!-- Features -->
    <section class="features">
        <div class="features-grid">
            <div class="feature-card">
                <div class="feature-icon">&#x1F4D6;</div>
                <h3>Swift-like Syntax</h3>
                <p>Familiar, clean syntax your students already recognize</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">&#x1F310;</div>
                <h3>Built-in HTTP</h3>
                <p>Web server included. Route, serve, build web apps.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">&#x1F5C4;</div>
                <h3>SQLite Built-in</h3>
                <p>Database operations with zero setup</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">&#x1F1F0;&#x1F1FF;</div>
                <h3>Russian Errors</h3>
                <p>Error messages in Russian with line numbers</p>
            </div>
        </div>
    </section>

    <!-- Why -->
    <section class="section why">
        <h2 class="section-title">Why sakenlang?</h2>
        <p>
            sakenlang occupies the space between Scratch and Python. Unlike Scratch, it uses real
            text-based syntax that prepares students for industry languages. Unlike Python or
            JavaScript, it has zero ecosystem complexity — no package managers, no virtual
            environments, no toolchain. One binary, one language, from basics to web apps
            with a built-in HTTP server and SQLite database.
        </p>
    </section>

    <!-- Quick Start -->
    <section class="section" id="quickstart">
        <h2 class="section-title">Quick Start</h2>
        <div class="quickstart">
            <code>
                <span class="cm"># Run a program</span><br>
                <span class="prompt">$</span> ./sakenlang examples/hello.sl<br><br>
                <span class="cm"># Interactive REPL</span><br>
                <span class="prompt">$</span> ./sakenlang<br><br>
                <span class="cm"># Start a web server</span><br>
                <span class="prompt">$</span> ./sakenlang examples/web.sl
            </code>
        </div>
    </section>

    <!-- Footer -->
    <footer class="footer">
        Made in Kazakhstan · <a href="https://github.com/sakentukenov/sakenlang">GitHub</a>
    </footer>

</body>
</html>
```

- [ ] **Step 2: Open in browser and verify**

Run: `open index.html` (macOS) or open manually in browser.

Verify:
- Hero gradient is blue-to-indigo
- Code block has dark background with syntax colors
- 2x2 feature grid renders on desktop, stacks on mobile
- "Get Started" anchors to #quickstart section
- Footer shows "Made in Kazakhstan"
- Page is responsive (resize browser window)

- [ ] **Step 3: Check file size**

Run: `wc -c index.html`

Expected: under 51200 bytes (50KB).

---

### Task 4: The sakenlang Book — docs/README.md

**Files:**
- Rewrite: `docs/README.md`

**Reference:** Spec section 5 (Documentation)

**Rules:**
- Single markdown file, linear reading order
- English text, Cyrillic in code examples
- Each chapter starts with `## N. Chapter Title`
- Each chapter ends with a "Try it" exercise
- Target: 800-1200 lines
- All code examples must be valid sakenlang

- [ ] **Step 1: Write The sakenlang Book**

Overwrite `docs/README.md` with the following content:

```markdown
# The sakenlang Book

A complete guide to the sakenlang programming language — from your first program to building web applications.

---

## 1. Welcome to sakenlang

sakenlang is a modern teaching language designed for university CS courses. It has a Swift-like syntax that is clean, readable, and familiar to anyone who has seen a modern programming language.

sakenlang is different from other teaching tools. It is a real text-based language — not a visual block editor — but it strips away all the ecosystem complexity that makes languages like Python or JavaScript overwhelming for beginners. No package managers, no virtual environments, no build tools. One binary runs everything.

What makes sakenlang unique is its range. In a single language, students can learn variables, functions, and control flow — and then build web applications with a built-in HTTP server and SQLite database. Error messages are in Russian with line numbers, removing the language barrier from debugging.

sakenlang is written in Racket and compiles to a single executable binary.

---

## 2. Getting Started

### Download

The `sakenlang` binary is included in the project. No installation required.

### Run a Program

```bash
./sakenlang examples/hello.sl
```

### Interactive Mode (REPL)

Start the REPL by running `sakenlang` with no arguments:

```bash
./sakenlang
```

```
sakenlang> print("Привет!")
Привет!
sakenlang> var x = 10
sakenlang> print(x + 5)
15
sakenlang> exit
```

Type `exit` or press Ctrl+D to quit.

### Your First Program

Create a file called `first.sl`:

```
let name = "Сакен"
var age = 20

print("Привет, " + name + "!")
print(age)
```

Run it:

```bash
./sakenlang first.sl
```

Output:

```
Привет, Сакен!
20
```

**Try it:** Create a file called `about_me.sl` that prints your name, age, and favorite food.

---

## 3. The Basics

### Variables

sakenlang has two kinds of variables:

- `let` — creates a constant (cannot be changed)
- `var` — creates a mutable variable (can be changed)

```
let name = "Арман"       // constant — cannot change
var score = 0            // mutable — can change
score = score + 10       // ok
// name = "other"        // ERROR: cannot reassign let variable
```

### Types

| Type   | Example           | Description       |
|--------|-------------------|-------------------|
| Int    | `42`, `0`, `100`  | Whole numbers     |
| String | `"Привет"`        | Text in quotes    |
| Bool   | `true`, `false`   | Logical values    |
| Array  | `[1, 2, 3]`       | Lists of values   |

Types are inferred — you do not declare them explicitly.

### Print

Use `print()` to output values:

```
print(42)
print("Привет!")
print(2 + 3)
```

### Comments

Single-line comments start with `//`:

```
// This is a comment
var x = 10  // comment after code
```

**Try it:** Create variables for your university name (`let`), your current semester number (`var`), and print them both.

---

## 4. Control Flow

### if / else

```
var grade = 85

if grade > 89 {
    print("Отлично!")
} else {
    print("Хорошо")
}
```

The `else` block is optional:

```
var is_raining = true

if is_raining {
    print("Возьми зонт!")
}
```

### Nested Conditions

```
var grade = 75

if grade > 89 {
    print("Отлично")
} else {
    if grade > 74 {
        print("Хорошо")
    } else {
        print("Удовлетворительно")
    }
}
```

### Comparison Operators

| Operator | Meaning       | Example   |
|----------|---------------|-----------|
| `==`     | Equal         | `x == 5`  |
| `!=`     | Not equal     | `x != 0`  |
| `<`      | Less than     | `x < 10`  |
| `>`      | Greater than  | `x > 0`   |

### Logical Operators

| Operator | Meaning          | Example     |
|----------|------------------|-------------|
| `&&`     | AND (both true)  | `a && b`    |
| `\|\|`   | OR (either true) | `a \|\| b`  |
| `!`      | NOT (invert)     | `!a`        |

```
var has_umbrella = false
var is_raining = true

if is_raining && !has_umbrella {
    print("Возьми зонт!")
}
```

### while Loops

```
var i = 1
while i < 6 {
    print(i)
    i = i + 1
}
```

This prints numbers 1 through 5.

**Try it:** Write a program that prints all even numbers from 2 to 20 using a `while` loop.

---

## 5. Functions

### Declaring Functions

```
func add(a, b) {
    return a + b
}

print(add(10, 20))    // 30
```

### Functions Without Return

```
func greet(name) {
    print("Привет, " + name + "!")
}

greet("Алия")    // Привет, Алия!
```

### Multiple Parameters

```
func introduce(name, age) {
    print(name + " — " + to_string(age) + " лет")
}

introduce("Арман", 21)
```

### Anonymous Functions (Closures)

Functions can be assigned to variables:

```
let double = func(x) {
    return x * 2
}

print(double(5))     // 10
print(double(17))    // 34
```

Anonymous functions are used heavily in the HTTP server (see Chapter 8).

**Try it:** Write a function `max(a, b)` that returns the larger of two numbers.

---

## 6. Collections

### Arrays

Create an array with square brackets:

```
var fruits = ["яблоко", "банан", "апельсин"]
var numbers = [10, 20, 30, 40, 50]
```

### Indexing

Access elements by index (starting from 0):

```
var nums = [10, 20, 30]
print(nums[0])    // 10
print(nums[2])    // 30
```

### Length

Use `len()` to get the number of elements:

```
var items = [1, 2, 3, 4, 5]
print(len(items))    // 5
```

### Mutation

Change an element by index:

```
var colors = ["red", "green", "blue"]
colors[1] = "yellow"
print(colors[1])    // yellow
```

### Adding Elements

Use `push()` to add an element to the end:

```
var list = [1, 2, 3]
push(list, 4)
print(len(list))    // 4
```

### Iterating

Loop through all elements with `while`:

```
var scores = [85, 92, 78, 95, 88]
var i = 0

while i < len(scores) {
    print(scores[i])
    i = i + 1
}
```

**Try it:** Create an array of 5 names and print each one with its index number (e.g., "1. Арман").

---

## 7. Working with Strings

### Concatenation

Join strings with `+`:

```
let first = "Привет"
let second = "мир"
print(first + ", " + second + "!")    // Привет, мир!
```

### Type Conversion

Convert numbers to strings with `to_string()`:

```
var age = 21
print("Мне " + to_string(age) + " год")
```

Convert strings to numbers with `to_int()`:

```
var input = "42"
var number = to_int(input)
print(number + 8)    // 50
```

### Unicode Support

sakenlang fully supports Unicode. Strings can contain Cyrillic, emoji, and any other characters:

```
let greeting = "Сәлем, әлем!"
print(greeting)
```

**Try it:** Write a program that builds a sentence from separate words using concatenation and `to_string()`.

---

## 8. Building Web Apps

sakenlang has a built-in HTTP server. No external libraries, no setup.

### Your First Web App

```
route("GET", "/", func() {
    return "<h1>Привет, мир!</h1>"
})

serve(3000)
```

Run it:

```bash
./sakenlang web.sl
```

Open `http://localhost:3000` in your browser.

### Routes

Register routes with `route(method, path, handler)`:

```
route("GET", "/", func() {
    return "<h1>Home</h1>"
})

route("GET", "/about", func() {
    return "<h1>About</h1><p>This is sakenlang.</p>"
})

serve(3000)
```

### Query Parameters

Use `param(name)` to read query parameters:

```
route("GET", "/hello", func() {
    let name = param("name")
    return "<h1>Привет, " + name + "!</h1>"
})

serve(3000)
```

Visit `http://localhost:3000/hello?name=Арман` to see "Привет, Арман!"

### Headers and Status Codes

```
route("GET", "/api/data", func() {
    header("Content-Type")
    status(200)
    return "{\"result\": \"ok\"}"
})
```

### Built-in HTTP Functions

| Function              | Description                      |
|-----------------------|----------------------------------|
| `route(method, path, handler)` | Register a route        |
| `serve(port)`         | Start the HTTP server            |
| `param(name)`         | Get a query/body parameter       |
| `header(name)`        | Get an HTTP header               |
| `status(code)`        | Set response status code         |

**Try it:** Build a web app with three pages: home, about, and a greeting page that reads a name from `?name=`.

---

## 9. Working with Data

sakenlang has built-in SQLite support for database operations.

### Defining a Model

```
model("student", func() {
    field("name", "text")
    field("grade", "integer")
})

migrate()
```

### Creating Records

```
create("student", record("name", "Арман", "grade", 85))
create("student", record("name", "Алия", "grade", 92))
```

### Querying Records

```
var students = all("student")
var i = 0
while i < len(students) {
    let s = students[i]
    print(get(s, "name"))
    i = i + 1
}
```

### Finding Records

```
var top = where("student", "grade > 90")
```

### Counting

```
var total = count("student")
print(total)
```

### Database Functions

| Function                       | Description                    |
|-------------------------------|--------------------------------|
| `model(name, schema)`         | Define a database model        |
| `field(name, type)`           | Add a field to a model         |
| `migrate()`                   | Create/update database tables  |
| `create(model, data)`         | Insert a new record            |
| `all(model)`                  | Get all records                |
| `find(model, id)`             | Find a record by ID            |
| `where(model, condition)`     | Query records with a condition |
| `update(model, id, data)`     | Update a record                |
| `delete(model, id)`           | Delete a record                |
| `count(model)`                | Count records                  |
| `save(model, data)`           | Insert or update a record      |
| `record(key, val, ...)`       | Create a data record           |
| `get(record, key)`            | Get a field from a record      |
| `set(record, key, value)`     | Set a field in a record        |
| `keys(record)`                | Get all keys from a record     |
| `query(sql)`                  | Run raw SQL query              |
| `run_query(sql)`              | Run raw SQL command            |

**Try it:** Create a "book" model with title and author fields, insert 3 books, and print all of them.

---

## 10. MVC Pattern

For larger applications, sakenlang supports the Model-View-Controller pattern. The `examples/erp/` directory contains a complete example.

### Project Structure

```
erp/
├── app.sl                 # entry point
├── models/
│   ├── product.sl         # product model
│   └── order.sl           # order model
├── controllers/
│   ├── products.sl        # product routes
│   └── orders.sl          # order routes
└── views/
    ├── dashboard.sl        # dashboard HTML
    ├── products.sl         # product list HTML
    └── orders.sl           # order list HTML
```

### Controllers

Controllers define routes and handle requests:

```
route("GET", "/products", func() {
    var products = all("product")
    return render("products", products)
})
```

### Views

Views return HTML with data:

```
func render(template, data) {
    return page("Products", view("products", data))
}
```

### Running the ERP Example

```bash
./sakenlang examples/erp/app.sl
```

Open `http://localhost:3000` to see the dashboard.

**Try it:** Add a new model (e.g., "customer") to the ERP example with a controller and a view.

---

## 11. Language Reference

### Keywords

| Keyword  | Usage                          |
|----------|--------------------------------|
| `let`    | Declare a constant             |
| `var`    | Declare a mutable variable     |
| `if`     | Conditional branch             |
| `else`   | Alternative branch             |
| `while`  | Loop                           |
| `func`   | Declare a function             |
| `return` | Return a value from a function |
| `true`   | Boolean literal                |
| `false`  | Boolean literal                |
| `print`  | Output a value                 |

### Operators

| Operator | Type        | Description       |
|----------|-------------|-------------------|
| `+`      | Arithmetic  | Addition / string concatenation |
| `-`      | Arithmetic  | Subtraction       |
| `*`      | Arithmetic  | Multiplication    |
| `/`      | Arithmetic  | Integer division  |
| `==`     | Comparison  | Equal             |
| `!=`     | Comparison  | Not equal         |
| `<`      | Comparison  | Less than         |
| `>`      | Comparison  | Greater than      |
| `&&`     | Logical     | AND               |
| `\|\|`   | Logical     | OR                |
| `!`      | Logical     | NOT               |
| `=`      | Assignment  | Assign value      |

### Built-in Functions

| Function              | Description                            |
|-----------------------|----------------------------------------|
| `print(value)`        | Output a value to the console          |
| `len(array)`          | Get the length of an array             |
| `push(array, value)`  | Add an element to the end of an array  |
| `to_string(value)`    | Convert a value to a string            |
| `to_int(string)`      | Convert a string to an integer         |
| `record(k, v, ...)`   | Create a key-value data record        |
| `get(record, key)`    | Get a field from a record              |
| `set(record, k, v)`   | Set a field in a record                |
| `keys(record)`        | Get all keys from a record             |

### HTTP Functions

| Function              | Description                      |
|-----------------------|----------------------------------|
| `route(method, path, handler)` | Register a route        |
| `serve(port)`         | Start the HTTP server            |
| `param(name)`         | Get a query/body parameter       |
| `header(name)`        | Get an HTTP header               |
| `status(code)`        | Set response status code         |
| `render(template, data)` | Render a view template        |
| `redirect(url)`       | Redirect to another URL          |
| `page(title, body)`   | Wrap content in an HTML page     |
| `view(name, data)`    | Load a view with data            |

### Database Functions

| Function                       | Description                    |
|-------------------------------|--------------------------------|
| `model(name, schema)`         | Define a database model        |
| `field(name, type)`           | Add a field to a model         |
| `migrate()`                   | Create/update database tables  |
| `create(model, data)`         | Insert a new record            |
| `all(model)`                  | Get all records                |
| `find(model, id)`             | Find a record by ID            |
| `where(model, condition)`     | Query with a condition         |
| `update(model, id, data)`     | Update a record                |
| `delete(model, id)`           | Delete a record                |
| `count(model)`                | Count records                  |
| `save(model, data)`           | Insert or update               |
| `query(sql)`                  | Run raw SQL query              |
| `run_query(sql)`              | Run raw SQL command            |

### Error Messages

Errors are reported in Russian with line numbers:

| Error | Meaning |
|-------|---------|
| `Ошибка [строка 3]: переменная 'x' не найдена` | Variable not found |
| `Ошибка [строка 5]: нельзя изменить let-переменную 'name'` | Cannot reassign constant |
| `Ошибка: переменная 'x' уже объявлена` | Variable already declared |
| `Ошибка: деление на ноль` | Division by zero |
| `Ошибка: условие if должно быть Bool` | If condition must be Bool |
| `Ошибка: индекс выходит за границы массива` | Array index out of bounds |
```

- [ ] **Step 2: Verify line count**

Run: `wc -l docs/README.md`

Expected: between 800 and 1200 lines.

- [ ] **Step 3: Verify all chapters present**

Run: `grep "^## " docs/README.md`

Expected output:
```
## 1. Welcome to sakenlang
## 2. Getting Started
## 3. The Basics
## 4. Control Flow
## 5. Functions
## 6. Collections
## 7. Working with Strings
## 8. Building Web Apps
## 9. Working with Data
## 10. MVC Pattern
## 11. Language Reference
```

---

### Task 5: GitHub Social Preview — .github/social.html

**Files:**
- Create: `.github/social.html`

This is an HTML template that can be opened in a browser and screenshotted at 1280x640 for use as a GitHub social preview image.

- [ ] **Step 1: Create .github directory**

Run: `mkdir -p .github`

- [ ] **Step 2: Write .github/social.html**

Write the file `.github/social.html`:

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;700&family=JetBrains+Mono&display=swap" rel="stylesheet">
    <style>
        body {
            margin: 0;
            width: 1280px;
            height: 640px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #0A84FF, #5E5CE6);
            font-family: 'Inter', system-ui, sans-serif;
            color: #fff;
            text-align: center;
        }
        .logo {
            width: 80px;
            height: 80px;
            border-radius: 20px;
            background: rgba(255,255,255,0.2);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 48px;
            font-weight: 700;
            margin-bottom: 24px;
        }
        .title {
            font-size: 56px;
            font-weight: 700;
            letter-spacing: -1px;
            margin-bottom: 12px;
        }
        .tagline {
            font-size: 24px;
            opacity: 0.9;
            max-width: 600px;
        }
        .subtitle {
            font-size: 16px;
            opacity: 0.7;
            margin-top: 20px;
            font-family: 'JetBrains Mono', monospace;
        }
    </style>
</head>
<body>
    <div class="logo">S</div>
    <div class="title">sakenlang</div>
    <div class="tagline">From hello world to web apps. One language.</div>
    <div class="subtitle">A modern teaching language for CS courses</div>
</body>
</html>
```

- [ ] **Step 3: Verify**

Run: `open .github/social.html` and confirm:
- Page is 1280x640 with blue-indigo gradient
- White "S" logo mark centered
- Title "sakenlang" and tagline visible
- Ready to screenshot for GitHub social preview

---

### Task 6: Final Verification

- [ ] **Step 1: Verify all files exist**

Run: `ls -la README.md index.html docs/README.md .github/social.html .gitignore`

Expected: all five files present.

- [ ] **Step 2: Verify README is under 150 lines**

Run: `wc -l README.md`

- [ ] **Step 3: Verify index.html is under 50KB**

Run: `wc -c index.html`

- [ ] **Step 4: Verify docs are 800-1200 lines**

Run: `wc -l docs/README.md`

- [ ] **Step 5: Open landing page in browser**

Run: `open index.html`

Verify: hero, code block, features, why, quick start, footer all render correctly.

- [ ] **Step 6: Test responsiveness**

Resize browser window to ~375px width. Verify feature grid stacks to single column and text remains readable.
