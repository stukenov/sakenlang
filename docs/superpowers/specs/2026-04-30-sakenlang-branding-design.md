# sakenlang — Branding & Marketing Design Spec

**Date:** 2026-04-30
**Approach:** Academic Modern
**Audience:** University/college CS students and instructors
**Language strategy:** English primary, Russian secondary

---

## 1. Visual Identity

### Color Palette — Swift Blue

| Role    | Color   | Usage                                      |
|---------|---------|---------------------------------------------|
| Primary | #0A84FF | CTAs, links, primary accents                |
| Accent  | #5E5CE6 | Gradient endpoint, secondary accents        |
| Dark    | #1C1C1E | Code blocks, dark backgrounds               |
| Light   | #F2F2F7 | Page background, cards, feature blocks      |
| White   | #FFFFFF | Text on dark, card backgrounds              |
| Text    | #333333 | Body text on light backgrounds              |
| Muted   | #888888 | Secondary text, captions                    |

**Gradient:** `linear-gradient(135deg, #0A84FF, #5E5CE6)` — used in hero, logo mark, accent bars.

### Typography

- **Headings:** Inter (web) / SF Pro Display (native). Weight 700, tight letter-spacing (-0.3px to -0.5px).
- **Body:** Inter / SF Pro Text. Weight 400, line-height 1.6.
- **Code:** JetBrains Mono or Fira Code. Used in all code examples, terminal snippets, inline code.

### Logo Concept

Lettermark "S" in white on the Swift Blue gradient, 16px border-radius square. Used as:
- Favicon (32x32)
- GitHub social preview (1280x640, centered logo + tagline on gradient)
- README badge

No complex logo — the lettermark + gradient is the identity.

---

## 2. Messaging

### Tagline

**Primary (EN):** "From hello world to web apps. One language."
**Primary (RU):** "От hello world до веб-приложений. Один язык."

### Subtitle

**EN:** "A modern teaching language with Swift-like syntax, built-in HTTP server, and error messages in Russian."
**RU:** "Современный учебный язык с синтаксисом в стиле Swift, встроенным HTTP-сервером и ошибками на русском."

### Brand Voice Rules

1. **Confident, not boastful** — state what it does, don't oversell
2. **Concrete, not abstract** — show code, not philosophy
3. **Welcoming, not dumbed down** — respect the student's intelligence
4. **Bilingual naturally** — English primary, Russian where it adds value (error examples, instructor section)

### Positioning Statement

sakenlang occupies the space between Scratch (too visual, no real syntax) and Python (too much ecosystem complexity for day-one learners). It teaches real programming concepts — variables, functions, control flow, HTTP, databases — in a single self-contained binary with no dependencies.

---

## 3. Landing Page (index.html)

### Layout: Hero-Centered

Single-page HTML file, no framework, no build step. Self-contained CSS.

### Sections (top to bottom)

