# sakenlang v2 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add comments, while loops, functions, arrays, REPL, line numbers in errors, and VS Code syntax highlighting to sakenlang.

**Architecture:** Extend existing lexer/parser/evaluator pipeline. Lexer gets new tokens (WHILE, FUNC, RETURN, LBRACKET, RBRACKET, COMMA, COMMENT skip). Parser gets new AST nodes. Evaluator gets new statement/expression handlers. REPL is a new mode in run.rkt. VS Code extension is a separate folder.

**Tech Stack:** Racket, rackunit, VS Code extension (TextMate grammar JSON)

---

### Task 1: Comments

**Files:**
- Modify: `src/lexer.rkt`
- Modify: `tests/lexer-test.rkt`

**Step 1: Write failing test**

Add to tests/lexer-test.rkt:
```racket
;; Комментарии
(check-equal? (tokenize "let x = 5 // это комментарий")
              '((LET) (IDENT "x") (ASSIGN) (NUMBER 5)))

(check-equal? (tokenize "// вся строка комментарий\nprint(1)")
              '((PRINT) (LPAREN) (NUMBER 1) (RPAREN)))
```

**Step 2: Run test — verify FAIL**

Run: `racket tests/lexer-test.rkt`

**Step 3: Implement**

In `src/lexer.rkt`, in the main `cond` of `tokenize`, add BEFORE the two-char-op check:

```racket
;; Комментарии //
[(and (char=? ch #\/) (< (add1 pos) len) (char=? (list-ref chars (add1 pos)) #\/))
 (let skip ([p pos])
   (if (or (>= p len) (char=? (list-ref chars p) #\newline))
       (loop (if (>= p len) p (add1 p)) tokens)
       (skip (add1 p))))]
```

**Step 4: Run test — verify PASS**

Run: `racket tests/lexer-test.rkt`

**Step 5: Commit**

```bash
git add src/lexer.rkt tests/lexer-test.rkt
git commit -m "feat: add // comments"
```

---

### Task 2: Line numbers in tokens + error messages

**Files:**
- Modify: `src/lexer.rkt`
- Modify: `src/parser.rkt`
- Modify: `src/evaluator.rkt`
- Modify: `tests/lexer-test.rkt`
- Modify: `tests/parser-test.rkt`
- Modify: `tests/evaluator-test.rkt`

This is a cross-cutting change. Tokens gain a line number: `(NUMBER 42 1)` instead of `(NUMBER 42)`. Single-element tokens like `(LET)` become `(LET 1)`. AST nodes don't change — errors use a current-line parameter threaded through eval.

**Step 1: Update lexer to track line numbers**

In `src/lexer.rkt`, add `line` tracking to the loop. Each token gets line appended as last element:
- `(NUMBER 42)` → `(NUMBER 42 1)`
- `(LET)` → `(LET 1)`
- `(IDENT "x")` → `(IDENT "x" 1)`

The `tokenize` function tracks a `line` counter, incrementing on `\n`.

**Step 2: Update ALL tests**

All lexer tests must include line numbers. All parser tests that use `(tokenize ...)` will get line-numbered tokens automatically. Parser must strip line numbers when reading tokens. Evaluator tests don't change (they test via full pipeline).

**Step 3: Update parser to extract line info**

Parser reads `(car tok)` for tag, `(cadr tok)` for value, `(last tok)` for line. Thread line into error messages.

**Step 4: Update evaluator error messages**

Pass line info through AST where useful (store in stmt nodes). Error messages become: `"Ошибка (строка 3): переменная 'x' не найдена"`

**Step 5: Commit**

```bash
git add src/ tests/
git commit -m "feat: line numbers in error messages"
```

---

### Task 3: while loops

**Files:**
- Modify: `src/lexer.rkt`
- Modify: `src/parser.rkt`
- Modify: `src/evaluator.rkt`
- Modify: `tests/evaluator-test.rkt`

**Step 1: Write failing test**

Add to tests/evaluator-test.rkt:
```racket
;; while цикл
(check-equal? (run-capture "var x = 0\nwhile x < 5 {\nx = x + 1\n}\nprint(x)") "5\n")

;; while с false — не выполняется
(check-equal? (run-capture "while false {\nprint(1)\n}\nprint(0)") "0\n")
```

**Step 2: Run test — verify FAIL**

**Step 3: Implement**

Lexer: add `"while"` → `'(WHILE)` to keywords hash.

Parser: add to `parse-stmt`:
```racket
[(WHILE) (parse-while)]
```

```racket
(define (parse-while)
  (advance!) ;; consume WHILE
  (define cond-expr (parse-expr))
  (define body (parse-block))
  `(while-stmt ,cond-expr ,body))
