#lang racket
(provide start-server add-route current-request-params current-request-headers set-response-status!)
(require web-server/servlet-env
         web-server/servlet
         web-server/http/request-structs
         net/url
         racket/hash)

;; Route table: hash of "METHOD /path" -> handler-thunk-caller
(define routes (make-hash))

;; Per-request context (thread-local via parameters)
(define current-request-params (make-parameter (hash)))
(define current-request-headers (make-parameter (hash)))
(define current-response-status (make-parameter 200))

(define (add-route method path handler)
  (hash-set! routes (string-append method " " path) handler))

(define (set-response-status! code)
  (current-response-status code))

(define (find-pattern-route method path)
  (for/fold ([found-handler #f] [found-params (hash)]
             #:result (values found-handler found-params))
            ([(route-key handler) (in-hash routes)]
             #:when (not found-handler))
    (define parts (string-split route-key " " #:trim? #f))
    (define route-method (car parts))
    (define route-path (cadr parts))
    (if (and (string=? method route-method)
             (pattern-match? route-path path))
        (values handler (extract-params route-path path))
        (values #f (hash)))))

(define (pattern-match? pattern path)
  (define pat-parts (string-split pattern "/"))
  (define path-parts (string-split path "/"))
  (and (= (length pat-parts) (length path-parts))
       (for/and ([pp pat-parts] [rp path-parts])
         (or (string-prefix? pp ":") (string=? pp rp)))))

(define (extract-params pattern path)
  (define pat-parts (string-split pattern "/"))
  (define path-parts (string-split path "/"))
  (for/hash ([pp pat-parts] [rp path-parts]
             #:when (string-prefix? pp ":"))
    (values (substring pp 1) rp)))

(define (start-server port call-handler)
  (displayln (format "sakenlang server запущен на http://localhost:~a" port))
  (serve/servlet
   (lambda (req)
     (define method (bytes->string/utf-8 (request-method req)))
     (define path (url->string (request-uri req)))
     ;; Strip query string from path for matching
     (define clean-path
       (let ([qpos (regexp-match-positions #rx"\\?" path)])
         (if qpos (substring path 0 (caar qpos)) path)))
     ;; Parse query params
     (define query-params
       (let ([bindings (url-query (request-uri req))])
         (for/hash ([b bindings])
           (values (symbol->string (car b)) (or (cdr b) "")))))
     ;; Parse POST body params (application/x-www-form-urlencoded)
     (define body-params
       (with-handlers ([exn:fail? (lambda (_) (hash))])
         (define body-bindings (request-bindings/raw req))
         (for/hash ([b body-bindings]
                    #:when (binding:form? b))
           (values (bytes->string/utf-8 (binding-id b))
                   (bytes->string/utf-8 (binding:form-value b))))))
     ;; Merge params (body overrides query)
     (define all-params (hash-union query-params body-params #:combine/key (lambda (k v1 v2) v2)))
     ;; Parse headers
     (define hdrs
       (for/hash ([h (request-headers/raw req)])
         (values (string-downcase (bytes->string/utf-8 (header-field h)))
                 (bytes->string/utf-8 (header-value h)))))
     ;; Find route (exact match first, then pattern match with :params)
     (define key (string-append method " " clean-path))
     (define-values (handler route-params)
       (let ([exact (hash-ref routes key #f)])
         (if exact
             (values exact (hash))
             (find-pattern-route method clean-path))))
     (define all-params-with-route (hash-union all-params route-params #:combine/key (lambda (k v1 v2) v2)))
     (if handler
         (begin
           (parameterize ([current-request-params all-params-with-route]
                          [current-request-headers hdrs]
                          [current-response-status 200])
             (define result
               (if (procedure? handler)
                   ;; Controller route — call lambda directly
                   (let ()
                     (define-values (action data) (handler all-params-with-route))
                     (cond
                       [(string=? action "redirect")
                        (format "<html><head><meta http-equiv=\"refresh\" content=\"0;url=~a\"></head></html>" data)]
                       [else (format "~a" data)]))
                   ;; User-defined route (func-entry) — use call-handler
                   (call-handler handler)))
             (define status-code (current-response-status))
             (response/full
              status-code
              (string->bytes/utf-8 "OK")
              (current-seconds)
              #"text/html; charset=utf-8"
              '()
              (list (string->bytes/utf-8 (if (string? result) result ""))))))
         (response/full
          404 #"Not Found" (current-seconds)
          #"text/html; charset=utf-8"
          '()
          (list #"<h1>404 - Not Found</h1>"))))
   #:port port
   #:servlet-path "/"
   #:servlet-regexp #rx""
   #:launch-browser? #f
   #:listen-ip #f))
