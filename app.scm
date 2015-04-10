;; basic wechat server
(use spiffy intarweb uri-common srfi-13)
(use dissector)

(include "utils")
(include "validate") #;crypt
(include "token-man")
(include "message") (include "response-sync") (include "response-async")

(server-port 4000)
(access-log (current-output-port))

;; for /
(add-route '("")
           (lambda (req)
             (let* ([res-buf (mk-res-buffer)] ; response buffer
                    [form    (request-content-form req)])
               (res-buf (validate req))

               (when form ; POST method?
                 (res-buf (let* ([reader (mk-message-reader
                                          (parse-message (string<-symbol (caar form))))]
                                 [to     (reader 'ToUserName)]
                                 [from   (reader 'FromUserName)]
                                 [msg    (reader 'Content)])
                            (log "User ~A says: ~A" from msg)
                            (case (symbol<-string (string-downcase msg))
                              [(|hello|)
                               (sync-response to from
                                              "Hello From Chicken!")]
                              [(|fox say| |fox|)
                               (async-response to from
                                               "bing bing")
                               (async-response to from
                                               "bing bing bing ~") ""]
                              [else
                               (sync-response to from
                                              "Don't know what to say...")]))))
               (inspect (res-buf)))))

(start-server)
