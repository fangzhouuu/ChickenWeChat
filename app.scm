;; basic webserver
(use spiffy intarweb uri-common simple-sha1)
(use dissector)

(server-port 4000)
(debug-log (current-output-port))

;; (nif (eq? 1 1) "false" (display "true") "true") => "true"
(define-syntax nif
  (syntax-rules ()
    [(_ test false-body true-body ...)
     (if test (begin true-body ...) false-body)]))

(define mk-signature
  (lambda (timestamp nonce token)
    (string->sha1sum (apply string-append
                            (sort (list timestamp nonce token)
                                  string<?)))))

(define validate
  (lambda (req)
    (let* ([token "wxtestqpwoeiru"]
           [params (request-content-query req)]
           [timestamp (alist-ref 'timestamp params)]
           [nonce (alist-ref 'nonce params)]
           [signature (alist-ref 'signature params)]
           [echostr (alist-ref 'echostr params)])
      (if (string=? signature (mk-signature timestamp nonce token))
          echostr
          "not validate"))))

;; for /
(add-route '("") (lambda (req)
                   (validate req)))

(start-server)
