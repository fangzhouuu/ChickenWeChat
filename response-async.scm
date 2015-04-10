(include "utils")
(include "token-man")
(use http-client)

;; https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=ACCESS_TOKEN
(define async-response
  (lambda (from to msg)
    (let ([req-url  (string-append "https://api.weixin.qq.com/cgi-bin/message/custom/send?"
                                   "access_token="
                                   (get-access-token))]
          [json-msg (with-output-to-string
                      (lambda () (json-write `#(("touser" . ,to)
                                           ("msgtype" . "text")
                                           ("text". #(("content" . ,msg)))))))])
      (with-input-from-request req-url json-msg read-string))))

;; return a emtpy string when finished register async response
(define finish-async-response
  (lambda ()
    ""))
