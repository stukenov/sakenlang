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

### Common Patterns

**Summing values:**

```
var nums = [10, 20, 30, 40, 50]
var i = 0
var sum = 0

while i < len(nums) {
    sum = sum + nums[i]
    i = i + 1
}

print(sum)    // 150
```

**Finding a maximum:**

```
var scores = [85, 92, 78, 95, 88]
var i = 1
var best = scores[0]

while i < len(scores) {
    if scores[i] > best {
        best = scores[i]
    }
    i = i + 1
}

print(best)    // 95
```

**Counting matches:**

```
var ages = [18, 21, 16, 25, 17]
var i = 0
var adults = 0

while i < len(ages) {
    if ages[i] > 17 {
        adults = adults + 1
    }
    i = i + 1
}

print(adults)    // 3
```

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

### Functions as Values

Functions are first-class values in sakenlang. You can pass them as arguments:

```
func apply(f, x) {
    return f(x)
}

let double = func(n) {
    return n * 2
}

let negate = func(n) {
    return 0 - n
}

print(apply(double, 5))     // 10
print(apply(negate, 3))     // -3
```

### Recursion

Functions can call themselves:

```
func factorial(n) {
    if n < 2 {
        return 1
    }
    return n * factorial(n - 1)
}

print(factorial(5))    // 120
```

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

| Function                        | Description                |
|---------------------------------|----------------------------|
| `route(method, path, handler)`  | Register a route           |
| `serve(port)`                   | Start the HTTP server      |
| `param(name)`                   | Get a query/body parameter |
| `header(name)`                  | Get an HTTP header         |
| `status(code)`                  | Set response status code   |

### Returning HTML

Handlers return strings. Use HTML to build rich responses:

```
route("GET", "/", func() {
    return "<html><body>"
         + "<h1>sakenlang web</h1>"
         + "<p>Привет, мир!</p>"
         + "<a href='/hello?name=Студент'>Say hello</a>"
         + "</body></html>"
})

route("GET", "/hello", func() {
    let name = param("name")
    return "<html><body>"
         + "<h1>Привет, " + name + "!</h1>"
         + "<a href='/'>Back</a>"
         + "</body></html>"
})

serve(3000)
```

### Multiple Routes Example

A more complete application with several endpoints:

```
route("GET", "/", func() {
    return "<h1>Home</h1><ul>"
         + "<li><a href='/about'>About</a></li>"
         + "<li><a href='/contact'>Contact</a></li>"
         + "</ul>"
})

route("GET", "/about", func() {
    return "<h1>About</h1><p>Built with sakenlang.</p>"
})

route("GET", "/contact", func() {
    return "<h1>Contact</h1><p>email@example.com</p>"
})

serve(3000)
```

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

| Function                   | Description                    |
|----------------------------|--------------------------------|
| `model(name, schema)`     | Define a database model        |
| `field(name, type)`       | Add a field to a model         |
| `migrate()`               | Create/update database tables  |
| `create(model, data)`     | Insert a new record            |
| `all(model)`              | Get all records                |
| `find(model, id)`         | Find a record by ID            |
| `where(model, condition)` | Query records with a condition |
| `update(model, id, data)` | Update a record                |
| `delete(model, id)`       | Delete a record                |
| `count(model)`            | Count records                  |
| `save(model, data)`       | Insert or update a record      |
| `record(key, val, ...)`   | Create a data record           |
| `get(record, key)`        | Get a field from a record      |
| `set(record, key, value)` | Set a field in a record        |
| `keys(record)`            | Get all keys from a record     |
| `query(sql)`              | Run raw SQL query              |
| `run_query(sql)`          | Run raw SQL command            |

### Updating and Deleting

```
// Update a student's grade
update("student", 1, record("grade", 95))

// Delete a student
delete("student", 2)

// Count remaining students
print(count("student"))
```

### Raw SQL

For advanced queries, use `query()` and `run_query()`:

```
// Read query — returns rows
var results = query("SELECT name FROM student WHERE grade > 80")

// Write query — modifies data
run_query("UPDATE student SET grade = grade + 5 WHERE grade < 60")
```

### Complete Database Example

A full program that creates a model, inserts data, and queries it:

```
model("course", func() {
    field("title", "text")
    field("credits", "integer")
    field("instructor", "text")
})

migrate()

create("course", record("title", "Алгоритмы", "credits", 3, "instructor", "Проф. Касымов"))
create("course", record("title", "Базы данных", "credits", 4, "instructor", "Проф. Ахметова"))
create("course", record("title", "Веб-разработка", "credits", 3, "instructor", "Проф. Нурланов"))

var courses = all("course")
var i = 0
while i < len(courses) {
    let c = courses[i]
    print(get(c, "title") + " — " + to_string(get(c, "credits")) + " кредитов")
    i = i + 1
}

var total = count("course")
print("Всего курсов: " + to_string(total))
```

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
    ├── dashboard.sl       # dashboard HTML
    ├── products.sl        # product list HTML
    └── orders.sl          # order list HTML
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

| Operator | Type        | Description                     |
|----------|-------------|---------------------------------|
| `+`      | Arithmetic  | Addition / string concatenation |
| `-`      | Arithmetic  | Subtraction                     |
| `*`      | Arithmetic  | Multiplication                  |
| `/`      | Arithmetic  | Integer division                |
| `==`     | Comparison  | Equal                           |
| `!=`     | Comparison  | Not equal                       |
| `<`      | Comparison  | Less than                       |
| `>`      | Comparison  | Greater than                    |
| `&&`     | Logical     | AND                             |
| `\|\|`   | Logical     | OR                              |
| `!`      | Logical     | NOT                             |
| `=`      | Assignment  | Assign value                    |

### Built-in Functions

| Function              | Description                            |
|-----------------------|----------------------------------------|
| `print(value)`        | Output a value to the console          |
| `len(array)`          | Get the length of an array             |
| `push(array, value)`  | Add an element to the end of an array  |
| `to_string(value)`    | Convert a value to a string            |
| `to_int(string)`      | Convert a string to an integer         |
| `record(k, v, ...)`   | Create a key-value data record         |
| `get(record, key)`    | Get a field from a record              |
| `set(record, k, v)`   | Set a field in a record                |
| `keys(record)`        | Get all keys from a record             |

### HTTP Functions

| Function                        | Description                |
|---------------------------------|----------------------------|
| `route(method, path, handler)`  | Register a route           |
| `serve(port)`                   | Start the HTTP server      |
| `param(name)`                   | Get a query/body parameter |
| `header(name)`                  | Get an HTTP header         |
| `status(code)`                  | Set response status code   |
| `render(template, data)`        | Render a view template     |
| `redirect(url)`                 | Redirect to another URL    |
| `page(title, body)`             | Wrap content in HTML page  |
| `view(name, data)`              | Load a view with data      |

### Database Functions

| Function                   | Description                    |
|----------------------------|--------------------------------|
| `model(name, schema)`     | Define a database model        |
| `field(name, type)`       | Add a field to a model         |
| `migrate()`               | Create/update database tables  |
| `create(model, data)`     | Insert a new record            |
| `all(model)`              | Get all records                |
| `find(model, id)`         | Find a record by ID            |
| `where(model, condition)` | Query with a condition         |
| `update(model, id, data)` | Update a record                |
| `delete(model, id)`       | Delete a record                |
| `count(model)`            | Count records                  |
| `save(model, data)`       | Insert or update               |
| `query(sql)`              | Run raw SQL query              |
| `run_query(sql)`          | Run raw SQL command            |

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
