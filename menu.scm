(include "utils")
(include "crypt")
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
                                           ("name" . "看看")
                                           ("key"  . "EVT_PULL"))
                                         #(("name" . "帮助")
                                           ("sub_button" .
                                            (#(("type" . "click")
                                               ("name" . "About")
                                               ("key"  . "EVT_ABOUT"))
                                             #(("type" . "view")
                                               ("name" . "资源页面")
                                               ("url"  . "http://res.wx.vetrm.net"))
                                             #(("type" . "view")
                                               ("name" . "Search")
                                               ("url"  . "http://baidu.com"))
                                             #(("type" . "click")
                                               ("name" . "帮助")
                                               ("key"  . "EVT_HELP")))))))))))])
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
