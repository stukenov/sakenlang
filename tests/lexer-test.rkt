#lang racket
(require rackunit "../src/lexer.rkt")

;; Числа
(check-equal? (tokenize "42")
              '((NUMBER 42 1)))

;; Строки
(check-equal? (tokenize "\"hello\"")
              '((STRING "hello" 1)))

;; Bool
(check-equal? (tokenize "true false")
              '((TRUE 1) (FALSE 1)))

;; Ключевые слова
(check-equal? (tokenize "let var if else print")
              '((LET 1) (VAR 1) (IF 1) (ELSE 1) (PRINT 1)))

;; Идентификаторы
(check-equal? (tokenize "my_var")
              '((IDENT "my_var" 1)))

;; Операторы и скобки
(check-equal? (tokenize "= + - * / ( ) { }")
              '((ASSIGN 1) (PLUS 1) (MINUS 1) (STAR 1) (SLASH 1)
                (LPAREN 1) (RPAREN 1) (LBRACE 1) (RBRACE 1)))

;; Операторы сравнения и логики
(check-equal? (tokenize "== != < > && || !")
              '((EQ 1) (NEQ 1) (LT 1) (GT 1) (AND 1) (OR 1) (NOT 1)))

;; Полное выражение
(check-equal? (tokenize "let x = 10")
              '((LET 1) (IDENT "x" 1) (ASSIGN 1) (NUMBER 10 1)))

;; Комментарии
(check-equal? (tokenize "let x = 5 // это комментарий")
              '((LET 1) (IDENT "x" 1) (ASSIGN 1) (NUMBER 5 1)))

(check-equal? (tokenize "// вся строка комментарий\nprint(1)")
              '((PRINT 2) (LPAREN 2) (NUMBER 1 2) (RPAREN 2)))
