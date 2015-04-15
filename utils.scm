(use miscmacros json s11n)
(use srfi-69) ;;hash-table
(use dissector trace)

;; resposne buffer
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

;;;; logging and debugging facility
;; time
(define current-unix-time (lambda () (substr (->string (current-seconds)) 0 -2)))

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
    [(_ obj) (begin (log "Inspecting... : ~A" obj) obj)]
    [(_ name obj) (begin (log "inspecting ~A: ~A" name obj) obj)]))

;;;; string utils
;; support negtive index (substr "abc" 0 -1) => "ab"
(define substr
  (lambda (obj start end)
    (let* ([len   (string-length obj)]
           [start (modulo start len)]
           [end   (modulo end len)])
      (substring obj start end))))

;;;; misc macros
;; aliasing some useful stuff
;; (nif (eq? 1 1) "false" (display "true") "true") => (print "true)"true"
(define-syntax-rule (nif test false-body true-body ...)
  (if test (begin true-body ...) false-body))

;; (begin1 "abc" "def") => (begin "def" "abc")
(define-syntax-rule (begin1 br b1 ...) (begin b1 ... br))

;;;; my version of misc procedures
;; (sort/ f lst) === (sort lst f)
(define-syntax-rule (sort/ f lst) (sort lst f))
(define-syntax-rule (hash-table-map/ f hash) (hash-table-map hash f))

;;;; type convention and some data structure
(define (sha1sum<-string obj) (string->sha1sum obj))
(define (string<-seconds sec) (seconds->string sec))

(define (string<-symbol obj) (symbol->string obj))
(define (symbol<-string obj) (string->symbol obj))
(define (alist<-hash-table obj) (hash-table->alist obj))

(define (vector<-list obj) (list->vector obj))
(define (list<-vector obj) (vector->list obj))

;; json
(define (string<-json obj) (with-output-to-string (lambda () (json-write obj))))
(define (json<-string obj) (with-input-from-string obj (lambda () (json-read))))

;; hasheq
(define make-hasheq (lambda () (make-hash-table test: eq?)))
(define alist<-hasheq (lambda (h) (alist<-hash-table h)))
(define hasheq<-alist (lambda (h) (alist->hash-table h test: eq?)))

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
