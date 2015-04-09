;;(declare (unit utils))

;; (nif (eq? 1 1) "false" (display "true") "true") => "true"
(use miscmacros)


;; aliasing some useful stuff
(define-syntax nif
  (syntax-rules ()
    [(_ test false-body true-body ...)
     (if test (begin true-body ...) false-body)]))

(define-syntax-rule (sha1sum<-string str) (string->sha1sum str))
