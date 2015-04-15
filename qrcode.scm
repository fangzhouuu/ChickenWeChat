(use http-client)
(include "utils")
(include "crypt")

(define get-permanent-qrcode
  (lambda ()
    (let ([url (string-append "https://api.weixin.qq.com/cgi-bin/qrcode/create?"
                              "access_token=" (get-access-token))]
          [msg (string<-json `#(("action_name" . "QR_LIMIT_SCENE")
                                ("action_info" .
                                 #(("scene" .
                                    #(("scene_id" . 42)))))))])
      (log "Getting new ticket")
      (json<-string (with-input-from-request url msg read-string)))))

(define get-ticket
  (let ([ticket #f])
    (lambda ()
      (if (eq? ticket #f)
          (begin
            (set! ticket (cdr (vector-ref (get-permanent-qrcode) 0)))
            ticket)
          ticket))))
