# sakenlang Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Создать учебный микро-DSL с Swift-подобным синтаксисом на Racket.

**Architecture:** Три модуля — lexer (токенизация), parser (AST), evaluator (выполнение). Точка входа `run.rkt` читает файл `.saken` и прогоняет через пайплайн.

**Tech Stack:** Racket, rackunit (тесты)

---

### Task 1: Project scaffold

**Files:**
- Create: `info.rkt`
- Create: `run.rkt`
- Create: `lexer.rkt`
- Create: `parser.rkt`
- Create: `evaluator.rkt`
- Create: `tests/lexer-test.rkt`
- Create: `tests/parser-test.rkt`
- Create: `tests/evaluator-test.rkt`
- Create: `examples/hello.saken`

**Step 1: Create Racket package info**

```racket
;; info.rkt
#lang info
(define collection "sakenlang")
(define deps '("base"))
(define build-deps '("rackunit-lib"))
```

**Step 2: Create stub files**

`lexer.rkt`:
```racket
#lang racket
(provide tokenize)
(define (tokenize src) '())
```

`parser.rkt`:
```racket
#lang racket
(provide parse)
(define (parse tokens) '())
```

`evaluator.rkt`:
```racket
#lang racket
(provide evaluate)
(define (evaluate ast) (void))
```

`run.rkt`:
```racket
#lang racket
(require "lexer.rkt" "parser.rkt" "evaluator.rkt")
(define (run-file path)
  (define src (file->string path))
  (define tokens (tokenize src))
  (define ast (parse tokens))
  (evaluate ast))
(command-line
 #:args (filename)
 (run-file filename))
```

`examples/hello.saken`:
```
print(42)
```

**Step 3: Create test stubs**

`tests/lexer-test.rkt`:
```racket
#lang racket
(require rackunit "../lexer.rkt")
```

`tests/parser-test.rkt`:
```racket
#lang racket
(require rackunit "../parser.rkt")
```

`tests/evaluator-test.rkt`:
```racket
#lang racket
(require rackunit "../evaluator.rkt")
```

**Step 4: Commit**

```bash
git add -A
git commit -m "chore: project scaffold"
```

---

### Task 2: Lexer — numbers, strings, bools, identifiers, keywords

**Files:**
- Modify: `lexer.rkt`
- Modify: `tests/lexer-test.rkt`

**Step 1: Write failing tests**

```racket
;; tests/lexer-test.rkt
#lang racket
(require rackunit "../lexer.rkt")

;; Числа
(check-equal? (tokenize "42")
              '((NUMBER 42)))

;; Строки
(check-equal? (tokenize "\"hello\"")
              '((STRING "hello")))

;; Bool
(check-equal? (tokenize "true false")
              '((TRUE) (FALSE)))

;; Ключевые слова
(check-equal? (tokenize "let var if else print")
              '((LET) (VAR) (IF) (ELSE) (PRINT)))

;; Идентификаторы
(check-equal? (tokenize "my_var")
              '((IDENT "my_var")))

;; Операторы и скобки
(check-equal? (tokenize "= + - * / ( ) { }")
              '((ASSIGN) (PLUS) (MINUS) (STAR) (SLASH)
                (LPAREN) (RPAREN) (LBRACE) (RBRACE)))

;; Операторы сравнения и логики
(check-equal? (tokenize "== != < > && || !")
              '((EQ) (NEQ) (LT) (GT) (AND) (OR) (NOT)))

;; Полное выражение
(check-equal? (tokenize "let x = 10")
              '((LET) (IDENT "x") (ASSIGN) (NUMBER 10)))
```

**Step 2: Run tests — verify FAIL**

```bash
racket tests/lexer-test.rkt
```
Expected: FAIL (tokenize returns `'()`)

**Step 3: Implement lexer**

