(use sxml-serializer uri-common)
(include "dispatch")
(include "qrcode")

(page-handler (lambda (continue)
                (serialize-sxml `(html
                                  (head
                                   (meta (@ (charset "UTF-8")))
                                   (title "Resource"))
                                  (body
                                   (p "This is the resource page")
                                   (p "这是资源页面")
                                   (br)
                                   (p "扫码可关注")
                                   (img (@ (src ,(string-append "https://mp.weixin.qq.com/cgi-bin/showqrcode?ticket="
                                                                (uri-encode-string (get-ticket))))))))
                                method: 'html)))
