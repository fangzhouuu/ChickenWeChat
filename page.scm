(use sxml-serializer)
(include "dispatch")

(page-handler (lambda ()
                (serialize-sxml `(html
                                  (head (meta (@ (charset "UTF-8")))
                                        (title "Resource"))
                                  (body
                                   (p "This is the resource page")
                                   (p "这是资源页面")))
                                method: 'html)))
