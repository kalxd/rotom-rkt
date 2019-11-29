#lang racket

(require web-server/http
         web-server/dispatch
         "./app.rkt"
         "./auth.rkt"
         "./type/error.rkt"
         "./type/json.rkt"
         (prefix-in grouphelper:: "./helper/group.rkt"))

(provide execute)

#|
整个服务主入口，main.rkt是个傀儡。
|#

;;; 路由
(define (bind-dispatch user state)
  (dispatch-case
   [("ffzu") #:method "get" ((curry grouphelper::group-list) state)]))

(define/contract (execute state req)
  (-> state/c request? response?)
  (with-handlers
    ([error:box? send/error])
    (let* ([user (check-req state req)]
           [dispatch-route (bind-dispatch user state)]
           [result (dispatch-route req)]
           [body (json->byte result)])
      (response/full 200
                     #f
                     (current-seconds)
                     #f
                     (list (header #"Content-Type" #"application/json"))
                     (list body)))))
