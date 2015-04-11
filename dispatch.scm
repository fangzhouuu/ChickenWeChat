(include "utils")
(use dissector)

(define text-handler  (make-parameter
                       (lambda (to from content)
                         (sync-response to from content))))
(define event-handler (make-parameter
                       (lambda (to from event event-key)
                         (sync-response to from (string-append event " " event-key)))))
(define page-handler  (make-parameter
                       (lambda ()
                         "<p>Nothing here...</p>")))

(define wx-dispatcher
  (lambda (continue)
    (let* ([query   (uri-query (request-uri (current-request)))]
           [form    (if (eq? 'POST (request-method (current-request)))
                        (read-urlencoded-request-data (current-request))
                        #f)]
           [res-buf (make-res-buffer)])
      (res-buf (validate query))
      (when form
        (res-buf (let* ([reader (make-message-reader
                                 (parse-message (string<-symbol (caar form))))]
                        [to     (reader 'ToUserName)]
                        [from   (reader 'FromUserName)]
                        [type   (reader 'MsgType)])
                   (case (symbol<-string type) ;; "text" != "text", use symbol
                     [(|text|)
                      ((text-handler) to from (reader 'Content))]
                     [(|event|)
                      ((event-handler) to from (reader 'Event) (reader 'EventKey))]
                     [else
                      (sync-response to from "don't know what to say...")]))))
      (send-response code: 200 body: (res-buf)
                     header: '((content-type text/xml))))))

(define res-dispatcher
  (lambda (continue)
    (let* ([res-buf (make-res-buffer)])
      (res-buf ((page-handler)))
      (send-response code: 200 body: (res-buf)
                     header: '((content-type text/xml))))))

(vhost-map `(("wx.vetrm.net" . ,wx-dispatcher)
             ("res.wx.vetrm.net" . ,res-dispatcher)))
