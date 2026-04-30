#lang racket
(require rackunit "../src/evaluator.rkt" "../src/parser.rkt" "../src/lexer.rkt")

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

;; let нельзя менять — проверяем номер строки в ошибке
(check-exn #rx"строка 2"
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

;; while цикл
(check-equal? (run-capture "var x = 0\nwhile x < 5 {\nx = x + 1\n}\nprint(x)") "5\n")

;; while с false — не выполняется
(check-equal? (run-capture "while false {\nprint(1)\n}\nprint(0)") "0\n")

;; Функция без аргументов
(check-equal? (run-capture "func greet() {\nprint(\"hi\")\n}\ngreet()") "hi\n")

;; Функция с параметрами и return
(check-equal? (run-capture "func add(a, b) {\nreturn a + b\n}\nprint(add(1, 2))") "3\n")

;; Функция вызывает функцию
(check-equal? (run-capture "func double(x) {\nreturn x * 2\n}\nfunc quad(x) {\nreturn double(double(x))\n}\nprint(quad(3))") "12\n")

;; Массив — литерал и индекс
(check-equal? (run-capture "let nums = [1, 2, 3]\nprint(nums[0])") "1\n")
(check-equal? (run-capture "let nums = [10, 20, 30]\nprint(nums[2])") "30\n")

;; Изменение элемента массива
(check-equal? (run-capture "var arr = [1, 2, 3]\narr[0] = 99\nprint(arr[0])") "99\n")

;; len()
(check-equal? (run-capture "let arr = [1, 2, 3]\nprint(len(arr))") "3\n")

;; Анонимная функция
(check-equal? (run-capture "let greet = func() {\nreturn \"hi\"\n}\nprint(greet())") "hi\n")

;; Анонимная функция с параметрами
(check-equal? (run-capture "let add = func(a, b) {\nreturn a + b\n}\nprint(add(3, 4))") "7\n")

;; Передача анонимной функции как аргумент
(check-equal? (run-capture "func apply(f, x) {\nreturn f(x)\n}\nprint(apply(func(n) { return n * 2 }, 5))") "10\n")
