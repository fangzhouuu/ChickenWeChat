;; basic wechat server
(use spiffy intarweb uri-common)
(use dissector)

(include "utils") (include "validate")

(server-port 4000)
(access-log (current-output-port))

;; for /
(add-route '("") (lambda (req)
                   (validate req)))

(start-server)
