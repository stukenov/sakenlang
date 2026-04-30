#lang racket
(provide gui-page gui-table gui-form gui-card gui-stat gui-row
         gui-button gui-input gui-select gui-detail gui-section
         gui-breadcrumb gui-text gui-link gui-nav apple-css)

(define apple-css "
* { margin: 0; padding: 0; box-sizing: border-box; }
body { font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Segoe UI', system-ui, sans-serif;
       background: #f5f5f7; color: #1d1d1f; line-height: 1.5; }
.container { max-width: 1200px; margin: 0 auto; padding: 24px; }
nav { background: rgba(255,255,255,0.72); backdrop-filter: saturate(180%) blur(20px);
      border-bottom: 1px solid rgba(0,0,0,0.1); padding: 12px 24px; position: sticky; top: 0; z-index: 100; }
nav .nav-inner { max-width: 1200px; margin: 0 auto; display: flex; align-items: center; gap: 24px; }
nav a { text-decoration: none; color: #1d1d1f; font-size: 14px; font-weight: 500; }
nav a:hover { color: #007aff; }
nav .brand { font-size: 18px; font-weight: 600; }
.card { background: #fff; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.08);
        padding: 24px; margin-bottom: 20px; }
.row { display: flex; gap: 20px; flex-wrap: wrap; }
.row > * { flex: 1; min-width: 200px; }
.stat { text-align: center; padding: 24px; }
.stat .number { font-size: 48px; font-weight: 700; color: #007aff; }
.stat .label { font-size: 14px; color: #86868b; margin-top: 4px; }
table { width: 100%; border-collapse: collapse; }
th { text-align: left; padding: 12px 16px; font-size: 12px; font-weight: 600;
     text-transform: uppercase; letter-spacing: 0.5px; color: #86868b; border-bottom: 1px solid #e5e5e7; }
td { padding: 12px 16px; border-bottom: 1px solid #f0f0f2; font-size: 14px; }
tr:hover td { background: #fafafa; }
.section { margin-bottom: 32px; }
.section-title { font-size: 22px; font-weight: 600; margin-bottom: 16px; }
form { display: flex; flex-direction: column; gap: 16px; }
label { font-size: 13px; font-weight: 500; color: #86868b; margin-bottom: 4px; display: block; }
input, select, textarea { width: 100%; padding: 10px 14px; border: 1px solid #d2d2d7;
       border-radius: 8px; font-size: 15px; font-family: inherit; background: #fff;
       transition: border-color 0.2s; }
input:focus, select:focus { outline: none; border-color: #007aff; box-shadow: 0 0 0 3px rgba(0,122,255,0.1); }
.btn { display: inline-block; padding: 10px 20px; border-radius: 8px; font-size: 14px;
       font-weight: 500; text-decoration: none; cursor: pointer; border: none; font-family: inherit;
       transition: all 0.2s; }
.btn-primary { background: #007aff; color: #fff; }
.btn-primary:hover { background: #0056cc; }
.btn-danger { background: #ff3b30; color: #fff; }
.btn-danger:hover { background: #cc2f26; }
.btn-secondary { background: #e5e5ea; color: #1d1d1f; }
.btn-secondary:hover { background: #d1d1d6; }
.breadcrumb { display: flex; gap: 8px; align-items: center; margin-bottom: 20px; font-size: 14px; color: #86868b; }
.breadcrumb a { color: #007aff; text-decoration: none; }
.breadcrumb span::before { content: '/'; margin-right: 8px; color: #d2d2d7; }
.detail-row { display: flex; padding: 12px 0; border-bottom: 1px solid #f0f0f2; }
.detail-label { font-weight: 500; color: #86868b; width: 200px; flex-shrink: 0; font-size: 14px; }
.detail-value { font-size: 14px; }
h1 { font-size: 32px; font-weight: 700; margin-bottom: 8px; }
h2 { font-size: 22px; font-weight: 600; margin-bottom: 16px; }
.form-row { display: flex; gap: 16px; }
.form-row > * { flex: 1; }
.actions { display: flex; gap: 8px; margin-top: 8px; }
")

(define (esc s)
  (define str (if (string? s) s (format "~a" s)))
  (regexp-replace* #rx"&" (regexp-replace* #rx"<" (regexp-replace* #rx">" str "&gt;") "&lt;") "&amp;"))

(define (gui-nav links)
  (string-append
   "<nav><div class=\"nav-inner\">"
   "<a class=\"brand\" href=\"/\">sakenlang ERP</a>"
   (string-join (for/list ([l links])
                  (format "<a href=\"~a\">~a</a>" (cdr l) (car l))) "")
   "</div></nav>"))

(define (gui-page title body-html [nav-links '()])
  (string-append
   "<!DOCTYPE html><html><head><meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width,initial-scale=1\">"
   "<title>" (esc title) "</title>"
   "<style>" apple-css "</style></head><body>"
   (if (null? nav-links) "" (gui-nav nav-links))
   "<div class=\"container\">"
   "<h1 style=\"margin-bottom:24px\">" (esc title) "</h1>"
   body-html
   "</div></body></html>"))

(define (gui-table data columns [model-name #f])
  (define items (if (vector? data) (vector->list data) (if (list? data) data '())))
  (string-append
   "<div class=\"card\"><table><thead><tr>"
   (string-join (for/list ([c columns]) (format "<th>~a</th>" (esc c))) "")
   (if model-name "<th>Actions</th>" "")
   "</tr></thead><tbody>"
   (string-join
    (for/list ([item items])
      (string-append "<tr>"
        (string-join (for/list ([c columns])
                       (format "<td>~a</td>" (esc (format "~a" (hash-ref item c ""))))) "")
        (if model-name
            (format "<td class=\"actions\"><a class=\"btn btn-secondary\" href=\"/~a/~a\">View</a> <form method=\"POST\" action=\"/~a/~a/delete\" style=\"display:inline\"><button class=\"btn btn-danger\">Delete</button></form></td>"
                    model-name (hash-ref item "id" "")
                    model-name (hash-ref item "id" ""))
            "")
        "</tr>"))
    "")
   "</tbody></table></div>"))

(define (gui-form action fields [method "POST"] [submit-label "Save"])
  (string-append
   "<div class=\"card\"><form method=\"" method "\" action=\"" action "\">"
   (string-join
    (for/list ([f fields])
      (cond
        [(and (list? f) (>= (length f) 2))
         (define fname (car f))
         (define ftype (cadr f))
         (define flabel (if (>= (length f) 3) (caddr f) fname))
         (format "<div><label>~a</label><input type=\"~a\" name=\"~a\" placeholder=\"~a\"></div>"
                 (esc flabel) ftype (esc fname) (esc flabel))]
        [else (format "<div><label>~a</label><input type=\"text\" name=\"~a\"></div>"
                      (esc f) (esc f))]))
    "")
   "<div><button type=\"submit\" class=\"btn btn-primary\">" (esc submit-label) "</button></div>"
   "</form></div>"))

(define (gui-card title body-html)
  (string-append
   "<div class=\"card\">"
   (if (string=? title "") "" (format "<h2>~a</h2>" (esc title)))
   body-html
   "</div>"))

(define (gui-stat number label)
  (format "<div class=\"card stat\"><div class=\"number\">~a</div><div class=\"label\">~a</div></div>"
          (esc (format "~a" number)) (esc label)))

(define (gui-row children-html)
  (string-append "<div class=\"row\">" children-html "</div>"))

(define (gui-button label action [style "primary"])
  (format "<a class=\"btn btn-~a\" href=\"~a\">~a</a>" style action (esc label)))

(define (gui-input name label [type "text"])
  (format "<div><label>~a</label><input type=\"~a\" name=\"~a\"></div>"
          (esc label) type (esc name)))

(define (gui-select name label options [display-field "name"])
  (define items (if (vector? options) (vector->list options) options))
  (string-append
   "<div><label>" (esc label) "</label><select name=\"" (esc name) "\">"
   (string-join
    (for/list ([opt items])
      (if (hash? opt)
          (format "<option value=\"~a\">~a</option>"
                  (hash-ref opt "id" "") (hash-ref opt display-field ""))
          (format "<option value=\"~a\">~a</option>" opt opt)))
    "")
   "</select></div>"))

(define (gui-detail label-or-record value-or-fields)
  (cond
    [(hash? label-or-record)
     (define record label-or-record)
     (define fields (if (vector? value-or-fields) (vector->list value-or-fields) value-or-fields))
     (string-append "<div class=\"card\">"
       (string-join
        (for/list ([f fields])
          (format "<div class=\"detail-row\"><div class=\"detail-label\">~a</div><div class=\"detail-value\">~a</div></div>"
                  (esc f) (esc (format "~a" (hash-ref record f "")))))
        "")
       "</div>")]
    [else
     (format "<div class=\"detail-row\"><div class=\"detail-label\">~a</div><div class=\"detail-value\">~a</div></div>"
             (esc (format "~a" label-or-record)) (esc (format "~a" value-or-fields)))]))

(define (gui-section title body-html)
  (string-append
   "<div class=\"section\">"
   "<div class=\"section-title\">" (esc title) "</div>"
   body-html
   "</div>"))

(define (gui-breadcrumb items)
  (define elems
    (for/list ([item items])
      (cond
        [(hash? item)
         (format "<a href=\"~a\">~a</a>"
                 (hash-ref item "url" "#")
                 (esc (hash-ref item "label" "")))]
        [(pair? item)
         (format "<a href=\"~a\">~a</a>" (cdr item) (esc (car item)))]
        [else (format "<span>~a</span>" (esc (format "~a" item)))])))
  (string-append "<div class=\"breadcrumb\">" (string-join elems "") "</div>"))

(define (gui-text str)
  (format "<p>~a</p>" (esc str)))

(define (gui-link label url)
  (format "<a href=\"~a\" style=\"color:#007aff;text-decoration:none\">~a</a>" url (esc label)))
