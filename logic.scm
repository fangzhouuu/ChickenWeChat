(include "utils")
(include "user-man")
(use dissector)

(define count-table #f)

(define like-counter
  (lambda query
    (define get-ratio (lambda (h)
                        (conc
                         (apply + (hash-table-map h (lambda (k v) v)))
                         "/"
                         (hash-table-size h))))
    (cond
     [(null? query) (get-ratio count-table)]
     [else
      (let ([action (caar query)]
            [user   (symbol<-string (cdar query))])
        (cond
         [(eqv? action 'like)
          (hash-table-set! count-table user 1)]
         [(eqv? action 'unlike)
          (hash-table-set! count-table user 0)]
         [(eqv? action 'on-going?)
          (if (not count-table) #f #t)]
         [(eqv? action 'stop)
          (when-superuser? user
             (log "like counter shutdown by ~A, with obsoleted counter:~n~A"
                  user (alist<-hash-table count-table))
             (set! count-table #f))]
         [(eqv? action 'start)
          (when-superuser? user
             (log "like counter started, by ~A" user)
             (set! count-table (make-hasheq)))]
         [else ""]))])))
