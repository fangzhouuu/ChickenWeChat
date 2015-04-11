;; xml message handler
(include "utils")
(use ssax)

;; order: ToUserName FromUserName CreateTime MsgType (Content/(Event EventKey))
(define make-message-reader
  (lambda (msg-lst)
    (let ([message msg-lst] [cache (make-hash-table)])
      (lambda (name)
        (let loop ([msg message])
          (cond
           [(null? msg)
            (if (hash-table-exist? cache name)
                (hash-table-ref cache name) #f)]
           [(eqv? (caar msg) name)
            (set! message (cdr msg))
            (cadar msg)]
           [else
            (hash-table-set! cache (caar msg) (cadar msg))
            (loop (cdr msg))]))))))

(define parse-message
  (lambda (msg)
    (inspect 'incomming-sxml
             (with-input-from-string msg
               (lambda ()
                 (cdadr ;; want: (*TOP* (xml >>((FromUserName ...) ...)<<))
                  (ssax:xml->sxml (current-input-port) '())))))))
