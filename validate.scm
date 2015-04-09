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
           [echostr   (alist-ref 'echostr params)])
      (nif (string=? signature (mk-signature timestamp nonce token))
           "not validate"
           echostr))))

(define mk-signature
  (lambda (timestamp nonce token)
    (sha1sum<-string (apply string-append
                            (sort (list timestamp nonce token)
                                  string<?)))))
