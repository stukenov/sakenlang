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
