(include "utils")
(include "token-man")
(use http-client json)

;; https://api.weixin.qq.com/cgi-bin/menu/create?access_token=ACCESS_TOKEN
(define create-menu
  (lambda ()
    (let ([url  (string-append "https://api.weixin.qq.com/cgi-bin/menu/create?"
                                  "access_token=" (get-access-token))]
          [menu (with-output-to-string
                  (lambda () (json-write `#(("button" .
                                        (#(("name" . "赞?")
                                           ("sub_button" .
                                            (#(("type" . "click")
                                               ("name" . "Humm..")
                                               ("key"  . "EVT_UNLIKE"))
                                             #(("type" . "click")
                                               ("name" . "Like!")
                                               ("key"  . "EVT_LIKE")))))
                                         #(("type" . "click")
                                           ("name" . "命令查询")
                                           ("key"  . "EVT_HELP"))
                                         #(("name" . "关于")
                                           ("sub_button" .
                                            (#(("type" . "click")
                                               ("name" . "fund us!")
                                               ("key"  . "EVT_FUND"))
                                             #(("type" . "view")
                                               ("name" . "Search")
                                               ("url"  . "http://baidu.com")))))))))))])
      (log "Request for Menu Creation with response: ~A"
           (with-input-from-request url menu read-string)))))

(define get-menu
  (lambda ()
    (let ([url (string-append "https://api.weixin.qq.com/cgi-bin/menu/get?"
                                  "access_token=" (get-access-token))])
      (log "Request for Getting Menu with response: ~A"
           (with-input-from-string (with-input-from-request url #f read-string)
             (lambda ()
               (json-read)))))))

;;https://api.weixin.qq.com/cgi-bin/menu/delete?access_token=ACCESS_TOKEN
(define delete-menu
  (lambda ()
    (let ([url (string-append "https://api.weixin.qq.com/cgi-bin/menu/delete?"
                                  "access_token=" (get-access-token))])
      (log "Request for Menu Deletion with response: ~A"
           (with-input-from-request url #f read-string)))))
