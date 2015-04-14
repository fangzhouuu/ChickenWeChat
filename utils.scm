(use miscmacros json s11n)
(use srfi-69) ;;hash-table
(use dissector trace)

;; resposne writer
;; (define r (mk-res-buffer)) => void
;; (r "abc" "def") => void
;; (r) => "abcdef"
(define make-res-buffer
  (lambda ()
    (let ([res ""])
      (lambda arg
        (if (null? arg)
            res
            (set! res (apply string-append res arg)))))))

;; time
(define current-unix-time
  (lambda ()
    (substr (->string (current-seconds)) 0 -2)))

;; logging
(define log
  (lambda (fmt . rest)
    (with-output-to-port (current-output-port)
      (lambda ()
        (printf "- ~A~n- Log -> " (seconds->string (current-seconds)))
        (apply printf fmt rest)
        (printf " <-~n")))))

(define log-fatal
  (lambda (fmt . rest)
    (with-output-to-port (current-error-port)
      (lambda ()
        (printf "- ~A~n- FATAL -> " (seconds->string (current-seconds)))
        (apply printf fmt rest)
        (printf " <-~n")))))

;; inspect the value of an object, and return it
;; (inspect '(1 2 3)) => '(1 2 3) ; and print out "(1 2 3)"
;; (inspect 'list '(1 2 3)) => '(1 2 3) ; and print out: "list: (1 2 3)"
(define-syntax inspect
  (syntax-rules ()
    [(_ obj)
     (begin (log "Inspecting... : ~A" obj)
            obj)]
    [(_ name obj)
     (begin (log "inspecting ~A: ~A" name obj)
            obj)]))

;; string utils
;;
(define substr
  (lambda (obj start end)
    (let* ([len   (string-length obj)]
           [start (modulo start len)]
           [end   (modulo end len)])
      (substring obj start end))))

;; aliasing some useful stuff
;; (nif (eq? 1 1) "false" (display "true") "true") => (print "true)"true"
(define-syntax-rule (nif test false-body true-body ...)
  (if test (begin true-body ...) false-body))

(define-syntax begin1
  (syntax-rules ()
    [(_ br b1 ...)
     (begin b1 ... br)]))

(define-syntax-rule (sha1sum<-string obj) (string->sha1sum obj))
(define-syntax-rule (string<-seconds sec) (seconds->string sec))

(define-syntax-rule (string<-symbol obj) (symbol->string obj))
(define-syntax-rule (symbol<-string obj) (string->symbol obj))
(define-syntax-rule (alist<-hash-table obj) (hash-table->alist obj))

(define-syntax-rule (vector<-list obj) (list->vector obj))
(define-syntax-rule (list<-vector obj) (vector->list obj))

;; json
(define-syntax-rule (string<-json obj) (with-output-to-string (lambda () (json-write obj))))
(define-syntax-rule (json<-string obj) (with-input-from-string obj (lambda () (json-read))))

;; works with 'json' egg's json scheme representation
(define sxml<-json
  (lambda (json)
    (cond
     [(null? json) '()]
     [(or (number? json) (string? json)) json]
     ;; for { ..., "xxx" : [ <json>, <json> ], ...}
     [(and (pair? json) (not (dotted-list? json)) (list? (cdr json)))
      (append (list (symbol<-string (car json))) (map sxml<-json (cdr json)))]
     ;; for { ..., "xxx" : <json>, ...}
     [(pair? json)
      (cond
       [(vector? (cdr json)) ;; json obj
        (list (symbol<-string (car json)) (sxml<-json (cdr json)))]
       [(and (not (vector? json)) (dotted-list? json)) ;; json key value pair
        (list (symbol<-string (car json)) (cdr json))]
       [else (dissect json) '()])]
     ;; for <json>
     [(vector? json)
      (cons 'O (map sxml<-json (list<-vector json)))]
     [else (dissect json) '()])))


;; groups stuff
(define-syntax-rule (when-superuser? user action ...)
  (if (superuser? user)
      (begin action ...)
      (log-fatal "FATAL: Super User Auth Failed~n User ~A, Action ~A"
                 user
                 (with-output-to-string (lambda ()
                                          (write '(action ...)))))))

(define make-hasheq
  (lambda ()
    (make-hash-table test: eq?)))

(define alist<-hasheq
  (lambda (h)
    (alist<-hash-table h)))

(define hasheq<-alist
  (lambda (h)
    (alist->hash-table h test: eq?)))
