#lang racket
(provide evaluate eval-stmt)
(require "http-server.rkt"
         "db.rkt"
         "controller.rkt"
         "gui.rkt")

(struct env-entry (value mutable?) #:transparent)
(struct return-val (v) #:transparent)
(struct func-entry (params body closure-env) #:transparent)

(define (evaluate ast)
  (define env (make-hash))
  (for ([stmt ast])
    (eval-stmt stmt env)))

(define (eval-stmt stmt env)
  (match stmt
    [`(let-decl ,name ,expr ,line)
     (when (hash-has-key? env name)
       (error 'eval "Ошибка (строка ~a): переменная '~a' уже объявлена" line name))
     (hash-set! env name (env-entry (eval-expr expr env) #f))]

    [`(var-decl ,name ,expr ,line)
     (when (hash-has-key? env name)
       (error 'eval "Ошибка (строка ~a): переменная '~a' уже объявлена" line name))
     (hash-set! env name (env-entry (eval-expr expr env) #t))]

    [`(assign ,name ,expr ,line)
     (unless (hash-has-key? env name)
       (error 'eval "Ошибка (строка ~a): переменная '~a' не найдена" line name))
     (define entry (hash-ref env name))
     (unless (env-entry-mutable? entry)
       (error 'eval "Ошибка (строка ~a): нельзя изменить let-переменную '~a'" line name))
     (hash-set! env name (env-entry (eval-expr expr env) #t))]

    [`(print-stmt ,expr ,line)
     (define val (eval-expr expr env))
     (displayln (format-value val))]

    [`(if-stmt ,cond-expr ,then-block ,else-block ,line)
     (define val (eval-expr cond-expr env))
     (unless (boolean? val)
       (error 'eval "Ошибка (строка ~a): условие if должно быть Bool" line))
     (if val
         (for ([s then-block]) (eval-stmt s env))
         (for ([s else-block]) (eval-stmt s env)))]

    [`(while-stmt ,cond-expr ,body ,line)
     (let loop ()
       (define val (eval-expr cond-expr env))
       (unless (boolean? val)
         (error 'eval "Ошибка (строка ~a): условие while должно быть Bool" line))
       (when val
         (for ([s body]) (eval-stmt s env))
         (loop)))]

    [`(func-decl ,name ,params ,body ,line)
     (hash-set! env name (env-entry (func-entry params body env) #f))]

    [`(return-stmt ,expr ,line)
     (raise (return-val (eval-expr expr env)))]

    [`(dot-assign ,name ,field ,val-expr ,line)
     (unless (hash-has-key? env name)
       (error 'eval "Ошибка (строка ~a): переменная '~a' не найдена" line name))
     (define entry (hash-ref env name))
     (unless (env-entry-mutable? entry)
       (error 'eval "Ошибка (строка ~a): нельзя изменить let-переменную '~a'" line name))
     (define obj (env-entry-value entry))
     (hash-set! obj field (eval-expr val-expr env))]

    [`(index-assign ,name ,idx-expr ,val-expr ,line)
     (unless (hash-has-key? env name)
       (error 'eval "Ошибка (строка ~a): переменная '~a' не найдена" line name))
     (define entry (hash-ref env name))
     (unless (env-entry-mutable? entry)
       (error 'eval "Ошибка (строка ~a): нельзя изменить let-переменную '~a'" line name))
     (define arr (env-entry-value entry))
     (define idx (eval-expr idx-expr env))
     (define val (eval-expr val-expr env))
     (vector-set! arr idx val)]

    [`(expr ,e ,line) (eval-expr e env)]

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
     (define op-s (symbol->string op))
     (cond
       [(string=? op-s "+") (if (and (string? l) (string? r))
                                (string-append l r)
                                (+ l r))]
       [(string=? op-s "-") (- l r)]
       [(string=? op-s "*") (* l r)]
       [(string=? op-s "/") (when (zero? r) (error 'eval "Ошибка: деление на ноль"))
                            (quotient l r)]
       [(string=? op-s "==") (equal? l r)]
       [(string=? op-s "!=") (not (equal? l r))]
       [(string=? op-s "<") (< l r)]
       [(string=? op-s ">") (> l r)]
       [(string=? op-s "&&") (and l r)]
       [(string=? op-s "||") (or l r)]
       [else (error 'eval "Ошибка: неизвестный оператор ~a" op)])]

    [`(unop ,op ,operand)
     (define val (eval-expr operand env))
     (case op
       [(!) (not val)]
       [(-) (- val)]
       [else (error 'eval "Ошибка: неизвестный оператор ~a" op)])]

    [`(func-expr ,params ,body)
     (func-entry params body env)]

    [`(array-lit ,elems)
     (list->vector (map (lambda (e) (eval-expr e env)) elems))]

    [`(dot-access ,base-expr ,field)
     (define obj (eval-expr base-expr env))
     (cond
       [(hash? obj) (hash-ref obj field (lambda () (error 'eval "Ошибка: поле '~a' не найдено" field)))]
       [else (error 'eval "Ошибка: dot-access только для записей")])]

    [`(index ,base-expr ,idx-expr)
     (define base (eval-expr base-expr env))
     (define idx (eval-expr idx-expr env))
     (vector-ref base idx)]

    [`(call ,name ,args)
     (cond
       [(string=? name "len")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (define v (car arg-vals))
        (cond [(vector? v) (vector-length v)]
              [(string? v) (string-length v)]
              [(list? v) (length v)]
              [else (error 'eval "Ошибка: len() не поддерживает этот тип")])]
       [(string=? name "record")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (define h (make-hash))
        (let loop ([vals arg-vals])
          (when (>= (length vals) 2)
            (hash-set! h (car vals) (cadr vals))
            (loop (cddr vals))))
        h]
       [(string=? name "set")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (define obj (list-ref arg-vals 0))
        (define key (list-ref arg-vals 1))
        (define val (list-ref arg-vals 2))
        (hash-set! obj key val)
        obj]
       [(string=? name "get")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (hash-ref (car arg-vals) (cadr arg-vals) "")]
       [(string=? name "keys")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (list->vector (hash-keys (car arg-vals)))]
       [(string=? name "push")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (define arr (car arg-vals))
        (define val (cadr arg-vals))
        (define new-arr (vector-append arr (vector val)))
        new-arr]
       [(string=? name "to_string")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (format-value (car arg-vals))]
       [(string=? name "to_int")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (define v (car arg-vals))
        (cond [(number? v) v]
              [(string? v) (or (string->number v) 0)]
              [else 0])]
       ;; --- DB/Model builtins ---
       [(string=? name "model")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (define model-name (car arg-vals))
        (define fields (vector->list (cadr arg-vals)))
        (register-model model-name fields)
        (void)]
       [(string=? name "field")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (car arg-vals)]
       [(string=? name "migrate")
        (db-init)
        (run-migrate)
        (void)]
       [(string=? name "find")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (define result (db-find (car arg-vals) (cadr arg-vals)))
        (or result (make-hash))]
       [(string=? name "all")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (list->vector (db-all (car arg-vals)))]
       [(string=? name "where")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (list->vector (apply db-where arg-vals))]
       [(string=? name "create")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (define model-name (car arg-vals))
        (define data-pairs (cdr arg-vals))
        (define data (make-hash))
        ;; accept either a hash or key-value pairs
        (cond
          [(and (= (length data-pairs) 1) (hash? (car data-pairs)))
           (for ([(k v) (in-hash (car data-pairs))])
             (unless (string=? k "__model")
               (hash-set! data k v)))]
          [else
           (let loop ([ps data-pairs])
             (when (>= (length ps) 2)
               (hash-set! data (car ps) (cadr ps))
               (loop (cddr ps))))])
        ;; Run before_save hooks
        (run-hooks (format "~a:before_save" model-name) data)
        ;; Run validation
        (run-validation model-name data)
        (define result (db-create model-name data))
        ;; Run after_save hooks
        (run-hooks (format "~a:after_save" model-name) result)
        result]
       [(string=? name "update")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (db-update (list-ref arg-vals 0) (list-ref arg-vals 1)
                   (list-ref arg-vals 2) (list-ref arg-vals 3))
        (void)]
       [(string=? name "delete")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (db-delete (car arg-vals) (cadr arg-vals))
        (void)]
       [(string=? name "save")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (db-save (car arg-vals))
        (void)]
       [(string=? name "count")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (db-count (car arg-vals))]
       [(string=? name "query")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (register-query (list-ref arg-vals 0) (list-ref arg-vals 1) (list-ref arg-vals 2))
        (void)]
       [(string=? name "run_query")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (list->vector (apply run-query arg-vals))]
       [(string=? name "on")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (define event-key (car arg-vals))
        (define handler-func (cadr arg-vals))
        (register-hook event-key
          (lambda (record)
            (define call-env (make-hash))
            (for ([(k v) (in-hash env)])
              (hash-set! call-env k v))
            (hash-set! call-env (car (func-entry-params handler-func))
                       (env-entry record #t))
            (with-handlers ([return-val? (lambda (r) (return-val-v r))])
              (for ([s (func-entry-body handler-func)])
                (eval-stmt s call-env))
              (void))))
        (void)]
       [(string=? name "validate")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (define model-name (car arg-vals))
        (define handler-func (cadr arg-vals))
        (register-validation model-name
          (lambda (record)
            (define call-env (make-hash))
            (for ([(k v) (in-hash env)])
              (hash-set! call-env k v))
            (hash-set! call-env (car (func-entry-params handler-func))
                       (env-entry record #t))
            (with-handlers ([return-val? (lambda (r) (return-val-v r))])
              (for ([s (func-entry-body handler-func)])
                (eval-stmt s call-env))
              (void))))
        (void)]
       [(string=? name "error")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (error 'sakenlang "~a" (car arg-vals))]
       ;; --- Controller builtins ---
       [(string=? name "crud")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (define model-name (car arg-vals))
        (register-crud model-name #f)
        (void)]
       [(string=? name "action")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (define model-name (car arg-vals))
        (define action-name (cadr arg-vals))
        (define handler-func (caddr arg-vals))
        (register-action model-name action-name handler-func)
        (void)]
       [(string=? name "render")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (define view-name (car arg-vals))
        (define data (if (>= (length arg-vals) 2) (cadr arg-vals) (make-hash)))
        (define view-func (get-view view-name))
        (unless view-func
          (error 'eval "Ошибка: view '~a' не найден" view-name))
        ;; Call the view function with data
        (define call-env (make-hash))
        (for ([(k v) (in-hash env)])
          (hash-set! call-env k v))
        (hash-set! call-env (car (func-entry-params view-func))
                   (env-entry data #f))
        (with-handlers ([return-val? (lambda (r) (return-val-v r))])
          (for ([s (func-entry-body view-func)])
            (eval-stmt s call-env))
          (void))]
       [(string=? name "redirect")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (do-redirect (car arg-vals))]
       ;; --- GUI builtins ---
       [(string=? name "view")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (define view-name (car arg-vals))
        (define handler-func (cadr arg-vals))
        (register-view view-name handler-func)
        (void)]
       [(string=? name "page")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (define title (car arg-vals))
        (define body (cadr arg-vals))
        (define nav-links
          (if (>= (length arg-vals) 3)
              (let ([links (caddr arg-vals)])
                (if (vector? links)
                    (for/list ([l (in-vector links)])
                      (if (hash? l)
                          (cons (hash-ref l "label" "") (hash-ref l "url" ""))
                          (cons (format "~a" l) "/")))
                    '()))
              '()))
        (gui-page title body nav-links)]
       [(string=? name "table")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (define data (car arg-vals))
        (define columns (vector->list (cadr arg-vals)))
        (define model-name (if (>= (length arg-vals) 3) (caddr arg-vals) #f))
        (gui-table data columns model-name)]
       [(string=? name "form")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (define action-url (car arg-vals))
        (define fields (vector->list (cadr arg-vals)))
        (define submit-label (if (>= (length arg-vals) 3) (caddr arg-vals) "Save"))
        (gui-form action-url fields "POST" submit-label)]
       [(string=? name "card")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (define title (car arg-vals))
        (define body (cadr arg-vals))
        (gui-card title body)]
       [(string=? name "stat")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (gui-stat (car arg-vals) (cadr arg-vals))]
       [(string=? name "row")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (gui-row (car arg-vals))]
       [(string=? name "button")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (define label (car arg-vals))
        (define action-url (cadr arg-vals))
        (define style (if (>= (length arg-vals) 3) (caddr arg-vals) "primary"))
        (gui-button label action-url style)]
       [(string=? name "input")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (define iname (car arg-vals))
        (define ilabel (cadr arg-vals))
        (define itype (if (>= (length arg-vals) 3) (caddr arg-vals) "text"))
        (gui-input iname ilabel itype)]
       [(string=? name "select")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (define sname (car arg-vals))
        (define slabel (cadr arg-vals))
        (define options (caddr arg-vals))
        (define display-field (if (>= (length arg-vals) 4) (list-ref arg-vals 3) "name"))
        (gui-select sname slabel options display-field)]
       [(string=? name "detail")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (gui-detail (car arg-vals) (cadr arg-vals))]
       [(string=? name "section")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (gui-section (car arg-vals) (cadr arg-vals))]
       [(string=? name "breadcrumb")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (define items (vector->list (car arg-vals)))
        (gui-breadcrumb items)]
       [(string=? name "text")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (gui-text (car arg-vals))]
       [(string=? name "link")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (gui-link (car arg-vals) (cadr arg-vals))]
       [(string=? name "concat")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (string-join (map (lambda (v) (if (string? v) v (format-value v))) arg-vals) "")]
       [(string=? name "route")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (define method (list-ref arg-vals 0))
        (define path (list-ref arg-vals 1))
        (define handler (list-ref arg-vals 2))
        (add-route method path handler)
        (void)]
       [(string=? name "serve")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (define port (car arg-vals))
        (start-server port
          (lambda (handler)
            (define call-env (make-hash))
            (for ([(k v) (in-hash env)])
              (hash-set! call-env k v))
            (with-handlers ([return-val? (lambda (r) (return-val-v r))])
              (for ([s (func-entry-body handler)])
                (eval-stmt s call-env))
              (void))))]
       [(string=? name "param")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (define param-name (car arg-vals))
        (hash-ref (current-request-params) param-name "")]
       [(string=? name "header")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (define header-name (string-downcase (car arg-vals)))
        (hash-ref (current-request-headers) header-name "")]
       [(string=? name "status")
        (define arg-vals (map (lambda (a) (eval-expr a env)) args))
        (set-response-status! (car arg-vals))
        (void)]
       [else
     (define func-val
       (cond
         [(hash-has-key? env name) (env-entry-value (hash-ref env name))]
         [else (error 'eval "Ошибка: функция '~a' не найдена" name)]))
     (unless (func-entry? func-val)
       (error 'eval "Ошибка: '~a' не является функцией" name))
     (define param-names (func-entry-params func-val))
     (define arg-vals (map (lambda (a) (eval-expr a env)) args))
     (define call-env (make-hash))
     (for ([(k v) (in-hash env)])
       (hash-set! call-env k v))
     (for ([p param-names] [v arg-vals])
       (hash-set! call-env p (env-entry v #f)))
     (with-handlers ([return-val? (lambda (r) (return-val-v r))])
       (for ([s (func-entry-body func-val)])
         (eval-stmt s call-env))
       (void))])]

    [_ (error 'eval "Ошибка: неизвестное выражение ~a" expr)]))

(define (format-value v)
  (cond
    [(boolean? v) (if v "true" "false")]
    [(number? v) (number->string v)]
    [(string? v) v]
    [(vector? v)
     (string-append "["
       (string-join (for/list ([e (in-vector v)]) (format-value e)) ", ")
       "]")]
    [(hash? v)
     (string-append "{"
       (string-join (for/list ([(k val) (in-hash v)])
                      (format "~a: ~a" k (format-value val))) ", ")
       "}")]
    [(list? v)
     (string-append "["
       (string-join (for/list ([e v]) (format-value e)) ", ")
       "]")]
    [else (~a v)]))
