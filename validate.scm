;; validation
(use simple-sha1)
(include "utils")

(define validate
  (lambda (req)
    (let* ([token     "wxtestqpwoeiru"]
           [params    (request-content-query req)]
           [timestamp (alist-ref 'timestamp params)]
           [nonce     (alist-ref 'nonce params)]
           [signature (alist-ref 'signature params)]
           ;; if there is no echostr, return "" instead of #f
           [echostr   (alist-ref 'echostr params eqv? "")])
      (nif (string=? signature (mk-signature timestamp nonce token))
           (begin (log "not validate") "not validate")
           (log "validate OK")
           echostr))))

(define mk-signature
  (lambda (timestamp nonce token)
    (sha1sum<-string (apply string-append
                            (sort (list timestamp nonce token)
                                  string<?)))))
