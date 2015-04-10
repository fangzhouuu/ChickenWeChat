(include "utils")
(use sxml-serializer)

(define sync-response
  (lambda (from to msg)
    (serialize-sxml `(xml
                      (FromUserName ,from)
                      (ToUserName ,to)
                      (MsgType "text")
                      (Content ,msg)
                      (CreateTime ,(current-unix-time)))
                    cdata-section-elements: '(FromUserName
                                              ToUserName
                                              MsgType
                                              Content))))
