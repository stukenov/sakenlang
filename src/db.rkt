#lang racket
(provide db-init db-close
         register-model get-model-fields run-migrate
         db-find db-all db-where db-create db-update db-delete db-count db-save
         register-query run-query
         register-hook run-hooks
         register-validation run-validation)

(require db)

;; --- Database connection ---
(define current-db (make-parameter #f))

(define (db-init [path "app.db"])
  (current-db (sqlite3-connect #:database path #:mode 'create)))

(define (db-close)
  (when (current-db)
    (disconnect (current-db))
    (current-db #f)))

;; --- Model registry ---
;; model-name -> (listof field-spec)
;; field-spec: (list name type) e.g. ("name" "text") ("price" "integer")
(define model-registry (make-hash))

(define (register-model name fields)
  (hash-set! model-registry name fields))

(define (get-model-fields name)
  (hash-ref model-registry name '()))

(define (parse-field-spec spec)
  ;; spec is "name:type" or just "name" (defaults to text)
  (define parts (string-split spec ":"))
  (list (car parts) (if (>= (length parts) 2) (cadr parts) "text")))

;; --- Migrations ---
(define (run-migrate)
  (for ([(model-name fields) (in-hash model-registry)])
    (define parsed (map parse-field-spec fields))
    (define cols
      (string-join
       (cons "id INTEGER PRIMARY KEY AUTOINCREMENT"
             (append
              (for/list ([f parsed])
                (format "~a ~a" (car f) (string-upcase (cadr f))))
              (list "created_at TEXT DEFAULT (datetime('now'))")))
       ", "))
    (define sql (format "CREATE TABLE IF NOT EXISTS ~a (~a)" model-name cols))
    (query-exec (current-db) sql)))

;; --- CRUD ---
(define (row->hash model-name row)
  (define fields (get-model-fields model-name))
  (define parsed (map parse-field-spec fields))
  (define col-names (cons "id" (append (map car parsed) (list "created_at"))))
  (define h (make-hash))
  (hash-set! h "__model" model-name)
  (for ([name col-names] [val (vector->list row)])
    (hash-set! h name (if (sql-null? val) "" val)))
  h)

(define (db-find model-name id)
  (define rows (query-rows (current-db)
                 (format "SELECT * FROM ~a WHERE id = ?" model-name)
                 id))
  (if (null? rows)
      #f
      (row->hash model-name (car rows))))

(define (db-all model-name)
  (define rows (query-rows (current-db)
                 (format "SELECT * FROM ~a" model-name)))
  (for/list ([r rows]) (row->hash model-name r)))

(define (db-where model-name condition . params)
  (define rows (apply query-rows (current-db)
                 (format "SELECT * FROM ~a WHERE ~a" model-name condition)
                 params))
  (for/list ([r rows]) (row->hash model-name r)))

(define (db-create model-name data)
  ;; data is a hash of field->value
  (define fields (get-model-fields model-name))
  (define parsed (map parse-field-spec fields))
  (define col-names (map car parsed))
  (define present-cols (filter (lambda (c) (hash-has-key? data c)) col-names))
  (define vals (map (lambda (c) (hash-ref data c)) present-cols))
  (define placeholders (string-join (make-list (length present-cols) "?") ", "))
  (define sql (format "INSERT INTO ~a (~a) VALUES (~a)"
                model-name
                (string-join present-cols ", ")
                placeholders))
  (apply query-exec (current-db) sql vals)
  (define id (query-value (current-db) "SELECT last_insert_rowid()"))
  (db-find model-name id))

(define (db-update model-name id field value)
  (query-exec (current-db)
    (format "UPDATE ~a SET ~a = ? WHERE id = ?" model-name field)
    value id))

(define (db-delete model-name id)
  (query-exec (current-db)
    (format "DELETE FROM ~a WHERE id = ?" model-name)
    id))

(define (db-count model-name)
  (query-value (current-db)
    (format "SELECT COUNT(*) FROM ~a" model-name)))

(define (db-save record)
  ;; Save all fields from a record hash back to DB
  (define model-name (hash-ref record "__model" #f))
  (define id (hash-ref record "id" #f))
  (when (and model-name id)
    (define fields (get-model-fields model-name))
    (define parsed (map parse-field-spec fields))
    (define col-names (map car parsed))
    (for ([c col-names])
      (when (hash-has-key? record c)
        (db-update model-name id c (hash-ref record c))))))

;; --- Query registry ---
(define query-registry (make-hash))

(define (register-query name model-name condition)
  (hash-set! query-registry name (list model-name condition)))

(define (run-query name . params)
  (define entry (hash-ref query-registry name #f))
  (unless entry (error 'db "Ошибка: запрос '~a' не найден" name))
  (apply db-where (car entry) (cadr entry) params))

;; --- Hook registry ---
(define hook-registry (make-hash))

(define (register-hook key handler)
  (define existing (hash-ref hook-registry key '()))
  (hash-set! hook-registry key (append existing (list handler))))

(define (run-hooks key record)
  (define handlers (hash-ref hook-registry key '()))
  (for ([h handlers])
    (h record)))

;; --- Validation registry ---
(define validation-registry (make-hash))

(define (register-validation model-name handler)
  (hash-set! validation-registry model-name handler))

(define (run-validation model-name record)
  (define handler (hash-ref validation-registry model-name #f))
  (when handler (handler record)))