**3.1 Hero**
- Gradient background (#0A84FF → #5E5CE6)
- Eyebrow: "A MODERN TEACHING LANGUAGE" (small caps, tracking)
- Title: "sakenlang" (32px, bold, white)
- Tagline: "From hello world to web apps. One language."
- Two CTAs: "Get Started" (white bg, blue text, anchors to Quick Start section) + "GitHub" (outline, white, links to repo)

**3.2 Code Example**
- Dark code block (#1C1C1E) with syntax-highlighted sakenlang code
- Filename tab: "hello.sl"
- Example: func definition + print + variable usage (6-8 lines)
- Demonstrates: Swift-like syntax, Russian strings, simplicity

**3.3 Feature Grid (2x2)**
Four cards on light background (#F2F2F7):
- **Swift-like Syntax** — "Familiar, clean syntax your students already recognize"
- **Built-in HTTP** — "Web server included. Route, serve, build web apps."
- **SQLite Built-in** — "Database operations with zero setup"
- **Russian Errors** — "Error messages in Russian with line numbers"

**3.4 Why sakenlang?**
- Heading: "Why sakenlang?"
- 3-4 sentences comparing to Python (too complex for day one), Scratch (no real syntax), JavaScript (too much toolchain)
- Tone: positioning, not attacking

**3.5 Quick Start**
- Dark terminal block
- Three commands: download, run example, open REPL
- Each with a one-line comment explaining what it does

**3.6 Footer**
- "Made in Kazakhstan" + GitHub link
- Minimal, no navigation

### Technical Requirements
- Single HTML file, no dependencies
- Responsive (mobile-first, works on phone/tablet/desktop)
- System fonts with Inter fallback (loaded from Google Fonts CDN)
- JetBrains Mono for code (Google Fonts CDN)
- Dark code blocks with manual syntax highlighting via spans
- No JavaScript required (pure CSS)
- Page weight under 50KB

---

## 4. README.md

### Language
English primary. One section ("Для преподавателей") in Russian.

### Structure

```
# sakenlang

> From hello world to web apps. One language.

Tagline RU below EN.

## Quick Example
5-6 line code block showing func + print + variables.
Output shown as comment.

## Features
4-6 bullet points, format: **Feature** — one sentence.
- Swift-like syntax
- Built-in HTTP server (route, serve, param)
- SQLite database support
- REPL interactive mode
- Error messages in Russian with line numbers
- VS Code syntax highlighting

## Get Started
Three steps:
1. Download binary
2. Run: ./sakenlang examples/hello.sl
3. REPL: ./sakenlang

## Code Examples
Three fenced code blocks with titles:
- Variables & Control Flow (if/else, while)
- Web Server (route + serve)
- Working with Data (array operations)
Each 5-8 lines max.

## Why sakenlang?
3-4 sentences. Positioning vs Python/Scratch/JS.
Not an attack — explaining the niche.

## Language Guide
Link to docs/README.md ("The sakenlang Book").
One sentence describing what's there.

## Для преподавателей
In Russian. 2-3 sentences:
- What sakenlang is for in a course context
- How to get started with it in class
- Link to examples/ directory

## Development
- make build / make clean
- Project structure (compact tree)
- How to run tests

## License
(MIT recommended — user to confirm)
```

### Formatting Rules
- No emojis in headings
- Code blocks use `sl` language tag where supported
- Keep total README under 150 lines
- First code appears within first 10 lines (visible without scrolling on GitHub)

---

## 5. Documentation — The sakenlang Book (docs/README.md)

### Format
Single markdown file. Linear reading order, simple to complex. English text, Cyrillic in code examples to demonstrate Unicode support.

### Chapters

**1. Welcome to sakenlang**
- What it is, who it's for, design philosophy
- 3-4 paragraphs max

**2. Getting Started**
- Download binary, run a file, use REPL
- First program walkthrough

**3. The Basics**
- `let` (constants) and `var` (mutable variables)
- Types: Int, String, Bool
- `print()` function
- Comments (`//`)

**4. Control Flow**
- `if` / `else`
- `while` loops
- Comparison operators: `==`, `!=`, `<`, `>`
- Logical operators: `&&`, `||`, `!`

**5. Functions**
- `func` declaration, parameters, `return`
- Calling functions
- Anonymous functions (closures): `func(x) { return x * 2 }`

**6. Collections**
- Array literals: `[1, 2, 3]`
- Indexing: `arr[0]`
- `len()` function
- Mutation: `arr[i] = value`

**7. Working with Strings**
- Concatenation with `+`
- Unicode/Cyrillic support
- String in expressions

**8. Building Web Apps**
- `route(method, path, handler)`
- `serve(port)`
- `param(name)` for query parameters
- Full example: multi-route web app

**9. Working with Data**
- SQLite integration
- Creating tables, inserting, querying
- Building a CRUD application

**10. MVC Pattern**
- Walkthrough of the ERP example
- Models, controllers, views separation
- Organizing larger projects

**11. Language Reference**
- Keywords table (all 10 keywords)
- Operators table
- Built-in functions table
- Type system summary

### Formatting Rules
- Each chapter starts with `## N. Chapter Title`
- Code examples use real sakenlang code (tested against interpreter)
- Each chapter ends with a "Try it" exercise suggestion
- Target total length: 800-1200 lines

---

## 6. Deliverables Summary

| Deliverable          | File                | Action          |
|----------------------|---------------------|-----------------|
| README               | README.md           | Complete rewrite |
| Landing page         | index.html          | New file         |
| Language Guide       | docs/README.md      | Complete rewrite |
| Brand guidelines     | (this document)     | Reference        |
| GitHub social image  | .github/social.html | New file (template) |

### Out of Scope
- Custom domain / hosting setup
- VS Code extension updates (existing extension is fine)
- Changes to the interpreter source code
- CI/CD pipeline
- Package manager / distribution beyond binary download
