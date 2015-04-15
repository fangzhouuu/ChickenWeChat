(use spiffy intarweb uri-common srfi-13)
(use dissector)
;; libs
(include "utils") (include "dispatch") (include "crypt")
(include "message") (include "response")
;; user code
(include "page") (include "logic") (include "user-man")
(include "persistence")

(text-handler  (lambda (to from content)
                 (case (symbol<-string (string-downcase content))
                   [(|h| |help|)
                    (sync-response to from (conc "HELP\n"
                                                 "start:\n 开始新的计数\n"
                                                 "stop: \n 停止已有的计数"))]
                   [(|start|)
                    (like-counter 'start from)
                    (sync-response to from "Like Counter Start!")]
                   [(|stop|)
                    (like-counter 'stop from)
                    (sync-response to from "Like Counter Stop!")]
                   [(|fox say| |fox|)
                    (begin1 (acknowledge-string) ; return ack("") for later async response
                            (async-response to from "bing bing")
                            (async-response to from "bing bing bing ~"))]
                   [else
                    (sync-response to from "Don't know what to say...")])))

(event-handler (lambda (to from event event-key)
                 (case (symbol<-string event-key)
                   [(|EVT_PULL|)
                    (cond
                     [(like-counter 'on-going? from)
                      (sync-response to from (conc "投票中。。\n"
                                                   "目前是" (like-counter)))]
                     [else
                      (sync-response to from "暂无新的消息")])]
                   [(|EVT_LIKE|)
                    (if (like-counter 'on-going? from)
                        (begin
                          (like-counter 'like from)
                          (sync-response to from (conc "点了个赞!\n"
                                                       "目前是" (like-counter))))
                        (sync-response to from (conc "目前没有投票。。。")))]
                   [(|EVT_UNLIKE|)
                    (if (like-counter 'on-going? from)
                        (begin
                          (like-counter 'unlike from)
                          (sync-response to from (conc "不是很喜欢嘛。。\n"
                                                       "目前是" (like-counter))))
                        (sync-response to from (conc "目前没有投票。。。")))]
                   [(|EVT_ABOUT|)
                    (sync-response to from (conc "Powered by\n"
                                                 "(Spiffy (Chicken Scheme))"))]
                   [(|EVT_HELP|)
                    (sync-response to from (conc "点\"看看\"可以收到最新消息\n"
                                                 "点\"赞\"中的两个选项均可投票，若多次投票，以最后一次为准\n"
                                                 "点\"关于\"中资源页可以看到一些链接\n"
                                                 "想说什么就直接发过来~~暂不支持语音"))]
                   [else
                    (sync-response to from "还不会处理这种事件...")])))

(parameterize ((server-port 4000)
               (access-log  (current-output-port)))
  (start-server))
