(use http-client sxml-serializer)
(include "utils")
(include "crypt")

;;; SYNC
;; generate a sync response body
(define sync-response
  (lambda (from to msg)
    (serialize-sxml `(xml
                      (FromUserName ,from)
                      (ToUserName ,to)
                      (MsgType "text")
                      (Content ,msg)
                      (CreateTime ,(current-unix-time)))
                    cdata-section-elements: '(FromUserName ToUserName
                                              MsgType Content))))
;;; ASYNC
;; https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=ACCESS_TOKEN
(define async-response
  (lambda (from to msg)
    (let ([req-url  (string-append "https://api.weixin.qq.com/cgi-bin/message/custom/send?"
                                   "access_token=" (get-access-token))]
          [json-msg (string<-json `#(("touser" . ,to)
                                          ("msgtype" . "text")
                                          ("text". #(("content" . ,msg)))))])
      (with-input-from-request req-url json-msg read-string))))

;; return a emtpy string when finished register async response
(define acknowledge-string
  (lambda () ""))
