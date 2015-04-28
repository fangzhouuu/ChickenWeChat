(use s11n posix srfi-18 srfi-69)
(include "utils")

;; serialization
(define pickle
  (lambda (data file-name)
    (log "Before Pickle to ~A: ~A" file-name (current-milliseconds))
    (when (file-exists? file-name) (delete-file file-name))
    (with-output-to-file file-name
      (lambda () (serialize data)))
    (log "After Pickle to ~A: ~A" file-name (current-milliseconds))))

(define unpickle
  (lambda (file-name)
    (if (file-exists? file-name)
         (begin
           (log "Before unPickle from ~A: ~A" file-name (current-milliseconds))
           (begin1
            (with-input-from-file file-name
              (lambda ()
                (deserialize)))
            (log "After unPickle from ~A: ~A" file-name (current-milliseconds))))
        #f)))

(define hasheq-serialize
  (lambda (h fn)
    (when h
      (pickle (alist<-hasheq h) fn))))

(define hasheq-deserialize
  (lambda (fn)
    (hasheq<-alist (unpickle fn))))

(define pickle-all #f)
(define unpickle-all #f)
(define-syntax set-pickle/unpickle-all
  (syntax-rules ()
    [(n ((func file) ...))
     (begin
       (set! pickle-all
         (lambda ()
           (pickle func file) ...))
       (set! unpickle-all
         (lambda ()
           (when (file-exists? file)
             (set! func (unpickle file))) ...)))]))

(define pickle-hash-all #f)
(define unpickle-hash-all #f)
(define-syntax set-pickle/unpickle-hash-all
  (syntax-rules ()
    [(n ((hash file) ...))
     (begin
       (set! pickle-hash-all
         (lambda ()
           (hasheq-serialize hash file) ...))
       (set! unpickle-hash-all
         (lambda ()
           (when (file-exists? file)
             (set! hash (hasheq-deserialize file))) ...)))]))

;; for SIGINT(^C) SIGTERM and SIGALARM
(map (lambda (sig)
       (set-signal-handler! sig (lambda (x)
                                  (log "Before Pickle: ~A" (current-milliseconds))
                                  (pickle-all)
                                  (pickle-hash-all)
                                  (log "After Pickle:  ~A" (current-milliseconds))
                                  (if (= sig 14)
                                      (begin (log "dump and reset clock")
                                             (set-alarm! 60))
                                      (exit 0)))))
     '(2 15 14))

(set-alarm! 5) ;; set auto dumpping

(set-pickle/unpickle-all      ((get-access-token "./data/access-token")))
(set-pickle/unpickle-hash-all ((count-table "./data/count-table")))

;; hasheq serialization
;; s11n has a wired bug when serializing hash-table, so use alist

(unpickle-all)
(unpickle-hash-all)
