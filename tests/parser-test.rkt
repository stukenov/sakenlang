#lang racket
(require rackunit "../src/parser.rkt" "../src/lexer.rkt")

;; Число
(check-equal? (parse (tokenize "42"))
              '((expr (num 42) 1)))

;; Строка
(check-equal? (parse (tokenize "\"hi\""))
              '((expr (str "hi") 1)))

;; Bool
(check-equal? (parse (tokenize "true"))
              '((expr (bool #t) 1)))

;; Переменная
(check-equal? (parse (tokenize "x"))
              '((expr (ident "x") 1)))

;; Арифметика
(check-equal? (parse (tokenize "1 + 2"))
              '((expr (binop + (num 1) (num 2)) 1)))

;; Сравнение
(check-equal? (parse (tokenize "x == 10"))
              '((expr (binop == (ident "x") (num 10)) 1)))

;; Конкатенация строк
(check-equal? (parse (tokenize "\"a\" + \"b\""))
              '((expr (binop + (str "a") (str "b")) 1)))

;; Скобки
(check-equal? (parse (tokenize "(1 + 2) * 3"))
              '((expr (binop * (binop + (num 1) (num 2)) (num 3)) 1)))

;; Отрицание
(check-equal? (parse (tokenize "!true"))
              '((expr (unop ! (bool #t)) 1)))