```

Evaluator: add to `eval-stmt`:
```racket
[`(while-stmt ,cond-expr ,body)
 (let loop ()
   (define val (eval-expr cond-expr env))
   (unless (boolean? val)
     (error 'eval "Ошибка: условие while должно быть Bool"))
   (when val
     (for ([s body]) (eval-stmt s env))
     (loop)))]
```

**Step 4: Run tests — verify PASS**

**Step 5: Commit**

```bash
git add src/ tests/
git commit -m "feat: add while loops"
```

---

### Task 4: Functions (func, return)

**Files:**
- Modify: `src/lexer.rkt`
- Modify: `src/parser.rkt`
- Modify: `src/evaluator.rkt`
- Modify: `tests/evaluator-test.rkt`

**Step 1: Write failing tests**

```racket
;; Функция без аргументов
(check-equal? (run-capture "func greet() {\nprint(\"hi\")\n}\ngreet()") "hi\n")

;; Функция с параметрами
(check-equal? (run-capture "func add(a, b) {\nreturn a + b\n}\nprint(add(1, 2))") "3\n")

;; Функция вызывает функцию
(check-equal? (run-capture "func double(x) {\nreturn x * 2\n}\nfunc quad(x) {\nreturn double(double(x))\n}\nprint(quad(3))") "12\n")
```

**Step 2: Run — verify FAIL**

**Step 3: Implement**

Lexer: add keywords `"func"` → `(FUNC)`, `"return"` → `(RETURN)`. Add `(COMMA)` for `#\,` in one-char-op.

Parser:
- `parse-stmt`: add `(FUNC)` → `parse-func`, `(RETURN)` → `parse-return`
- Function call: in `parse-primary`, when IDENT is followed by LPAREN, parse as call

```racket
(define (parse-func)
  (advance!) ;; FUNC
  (define name (expect 'IDENT))
  (expect 'LPAREN)
  (define params (parse-params))
  (expect 'RPAREN)
  (define body (parse-block))
  `(func-decl ,(cadr name) ,params ,body))

