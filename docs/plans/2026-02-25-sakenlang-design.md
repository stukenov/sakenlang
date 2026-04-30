# sakenlang — Design

Учебный микро-DSL с упрощённым Swift-синтаксисом, реализованный на Racket.

## Синтаксис

```swift
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

## Возможности

- `let x = expr` — неизменяемая переменная
- `var x = expr` — изменяемая переменная
- Типы: Int, String, Bool (`true`/`false`)
- Операторы: `+`, `-`, `*`, `/`, `==`, `!=`, `<`, `>`, `&&`, `||`, `!`
- `if expr { ... } else { ... }`
- `print(expr)`
- Переменные в snake_case

## Архитектура

Три слоя в одном Racket-пакете:

1. **Lexer** — исходник -> токены
2. **Parser** — токены -> AST
3. **Evaluator** — AST -> выполнение

Запуск: `racket run.rkt program.saken`

## Ошибки

Понятные сообщения на русском:
- `"Ошибка: переменная 'x' не найдена"`
- `"Ошибка: нельзя изменить let-переменную"`
- `"Ошибка: несовместимые типы для операции '+'"`
