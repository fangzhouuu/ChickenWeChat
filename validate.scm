;; validation
(include "utils")
(use simple-sha1)

(define validate
  (lambda (query)
    (let* ([token     "wxtestqpwoeiru"]
           [timestamp (alist-ref 'timestamp query)]
           [nonce     (alist-ref 'nonce query)]
           [signature (alist-ref 'signature query)]
           ;; if there is no echostr, return "" instead of #f
           [echostr   (alist-ref 'echostr query eqv? "")])
      (nif (string=? signature (mk-signature timestamp nonce token))
           (begin (log "not validate") "not validate")
           (log "validate OK")
           echostr))))

(define mk-signature
  (lambda (timestamp nonce token)
    (sha1sum<-string (apply string-append
                            (sort (list timestamp nonce token)
                                  string<?)))))
