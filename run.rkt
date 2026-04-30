#lang racket
(require "src/lexer.rkt" "src/parser.rkt" "src/evaluator.rkt"
         "src/http-server.rkt" "src/db.rkt" "src/controller.rkt" "src/gui.rkt")

(provide eval-stmt)

(define (run-file path)
  (define src (file->string path))
  (define tokens (tokenize src))
  (define ast (parse tokens))
  (evaluate ast))

(define (run-file-with-env path env)
  (define src (file->string path))
  (define tokens (tokenize src))
  (define ast (parse tokens))
  (for ([stmt ast])
    (eval-stmt stmt env)))

(define (run-project dir)
  (define env (make-hash))

  ;; Load models
  (define models-dir (build-path dir "models"))
  (when (directory-exists? models-dir)
    (for ([f (sort (directory-list models-dir) string<? #:key path->string)]
          #:when (regexp-match? #rx"\\.sl$" (path->string f)))
      (displayln (format "Loading model: ~a" f))
      (run-file-with-env (path->string (build-path models-dir f)) env)))

  ;; Run migrations after models
  (db-init (path->string (build-path dir "app.db")))
  (run-migrate)

  ;; Load controllers
  (define controllers-dir (build-path dir "controllers"))
  (when (directory-exists? controllers-dir)
    (for ([f (sort (directory-list controllers-dir) string<? #:key path->string)]
          #:when (regexp-match? #rx"\\.sl$" (path->string f)))
      (displayln (format "Loading controller: ~a" f))
      (run-file-with-env (path->string (build-path controllers-dir f)) env)))

  ;; Load views
  (define views-dir (build-path dir "views"))
  (when (directory-exists? views-dir)
    (for ([f (sort (directory-list views-dir) string<? #:key path->string)]
          #:when (regexp-match? #rx"\\.sl$" (path->string f)))
      (displayln (format "Loading view: ~a" f))
      (run-file-with-env (path->string (build-path views-dir f)) env)))

  ;; Wire controller routes into HTTP server
  (for ([(key handler) (in-hash controller-routes)])
    (define parts (string-split key " " #:trim? #f))
    (define method (car parts))
    (define path (cadr parts))
    (add-route method path handler))

  ;; Load app.sl (sets up routes, serve, etc.)
  (define app-file (build-path dir "app.sl"))
  (when (file-exists? app-file)
    (displayln "Loading app.sl")
    (run-file-with-env (path->string app-file) env)))

(define (repl)
  (displayln "sakenlang v2.0")
  (displayln "Введи код или 'exit' для выхода.")
  (newline)
  (define env (make-hash))
  (let loop ()
    (display ">>> ")
    (flush-output)
    (define line (read-line))
    (cond
      [(eof-object? line) (newline) (displayln "Пока!")]
      [(string=? (string-trim line) "exit") (displayln "Пока!")]
      [(string=? (string-trim line) "") (loop)]
      [else
       (with-handlers ([exn:fail? (lambda (e) (displayln (exn-message e)))])
         (define tokens (tokenize line))
         (define ast (parse tokens))
         (for ([stmt ast]) (eval-stmt stmt env)))
       (loop)])))

(define args (vector->list (current-command-line-arguments)))
(cond
  [(null? args) (repl)]
  [(= (length args) 1)
   (define path (car args))
   (if (directory-exists? path)
       (run-project path)
       (run-file path))]
  [else (error "Использование: sakenlang [файл.sl | директория]")])
