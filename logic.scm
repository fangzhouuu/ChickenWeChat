(use matchable)
(include "utils")
(include "user-man")
(use dissector)

(define count-table #f)

(define like-counter
  (lambda query
    (let ([get-ratio ;; (get-ratio #hash((abc . 1) (def . 0))) => "1/2"
           (lambda (table)
             (conc (apply + (hash-table-map/ (lambda (key value) value)
                                             table))
                   "/"
                   (hash-table-size table)))])
      (match query
        [() (get-ratio count-table)]
        [(action user)
         (let ([user (symbol<-string user)])
           (cond
            [(eq? action 'like)
             (hash-table-set! count-table user 1)]
            [(eq? action 'unlike)
             (hash-table-set! count-table user 0)]
            [(eq? action 'on-going?)
             (if (not count-table) #f #t)]
            [(eq? action 'stop)
             (when-superuser? user
                              (log "like counter shutdown by ~A, with obsoleted counter:~n~A"
                                   user (alist<-hash-table count-table))
                              (set! count-table #f))]
            [(eq? action 'start)
             (when-superuser? user
                              (log "like counter started, by ~A" user)
                              (set! count-table (make-hasheq)))]
            [else ""]))]))))
