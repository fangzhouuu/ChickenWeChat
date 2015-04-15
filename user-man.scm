(use miscmacros http-client)
(include "utils")
(include "crypt")
;(include "persistence")

(define create-group
  (lambda (group-id group-name)
    (let ([url (string-append "https://api.weixin.qq.com/cgi-bin/groups/create?"
                              "access_token=" (get-access-token))]
          [msg (string<-json `#(("group" .
                                 #(("id"   . ,group-id)
                                   ("name" . ,group-name)))))])
      (log "Request for Group Creation with Response: ~A"
           (with-input-from-request url msg read-string)))))

(define get-group
  (lambda ()
    (let ([url (string-append "https://api.weixin.qq.com/cgi-bin/groups/get?"
                              "access_token=" (get-access-token))])
      (log "Request for Getting Groups with response: ~A"
           (json<-string (with-input-from-request url #f read-string))))))

(define delete-group
  (lambda (group-id group-name)
    (let ([url (string-append "https://api.weixin.qq.com/cgi-bin/groups/delete?"
                              "access_token=" (get-access-token))]
          [msg (string<-json `#(("group" .
                                 #(("id"   . ,group-id)
                                   ("name" . ,group-name)))))])
      (log "Request for Group Deletion with Response: ~A"
           (with-input-from-request url msg read-string)))))

(define which-group-user
  (lambda (open-id)
    (let* ([url     (string-append "https://api.weixin.qq.com/cgi-bin/groups/getid?"
                                   "access_token=" (get-access-token))]
           [msg     (string<-json `#(("openid" . ,open-id)))]
           [res-vec (json<-string (with-input-from-request url msg read-string))])
      (cdr (vector-ref res-vec 0)))))

(define to-group-user
  (lambda (group-id . open-id)
    (let ([url (string-append "https://api.weixin.qq.com/cgi-bin/groups/members/batchupdate?"
                              "access_token=" (get-access-token))]
          [msg (string<-json `#(("openid_list" . ,open-id)
                                ("to_groupid"  . ,group-id)))])
      (log "Request for Move ~A to Group ~A with Response: ~A"
           open-id group-id
           (json<-string (with-input-from-request url msg read-string))))))
;;(to-group-user 100 "oY-bVt1TnmNxMGhOoZZEkLO5vRPw")
;;(display (which-group-user "oY-bVt1TnmNxMGhOoZZEkLO5vRPw"))

(define get-user-list
  (lambda ()
    (let ([url (string-append "https://api.weixin.qq.com/cgi-bin/user/get?"
                              "access_token=" (get-access-token)
                              #;"&next_openid=NEXT_OPENID")])
      (json<-string (with-input-from-request url #f read-string)))))
;;(display (get-user-list))

(define get-user-info
  (lambda (open-id)
    (let ([url (string-append "https://api.weixin.qq.com/cgi-bin/user/info?"
                              "access_token=" (get-access-token) "&"
                              "openid=" open-id "&"
                              "lang=zh_CN")])
      ;; translate to sxml, thus could use the (make-message-reader) to parse it
      (sxml<-json (json<-string (with-input-from-request url #f read-string))))))
;;(display (get-user-info "oY-bVt1TnmNxMGhOoZZEkLO5vRPw"))

(define superuser?
  (lambda (open-id)
    (case (which-group-user open-id)
      [(100) #t]
      [else #f])))
