#lang racket
(provide register-crud register-action
         controller-routes
         view-registry register-view get-view
         do-render do-redirect)

(require "db.rkt" "http-server.rkt")

;; --- View registry ---
(define view-registry (make-hash))

(define (register-view name handler)
  (hash-set! view-registry name handler))

(define (get-view name)
  (hash-ref view-registry name #f))

;; --- Render / Redirect ---
(define (do-render view-name data call-handler)
  (define view-func (get-view view-name))
  (unless view-func
    (error 'controller "Ошибка: view '~a' не найден" view-name))
  (call-handler view-func data))

(define (do-redirect path)
  (format "<html><head><meta http-equiv=\"refresh\" content=\"0;url=~a\"></head></html>" path))

;; --- Controller routes ---
;; Returns a list of (method path handler-func) to be registered
(define controller-routes (make-hash))

(define (add-controller-route method path handler)
  (hash-set! controller-routes (string-append method " " path) handler))

(define (register-crud model-name eval-handler-fn)
  ;; eval-handler-fn: (lambda (func-entry data-hash) -> string)
  ;; We store route specs; the evaluator will wire them into the HTTP server
  (define plural model-name)

  ;; GET /models — list all
  (add-controller-route "GET" (format "/~a" plural)
    (lambda (params)
      (define items (db-all model-name))
      (values "list" items)))

  ;; GET /models/:id — show one
  (add-controller-route "GET" (format "/~a/:id" plural)
    (lambda (params)
      (define id (string->number (hash-ref params "id" "0")))
      (define item (db-find model-name (or id 0)))
      (values "show" item)))

  ;; POST /models — create
  (add-controller-route "POST" (format "/~a" plural)
    (lambda (params)
      (define data (make-hash))
      (for ([(k v) (in-hash params)])
        (unless (string=? k "id")
          (hash-set! data k v)))
      (define item (db-create model-name data))
      (values "redirect" (format "/~a" plural))))

  ;; POST /models/:id/update — update
  (add-controller-route "POST" (format "/~a/:id/update" plural)
    (lambda (params)
      (define id (string->number (hash-ref params "id" "0")))
      (define fields (get-model-fields model-name))
      (for ([f fields])
        (define fname (car (string-split f ":")))
        (when (hash-has-key? params fname)
          (db-update model-name id fname (hash-ref params fname))))
      (values "redirect" (format "/~a/~a" plural id))))

  ;; POST /models/:id/delete — delete
  (add-controller-route "POST" (format "/~a/:id/delete" plural)
    (lambda (params)
      (define id (string->number (hash-ref params "id" "0")))
      (db-delete model-name id)
      (values "redirect" (format "/~a" plural)))))

(define action-registry (make-hash))

(define (register-action model-name action-name handler)
  (hash-set! action-registry (format "~a:~a" model-name action-name) handler)
  (add-controller-route "POST" (format "/~a/:id/~a" model-name action-name)
    (lambda (params)
      (define id (string->number (hash-ref params "id" "0")))
      (define item (db-find model-name (or id 0)))
      (values "action" (list handler item params)))))
