#lang racket
(provide tokenize)

(define keywords
  (hash "let" 'LET "var" 'VAR "if" 'IF "else" 'ELSE
        "print" 'PRINT "true" 'TRUE "false" 'FALSE
        "while" 'WHILE "func" 'FUNC "return" 'RETURN))

(define (tokenize src)
  (define chars (string->list src))
  (define len (length chars))

  (let loop ([pos 0] [line 1] [tokens '()])
    (if (>= pos len)
        (reverse tokens)
        (let ([ch (list-ref chars pos)])
          (cond
            [(char=? ch #\newline)
             (loop (add1 pos) (add1 line) tokens)]

            [(char-whitespace? ch)
             (loop (add1 pos) line tokens)]

            [(char=? ch #\")
             (define-values (str end) (read-string-literal chars (add1 pos) len))
             (loop end line (cons `(STRING ,str ,line) tokens))]

            [(char-numeric? ch)
             (define-values (num end) (read-number chars pos len))
             (loop end line (cons `(NUMBER ,num ,line) tokens))]

            [(or (char-alphabetic? ch) (char=? ch #\_))
             (define-values (name end) (read-ident chars pos len))
             (define kw (hash-ref keywords name #f))
             (if kw
                 (loop end line (cons (list kw line) tokens))
                 (loop end line (cons `(IDENT ,name ,line) tokens)))]

            ;; Комментарии //
            [(and (char=? ch #\/) (< (add1 pos) len) (char=? (list-ref chars (add1 pos)) #\/))
             (let skip ([p pos])
               (if (or (>= p len) (char=? (list-ref chars p) #\newline))
                   (loop (if (>= p len) p (add1 p))
                         (if (and (< p len) (char=? (list-ref chars p) #\newline)) (add1 line) line)
                         tokens)
                   (skip (add1 p))))]

            [(and (< (add1 pos) len)
                  (two-char-op? ch (list-ref chars (add1 pos))))
             => (lambda (tok) (loop (+ pos 2) line (cons (append tok (list line)) tokens)))]

            [(one-char-op ch)
             => (lambda (tok) (loop (add1 pos) line (cons (append tok (list line)) tokens)))]

            [else
             (error 'tokenize "unknown character '~a' at position ~a" ch pos)])))))

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
    [(#\,) '(COMMA)]
    [(#\[) '(LBRACKET)]
    [(#\]) '(RBRACKET)]
    [(#\.) '(DOT)]
    [(#\:) '(COLON)]
    [else #f]))

(define (read-string-literal chars pos len)
  (let loop ([p pos] [acc '()])
    (cond
      [(>= p len) (error 'tokenize "unclosed string literal")]
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