(define (parse-params)
  (if (and (peek) (eq? (car (peek)) 'RPAREN))
      '()
      (let loop ([params (list (cadr (expect 'IDENT)))])
        (if (match-tok 'COMMA)
            (loop (append params (list (cadr (expect 'IDENT)))))
            params))))

(define (parse-return)
  (advance!) ;; RETURN
  `(return-stmt ,(parse-expr)))
```

In `parse-primary`, change IDENT case:
```racket
[(IDENT)
 (define id-tok (advance!))
 (if (and (peek) (eq? (car (peek)) 'LPAREN))
     (begin
       (advance!) ;; consume LPAREN
       (define args (parse-args))
       (expect 'RPAREN)
       `(call ,(cadr id-tok) ,args))
     `(ident ,(cadr id-tok)))]
```

Also update `parse-stmt` IDENT case to check for function call (IDENT followed by LPAREN).

Evaluator:
- Use a `return-exn` struct to implement return: `(struct return-val (v) #:transparent)`
- `func-decl`: store `(func-entry params body env)` in env
- `call` expr: create new env with params bound, eval body, catch return-val
- `return-stmt`: raise return-val

**Step 4: Run — verify PASS**

**Step 5: Commit**

```bash
git add src/ tests/
git commit -m "feat: add functions with parameters and return"
```

---

### Task 5: Arrays

**Files:**
- Modify: `src/lexer.rkt`
- Modify: `src/parser.rkt`
- Modify: `src/evaluator.rkt`
- Modify: `tests/evaluator-test.rkt`

**Step 1: Write failing tests**

```racket
;; Литерал массива
(check-equal? (run-capture "let nums = [1, 2, 3]\nprint(nums[0])") "1\n")
(check-equal? (run-capture "let nums = [10, 20, 30]\nprint(nums[2])") "30\n")

;; Изменение элемента
(check-equal? (run-capture "var arr = [1, 2, 3]\narr[0] = 99\nprint(arr[0])") "99\n")

;; Длина (встроенная функция len)
(check-equal? (run-capture "let arr = [1, 2, 3]\nprint(len(arr))") "3\n")
```

**Step 2: Run — verify FAIL**

**Step 3: Implement**

Lexer: add `(LBRACKET)` for `#\[`, `(RBRACKET)` for `#\]` in one-char-op.

Parser:
- Array literal: `[expr, expr, ...]` → `(array-lit (e1 e2 ...))`
- Index access: `ident[expr]` → `(index ident expr)` (in parse-primary after IDENT)
- Index assignment: `ident[expr] = expr` → `(index-assign name index-expr val-expr)` (in parse-stmt)

Evaluator:
- `array-lit`: eval each element, produce a Racket vector
- `index`: vector-ref
- `index-assign`: vector-set! (only on var)
- Built-in `len`: add to call handling

**Step 4: Run — verify PASS**

**Step 5: Commit**

```bash
git add src/ tests/
git commit -m "feat: add arrays with indexing and len()"
```

---

### Task 6: REPL mode

**Files:**
- Modify: `run.rkt`

**Step 1: Implement REPL**

When `./sakenlang` is run without arguments, start REPL:

```racket
(define (repl)
  (displayln "sakenlang v2.0")
  (displayln "Введи код или 'exit' для выхода.\n")
  (define env (make-hash))
  (let loop ()
    (display ">>> ")
    (flush-output)
    (define line (read-line))
    (cond
      [(eof-object? line) (displayln "\nПока!")]
      [(string=? (string-trim line) "exit") (displayln "Пока!")]
      [(string=? (string-trim line) "") (loop)]
      [else
       (with-handlers ([exn:fail? (lambda (e) (displayln (exn-message e)))])
         (define tokens (tokenize line))
         (define ast (parse tokens))
         (for ([stmt ast]) (eval-stmt stmt env)))
       (loop)])))
```

Update command-line to handle 0 args → REPL, 1 arg → file.

**Step 2: Test manually**

```bash
echo -e "let x = 42\nprint(x)\nexit" | ./sakenlang
```

Expected:
```
sakenlang v2.0
Введи код или 'exit' для выхода.

>>> >>> 42
>>> Пока!
```

**Step 3: Rebuild and commit**

```bash
make build
git add run.rkt Makefile
git commit -m "feat: add REPL mode"
```

---

### Task 7: VS Code syntax highlighting

**Files:**
- Create: `vscode-sakenlang/package.json`
- Create: `vscode-sakenlang/syntaxes/sakenlang.tmLanguage.json`
- Create: `vscode-sakenlang/language-configuration.json`

**Step 1: Create extension**

`vscode-sakenlang/package.json`:
```json
{
  "name": "sakenlang",
  "displayName": "sakenlang",
  "description": "Syntax highlighting for sakenlang (.sl files)",
  "version": "0.1.0",
  "engines": { "vscode": "^1.75.0" },
  "categories": ["Programming Languages"],
  "contributes": {
    "languages": [{
      "id": "sakenlang",
      "aliases": ["sakenlang"],
      "extensions": [".sl"],
      "configuration": "./language-configuration.json"
    }],
    "grammars": [{
      "language": "sakenlang",
      "scopeName": "source.sakenlang",
      "path": "./syntaxes/sakenlang.tmLanguage.json"
    }]
  }
}
```

`vscode-sakenlang/language-configuration.json`:
```json
{
  "comments": { "lineComment": "//" },
  "brackets": [["{", "}"], ["(", ")"], ["[", "]"]],
  "autoClosingPairs": [
    { "open": "{", "close": "}" },
    { "open": "(", "close": ")" },
    { "open": "[", "close": "]" },
    { "open": "\"", "close": "\"" }
  ]
}
```

`vscode-sakenlang/syntaxes/sakenlang.tmLanguage.json`:
TextMate grammar with scopes for:
- `keyword.control`: if, else, while, return
- `keyword.declaration`: let, var, func
- `support.function`: print, len
- `constant.language`: true, false
- `constant.numeric`: numbers
- `string.quoted.double`: strings
- `comment.line.double-slash`: // comments
- `entity.name.function`: function names after func

**Step 2: Install locally**

```bash
ln -s $(pwd)/vscode-sakenlang ~/.vscode/extensions/sakenlang
```

**Step 3: Commit**

```bash
git add vscode-sakenlang/
git commit -m "feat: add VS Code syntax highlighting extension"
```

---

### Task 8: Examples and docs update

**Files:**
- Create: `examples/while.sl`
- Create: `examples/functions.sl`
- Create: `examples/arrays.sl`
- Modify: `docs/README.md`

**Step 1: Create new examples**

`examples/while.sl`:
```
// Считаем от 1 до 5
var i = 1
while i < 6 {
    print(i)
    i = i + 1
}
```

`examples/functions.sl`:
```
// Функция сложения
func add(a, b) {
    return a + b
}

// Функция приветствия
func greet(name) {
    print("Привет, " + name + "!")
}

greet("Алия")
print(add(10, 20))
```

`examples/arrays.sl`:
```
// Массивы
var scores = [85, 92, 78, 95, 88]
var i = 0
var total = 0

while i < len(scores) {
    total = total + scores[i]
    i = i + 1
}

print("Сумма баллов:")
print(total)
```

**Step 2: Update docs/README.md** with new sections for while, func, arrays, comments, REPL.

**Step 3: Run all examples, commit**

```bash
git add examples/ docs/
git commit -m "docs: update docs and add examples for new features"
```
