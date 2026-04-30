#lang racket
(provide parse)

(define (parse tokens)
  (define toks (list->vector tokens))
  (define pos 0)
  (define current-line 1)

  (define (peek)
    (if (< pos (vector-length toks)) (vector-ref toks pos) #f))

  (define (advance!)
    (define tok (peek))
    (when tok (set! current-line (last tok)))
    (set! pos (add1 pos))
    tok)

  (define (expect tag)
    (define tok (peek))
    (unless (and tok (eq? (car tok) tag))
      (error 'parse "Ошибка (строка ~a): ожидался ~a, получен ~a" current-line tag tok))
    (advance!))

  (define (match-tok . tags)
    (define tok (peek))
    (and tok (memq (car tok) tags) (advance!)))

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
    (unless tok (error 'parse "Ошибка (строка ~a): неожиданный конец ввода" current-line))
    (case (car tok)
      [(NUMBER) (advance!) `(num ,(cadr tok))]
      [(STRING) (advance!) `(str ,(cadr tok))]
      [(TRUE) (advance!) '(bool #t)]
      [(FALSE) (advance!) '(bool #f)]
      [(LBRACKET)
       (advance!) ;; consume [
       (define elems
         (if (and (peek) (eq? (car (peek)) 'RBRACKET))
             '()
             (let loop ([es (list (parse-expr))])
               (if (match-tok 'COMMA)
                   (loop (append es (list (parse-expr))))
                   es))))
       (expect 'RBRACKET)
       `(array-lit ,elems)]
      [(FUNC)
       (advance!) ;; consume FUNC
       (expect 'LPAREN)
       (define params (parse-params))
       (expect 'RPAREN)
       (define body (parse-block))
       `(func-expr ,params ,body)]
      [(IDENT)
       (define id-tok (advance!))
       (define base
         (if (and (peek) (eq? (car (peek)) 'LPAREN))
             (let ()
               (advance!) ;; consume LPAREN
               (define args (parse-args))
               (expect 'RPAREN)
               `(call ,(cadr id-tok) ,args))
             `(ident ,(cadr id-tok))))
       (define with-index
         (if (and (peek) (eq? (car (peek)) 'LBRACKET))
             (let ()
               (advance!) ;; consume [
               (define idx (parse-expr))
               (expect 'RBRACKET)
               `(index ,base ,idx))
             base))
       ;; dot-access chain
       (let dot-loop ([result with-index])
         (if (and (peek) (eq? (car (peek)) 'DOT))
             (let ()
               (advance!) ;; consume DOT
               (define field-tok (expect 'IDENT))
               (dot-loop `(dot-access ,result ,(cadr field-tok))))
             result))]
      [(LPAREN)
       (advance!)
       (define e (parse-expr))
       (expect 'RPAREN)
       e]
      [else (error 'parse "Ошибка (строка ~a): неожиданный токен ~a" current-line tok)]))

  (define (parse-stmt)
    (define tok (peek))
    (unless tok (error 'parse "Ошибка (строка ~a): неожиданный конец ввода" current-line))
    (case (car tok)
      [(LET) (parse-let)]
      [(VAR) (parse-var)]
      [(IF) (parse-if)]
      [(WHILE) (parse-while)]
      [(PRINT) (parse-print)]
      [(FUNC) (parse-func)]
      [(RETURN) (parse-return)]
      [(IDENT)
       (define id-tok (advance!))
       (cond
         [(and (peek) (eq? (car (peek)) 'LBRACKET))
          (let ()
            (advance!) ;; consume [
            (define idx (parse-expr))
            (expect 'RBRACKET)
            (expect 'ASSIGN)
            (define val (parse-expr))
            `(index-assign ,(cadr id-tok) ,idx ,val ,current-line))]
         [(and (peek) (eq? (car (peek)) 'DOT))
          (advance!) ;; consume DOT
          (define field-tok (expect 'IDENT))
          (expect 'ASSIGN)
          (define val (parse-expr))
          `(dot-assign ,(cadr id-tok) ,(cadr field-tok) ,val ,current-line)]
         [(match-tok 'ASSIGN)
          `(assign ,(cadr id-tok) ,(parse-expr) ,current-line)]
         [(and (peek) (eq? (car (peek)) 'LPAREN))
          (advance!) ;; consume LPAREN
          (let ([args (parse-args)])
            (expect 'RPAREN)
            `(expr (call ,(cadr id-tok) ,args) ,current-line))]
         [else
          (set! pos (sub1 pos))
          `(expr ,(parse-expr) ,current-line)])]
      [else `(expr ,(parse-expr) ,current-line)]))

  (define (parse-let)
    (define line current-line)
    (advance!)
    (define id (expect 'IDENT))
    (expect 'ASSIGN)
    (define val (parse-expr))
    `(let-decl ,(cadr id) ,val ,line))

  (define (parse-var)
    (define line current-line)
    (advance!)
    (define id (expect 'IDENT))
    (expect 'ASSIGN)
    (define val (parse-expr))
    `(var-decl ,(cadr id) ,val ,line))

  (define (parse-if)
    (define line current-line)
    (advance!)
    (define cond-expr (parse-expr))
    (define then-block (parse-block))
    (define else-block
      (if (match-tok 'ELSE)
          (parse-block)
          '()))
    `(if-stmt ,cond-expr ,then-block ,else-block ,line))

  (define (parse-while)
    (define line current-line)
    (advance!)
    (define cond-expr (parse-expr))
    (define body (parse-block))
    `(while-stmt ,cond-expr ,body ,line))

  (define (parse-print)
    (define line current-line)
    (advance!)
    (expect 'LPAREN)
    (define val (parse-expr))
    (expect 'RPAREN)
    `(print-stmt ,val ,line))

  (define (parse-block)
    (expect 'LBRACE)
    (let loop ([stmts '()])
      (define tok (peek))
      (if (and tok (eq? (car tok) 'RBRACE))
          (begin (advance!) (reverse stmts))
          (loop (cons (parse-stmt) stmts)))))

  (define (parse-func)
    (define line current-line)
    (advance!) ;; FUNC
    (define name (expect 'IDENT))
    (expect 'LPAREN)
    (define params (parse-params))
    (expect 'RPAREN)
    (define body (parse-block))
    `(func-decl ,(cadr name) ,params ,body ,line))

  (define (parse-params)
    (if (and (peek) (eq? (car (peek)) 'RPAREN))
        '()
        (let loop ([params (list (cadr (expect 'IDENT)))])
          (if (match-tok 'COMMA)
              (loop (append params (list (cadr (expect 'IDENT)))))
              params))))

  (define (parse-return)
    (define line current-line)
    (advance!) ;; RETURN
    `(return-stmt ,(parse-expr) ,line))

  (define (parse-args)
    (if (and (peek) (eq? (car (peek)) 'RPAREN))
        '()
        (let loop ([args (list (parse-expr))])
          (if (match-tok 'COMMA)
              (loop (append args (list (parse-expr))))
              args))))

  (let loop ([stmts '()])
    (if (peek)
        (loop (cons (parse-stmt) stmts))
        (reverse stmts))))
