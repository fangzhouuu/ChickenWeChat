;;(declare (unit utils))

;; (nif (eq? 1 1) "false" (display "true") "true") => "true"
(use miscmacros spiffy)

;; resposne writer
;; (define r (mk-res-buffer)) => void
;; (r "abc" "def") => void
;; (r) => "abcdef"
(define mk-res-buffer
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
  (lambda (str start end)
    (let* ([len   (string-length str)]
           [start (modulo start len)]
           [end   (modulo end len)])
      (substring str start end))))

;; aliasing some useful stuff
(define-syntax nif
  (syntax-rules ()
    [(_ test false-body true-body ...)
     (if test (begin true-body ...) false-body)]))

(define-syntax-rule (sha1sum<-string str) (string->sha1sum str))
(define-syntax-rule (string<-seconds str) (seconds->string str))

(define-syntax-rule (string<-symbol str) (symbol->string str))
(define-syntax-rule (symbol<-string str) (string->symbol str))
