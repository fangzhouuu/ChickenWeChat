;; validation
(use simple-sha1 http-client json)
(include "utils")

;;; VALIDATION
(define validate
  (lambda (query)
    (let* ([token     "wxtestqpwoeiru"]
           [timestamp (alist-ref 'timestamp query)]
           [nonce     (alist-ref 'nonce query)]
           [signature (alist-ref 'signature query)]
           ;; if there is no echostr, return "" instead of #f
           [echostr   (alist-ref 'echostr query eqv? "")])
      (nif (string=? signature (make-signature timestamp nonce token))
           (begin (log "not validate") "not validate")
           (log "validate OK")
           echostr))))

(define make-signature
  (lambda (timestamp nonce token)
    (sha1sum<-string (apply string-append
                            (sort/ string<?
                                   (list timestamp nonce token))))))

;;; ACCESS TOKEN
;; https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=APPID&secret=APPSECRET
(define get-access-token
  (let ([access-token #f] [last-fetch-time 0.0])
    (lambda ()
      (log "Getting token. last-fetch-time ~A" (string<-seconds last-fetch-time))
      (when (> (- (current-seconds) last-fetch-time)
               7100)
        (log "Got to get a NEW token!")
        (set! access-token (fetch-access-token))
        (set! last-fetch-time (current-seconds)))
      access-token)))

(define fetch-access-token
  (lambda ()
    (let* ([appid     "wx8c09c17db05adc8b"]
           [appsecret "225e3b8b6f2b6614f6bca0607dfd2e78"]
           [req-url   (string-append "https://api.weixin.qq.com/cgi-bin/token?"
                                     "grant_type=client_credential" "&"
                                     "appid=" appid "&" "secret=" appsecret)]
           [token-vec (json<-string (with-input-from-request req-url #f read-string))])
      (cdr (vector-ref token-vec 0)))))