```racket
#lang racket
(provide tokenize)

(define keywords
  (hash "let" '(LET) "var" '(VAR) "if" '(IF) "else" '(ELSE)
        "print" '(PRINT) "true" '(TRUE) "false" '(FALSE)))

(define (tokenize src)
  (define chars (string->list src))
  (define len (length chars))

  (let loop ([pos 0] [tokens '()])
    (if (>= pos len)
        (reverse tokens)
        (let ([ch (list-ref chars pos)])
          (cond
            ;; Пробелы и переводы строк
            [(char-whitespace? ch)
             (loop (add1 pos) tokens)]

            ;; Строки
            [(char=? ch #\")
             (define-values (str end) (read-string-literal chars (add1 pos) len))
             (loop end (cons `(STRING ,str) tokens))]

            ;; Числа
            [(char-numeric? ch)
             (define-values (num end) (read-number chars pos len))
             (loop end (cons `(NUMBER ,num) tokens))]

            ;; Идентификаторы и ключевые слова
            [(or (char-alphabetic? ch) (char=? ch #\_))
             (define-values (name end) (read-ident chars pos len))
             (define tok (hash-ref keywords name #f))
             (if tok
                 (loop end (cons tok tokens))
                 (loop end (cons `(IDENT ,name) tokens)))]

            ;; Двухсимвольные операторы
            [(and (< (add1 pos) len)
                  (two-char-op? ch (list-ref chars (add1 pos))))
             => (lambda (tok) (loop (+ pos 2) (cons tok tokens)))]

            ;; Односимвольные операторы
            [(one-char-op ch)
             => (lambda (tok) (loop (add1 pos) (cons tok tokens)))]

            [else
             (error 'tokenize "Ошибка: неизвестный символ '~a' на позиции ~a" ch pos)])))))

(define (two-char-op? c1 c2)
  (define s (string c1 c2))
  (cond
    [(string=? s "==") '(EQ)]
    [(string=? s "!=") '(NEQ)]
    [(string=? s "&&") '(AND)]
    [(string=? s "||") '(OR)]
    [else #f]))

(define (one-char-op ch)
  (case ch
    [(#\=) '(ASSIGN)]
    [(#\+) '(PLUS)]
    [(#\-) '(MINUS)]
    [(#\*) '(STAR)]
    [(#\/) '(SLASH)]
    [(#\() '(LPAREN)]
    [(#\)) '(RPAREN)]
    [(#\{) '(LBRACE)]
    [(#\}) '(RBRACE)]
    [(#\<) '(LT)]
    [(#\>) '(GT)]
    [(#\!) '(NOT)]
    [else #f]))

(define (read-string-literal chars pos len)
  (let loop ([p pos] [acc '()])
    (cond
      [(>= p len) (error 'tokenize "Ошибка: незакрытая строка")]
      [(char=? (list-ref chars p) #\")
       (values (list->string (reverse acc)) (add1 p))]
      [else (loop (add1 p) (cons (list-ref chars p) acc))])))

(define (read-number chars pos len)
  (let loop ([p pos] [acc '()])
    (if (and (< p len) (char-numeric? (list-ref chars p)))
        (loop (add1 p) (cons (list-ref chars p) acc))
        (values (string->number (list->string (reverse acc))) p))))

(define (read-ident chars pos len)
  (let loop ([p pos] [acc '()])
    (if (and (< p len)
             (let ([c (list-ref chars p)])
               (or (char-alphabetic? c) (char-numeric? c) (char=? c #\_))))
        (loop (add1 p) (cons (list-ref chars p) acc))
        (values (list->string (reverse acc)) p))))
```

**Step 4: Run tests — verify PASS**

```bash
racket tests/lexer-test.rkt
```

**Step 5: Commit**

```bash
git add lexer.rkt tests/lexer-test.rkt
git commit -m "feat: implement lexer"
```

---

### Task 3: Parser — expressions

**Files:**
- Modify: `parser.rkt`
- Modify: `tests/parser-test.rkt`

**Step 1: Write failing tests**

```racket
;; tests/parser-test.rkt
#lang racket
(require rackunit "../parser.rkt" "../lexer.rkt")

;; Число
(check-equal? (parse (tokenize "42"))
              '((expr (num 42))))

;; Строка
(check-equal? (parse (tokenize "\"hi\""))
              '((expr (str "hi"))))

;; Bool
(check-equal? (parse (tokenize "true"))
              '((expr (bool #t))))

;; Переменная
(check-equal? (parse (tokenize "x"))
              '((expr (ident "x"))))

;; Арифметика
(check-equal? (parse (tokenize "1 + 2"))
              '((expr (binop + (num 1) (num 2)))))

;; Сравнение
(check-equal? (parse (tokenize "x == 10"))
              '((expr (binop == (ident "x") (num 10)))))

;; Конкатенация строк
(check-equal? (parse (tokenize "\"a\" + \"b\""))
              '((expr (binop + (str "a") (str "b")))))

;; Скобки
(check-equal? (parse (tokenize "(1 + 2) * 3"))
              '((expr (binop * (binop + (num 1) (num 2)) (num 3)))))

;; Отрицание
(check-equal? (parse (tokenize "!true"))
              '((expr (unop ! (bool #t)))))
```

**Step 2: Run tests — verify FAIL**

```bash
racket tests/parser-test.rkt
```

**Step 3: Implement parser**

Parser использует recursive descent с приоритетами операторов:
- `||` (lowest)
- `&&`
- `== !=`
- `< >`
- `+ -`
- `* /`
- `! -` (unary, highest)

```racket
#lang racket
(provide parse)

(define (parse tokens)
  (define toks (list->vector tokens))
  (define pos 0)

  (define (peek)
    (if (< pos (vector-length toks)) (vector-ref toks pos) #f))

  (define (advance!)
    (define tok (peek))
    (set! pos (add1 pos))
    tok)

  (define (expect tag)
    (define tok (peek))
    (unless (and tok (eq? (car tok) tag))
      (error 'parse "Ошибка: ожидался ~a, получен ~a" tag tok))
    (advance!))

  (define (match-tok . tags)
    (define tok (peek))
    (and tok (memq (car tok) tags) (advance!)))

  ;; Expression parsing with precedence climbing

  (define (parse-expr) (parse-or))

  (define (parse-or)
    (let loop ([left (parse-and)])
      (if (match-tok 'OR)
          (loop `(binop \|\| ,left ,(parse-and)))
          left)))

  (define (parse-and)
    (let loop ([left (parse-equality)])
      (if (match-tok 'AND)
          (loop `(binop && ,left ,(parse-equality)))
          left)))

  (define (parse-equality)
    (let loop ([left (parse-comparison)])
      (define tok (match-tok 'EQ 'NEQ))
      (if tok
          (let ([op (if (eq? (car tok) 'EQ) '== '!=)])
            (loop `(binop ,op ,left ,(parse-comparison))))
          left)))

  (define (parse-comparison)
    (let loop ([left (parse-add)])
      (define tok (match-tok 'LT 'GT))
      (if tok
          (let ([op (if (eq? (car tok) 'LT) '< '>)])
            (loop `(binop ,op ,left ,(parse-add))))
          left)))

  (define (parse-add)
    (let loop ([left (parse-mul)])
      (define tok (match-tok 'PLUS 'MINUS))
      (if tok
          (let ([op (if (eq? (car tok) 'PLUS) '+ '-)])
            (loop `(binop ,op ,left ,(parse-mul))))
          left)))

  (define (parse-mul)
    (let loop ([left (parse-unary)])
      (define tok (match-tok 'STAR 'SLASH))
      (if tok
          (let ([op (if (eq? (car tok) 'STAR) '* '/)])
            (loop `(binop ,op ,left ,(parse-unary))))
          left)))

  (define (parse-unary)
    (cond
      [(match-tok 'NOT) `(unop ! ,(parse-unary))]
      [(match-tok 'MINUS) `(unop - ,(parse-unary))]
      [else (parse-primary)]))

  (define (parse-primary)
    (define tok (peek))
    (unless tok (error 'parse "Ошибка: неожиданный конец ввода"))
    (case (car tok)
      [(NUMBER) (advance!) `(num ,(cadr tok))]
      [(STRING) (advance!) `(str ,(cadr tok))]
      [(TRUE) (advance!) '(bool #t)]
      [(FALSE) (advance!) '(bool #f)]
      [(IDENT) (advance!) `(ident ,(cadr tok))]
      [(LPAREN)
       (advance!)
       (define e (parse-expr))
       (expect 'RPAREN)
       e]
      [else (error 'parse "Ошибка: неожиданный токен ~a" tok)]))

  ;; Statement parsing

  (define (parse-stmt)
    (define tok (peek))
    (unless tok (error 'parse "Ошибка: неожиданный конец ввода"))
    (case (car tok)
      [(LET) (parse-let)]
      [(VAR) (parse-var)]
      [(IF) (parse-if)]
      [(PRINT) (parse-print)]
      [(IDENT)
       ;; Assignment: ident = expr
       (define id-tok (advance!))
       (if (match-tok 'ASSIGN)
           `(assign ,(cadr id-tok) ,(parse-expr))
           ;; Bare expression starting with ident
           (begin
             (set! pos (sub1 pos)) ;; put ident back
             `(expr ,(parse-expr))))]
      [else `(expr ,(parse-expr))]))

  (define (parse-let)
    (advance!) ;; consume LET
    (define id (expect 'IDENT))
    (expect 'ASSIGN)
    (define val (parse-expr))
    `(let-decl ,(cadr id) ,val))

  (define (parse-var)
    (advance!) ;; consume VAR
    (define id (expect 'IDENT))
    (expect 'ASSIGN)
    (define val (parse-expr))
    `(var-decl ,(cadr id) ,val))

  (define (parse-if)
    (advance!) ;; consume IF
    (define cond-expr (parse-expr))
    (define then-block (parse-block))
    (define else-block
      (if (match-tok 'ELSE)
          (parse-block)
          '()))
    `(if-stmt ,cond-expr ,then-block ,else-block))

  (define (parse-print)
    (advance!) ;; consume PRINT
    (expect 'LPAREN)
    (define val (parse-expr))
    (expect 'RPAREN)
    `(print-stmt ,val))

  (define (parse-block)
    (expect 'LBRACE)
    (let loop ([stmts '()])
      (define tok (peek))
      (if (and tok (eq? (car tok) 'RBRACE))
          (begin (advance!) (reverse stmts))
          (loop (cons (parse-stmt) stmts)))))

  ;; Parse program
  (let loop ([stmts '()])
    (if (peek)
        (loop (cons (parse-stmt) stmts))
        (reverse stmts))))
```

**Step 4: Run tests — verify PASS**

```bash
racket tests/parser-test.rkt
```

**Step 5: Commit**

```bash
git add parser.rkt tests/parser-test.rkt
git commit -m "feat: implement parser"
```

---

### Task 4: Evaluator

**Files:**
- Modify: `evaluator.rkt`
- Modify: `tests/evaluator-test.rkt`

**Step 1: Write failing tests**

```racket
;; tests/evaluator-test.rkt
#lang racket
(require rackunit "../evaluator.rkt" "../parser.rkt" "../lexer.rkt")

(define (run src)
  (evaluate (parse (tokenize src))))

(define (run-capture src)
  (with-output-to-string (lambda () (run src))))

;; Арифметика
(check-equal? (run-capture "print(1 + 2)") "3\n")
(check-equal? (run-capture "print(10 - 3)") "7\n")
(check-equal? (run-capture "print(4 * 5)") "20\n")
(check-equal? (run-capture "print(10 / 2)") "5\n")

;; Строки
(check-equal? (run-capture "print(\"hello\")") "hello\n")
(check-equal? (run-capture "print(\"a\" + \"b\")") "ab\n")

;; Bool
(check-equal? (run-capture "print(true)") "true\n")
(check-equal? (run-capture "print(!false)") "true\n")

;; Переменные
(check-equal? (run-capture "let x = 5\nprint(x)") "5\n")
(check-equal? (run-capture "var x = 1\nx = 2\nprint(x)") "2\n")

;; let нельзя менять
(check-exn exn:fail?
  (lambda () (run "let x = 1\nx = 2")))

;; if/else
(check-equal? (run-capture "if true {\nprint(1)\n} else {\nprint(2)\n}") "1\n")
(check-equal? (run-capture "if false {\nprint(1)\n} else {\nprint(2)\n}") "2\n")

;; Сравнения
(check-equal? (run-capture "print(1 == 1)") "true\n")
(check-equal? (run-capture "print(1 != 2)") "true\n")
(check-equal? (run-capture "print(3 > 2)") "true\n")
(check-equal? (run-capture "print(1 < 2)") "true\n")

;; Логические
(check-equal? (run-capture "print(true && false)") "false\n")
(check-equal? (run-capture "print(true || false)") "true\n")
```

**Step 2: Run tests — verify FAIL**

```bash
racket tests/evaluator-test.rkt
```

**Step 3: Implement evaluator**

```racket
#lang racket
(provide evaluate)

(struct env-entry (value mutable?) #:transparent)

(define (evaluate ast)
  (define env (make-hash))
  (for ([stmt ast])
    (eval-stmt stmt env)))

(define (eval-stmt stmt env)
  (match stmt
    [`(let-decl ,name ,expr)
     (when (hash-has-key? env name)
       (error 'eval "Ошибка: переменная '~a' уже объявлена" name))
     (hash-set! env name (env-entry (eval-expr expr env) #f))]

    [`(var-decl ,name ,expr)
     (when (hash-has-key? env name)
       (error 'eval "Ошибка: переменная '~a' уже объявлена" name))
     (hash-set! env name (env-entry (eval-expr expr env) #t))]

    [`(assign ,name ,expr)
     (unless (hash-has-key? env name)
       (error 'eval "Ошибка: переменная '~a' не найдена" name))
     (define entry (hash-ref env name))
     (unless (env-entry-mutable? entry)
       (error 'eval "Ошибка: нельзя изменить let-переменную '~a'" name))
     (hash-set! env name (env-entry (eval-expr expr env) #t))]

    [`(print-stmt ,expr)
     (define val (eval-expr expr env))
     (displayln (format-value val))]

    [`(if-stmt ,cond-expr ,then-block ,else-block)
     (define val (eval-expr cond-expr env))
     (unless (boolean? val)
       (error 'eval "Ошибка: условие if должно быть Bool"))
     (if val
         (for ([s then-block]) (eval-stmt s env))
         (for ([s else-block]) (eval-stmt s env)))]

    [`(expr ,e) (eval-expr e env)]

    [_ (error 'eval "Ошибка: неизвестная инструкция ~a" stmt)]))

(define (eval-expr expr env)
  (match expr
    [`(num ,n) n]
    [`(str ,s) s]
    [`(bool ,b) b]
    [`(ident ,name)
     (unless (hash-has-key? env name)
       (error 'eval "Ошибка: переменная '~a' не найдена" name))
     (env-entry-value (hash-ref env name))]

    [`(binop ,op ,left ,right)
     (define l (eval-expr left env))
     (define r (eval-expr right env))
     (case op
       [(+) (if (and (string? l) (string? r))
                (string-append l r)
                (+ l r))]
       [(-) (- l r)]
       [(*) (* l r)]
       [(/) (when (zero? r) (error 'eval "Ошибка: деление на ноль"))
            (quotient l r)]
       [(==) (equal? l r)]
       [(!=) (not (equal? l r))]
       [(<) (< l r)]
       [(>) (> l r)]
       [(&&) (and l r)]
       [(\|\|) (or l r)]
       [else (error 'eval "Ошибка: неизвестный оператор ~a" op)])]

    [`(unop ,op ,operand)
     (define val (eval-expr operand env))
     (case op
       [(!) (not val)]
       [(-) (- val)]
       [else (error 'eval "Ошибка: неизвестный оператор ~a" op)])]

    [_ (error 'eval "Ошибка: неизвестное выражение ~a" expr)]))

(define (format-value v)
  (cond
    [(boolean? v) (if v "true" "false")]
    [(number? v) (number->string v)]
    [(string? v) v]
    [else (~a v)]))
```

**Step 4: Run tests — verify PASS**

```bash
racket tests/evaluator-test.rkt
```

**Step 5: Commit**

```bash
git add evaluator.rkt tests/evaluator-test.rkt
git commit -m "feat: implement evaluator"
```

---

### Task 5: Integration — run.rkt + example

**Files:**
- Modify: `run.rkt`
- Modify: `examples/hello.saken`

**Step 1: Update example**

```
let name = "Сакен"
var age = 15
var is_student = true

if is_student {
    print("Привет, " + name)
    age = age + 1
} else {
    print("Пока")
}

print(age)
```

**Step 2: Run integration test**

```bash
racket run.rkt examples/hello.saken
```

Expected output:
```
Привет, Сакен
16
```

**Step 3: Commit**

```bash
git add run.rkt examples/hello.saken
git commit -m "feat: working sakenlang with example"
```
