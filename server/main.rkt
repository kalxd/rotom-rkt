#lang racket

(require web-server/http
         web-server/dispatch
         "./app.rkt"
         "./auth.rkt"
         "./type/error.rkt"
         "./type/json.rkt"
         (prefix-in grouphelper:: "./helper/group.rkt")
         (prefix-in emojihelper:: "./helper/emoji.rkt"))

(provide execute)

#|
整个服务主入口，main.rkt是个傀儡。
|#

;;; 路由
(define (bind-dispatch user state)
  (dispatch-case
   [("ffzu" "lpbn") #:method "get" ((curry grouphelper::group-list) state)]
   [("ffzu") #:method "post" ((curry grouphelper::group-create) user state)]
   [("ffzu" (integer-arg)) #:method "put" ((curry grouphelper::group-update) user state)]

   [("bnqk") #:method "post" ((curry emojihelper::emoji-create) user state)]
   [("bnqk" (integer-arg)) #:method "put" ((curry emojihelper::emoji-update) user state)]))

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
