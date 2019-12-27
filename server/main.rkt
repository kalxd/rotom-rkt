#lang racket

(require web-server/http
         web-server/dispatch
         "./type/state.rkt"
         "./type/json.rkt"

         (only-in "./type/error.rkt"
                  错误结构?
                  发送/错误)
         (only-in "./auth.rkt"
                  检查用户)

         "./helper/group.rkt")
         ;; (prefix-in emojihelper:: "./helper/emoji.rkt"))

(provide execute)

#|
整个服务主入口，main.rkt是个傀儡。
|#

;;; 路由
(define (bind-dispatch user state)
  (dispatch-case
   [("分组" "列表") #:method "get" ((curry 分组/列表) user state)]
   [("分组" "创建") #:method "post" ((curry 分组/创建) user state)]))
      #|

   [("ffzu" (integer-arg)) #:method "put" ((curry grouphelper::group-update) user state)]
   [("ffzu" (integer-arg)) #:method "get" ((curry grouphelper::group-emoji-list) user state)]))


   [("bnqk") #:method "post" ((curry emojihelper::emoji-create) user state)]
   [("bnqk" (integer-arg)) #:method "put" ((curry emojihelper::emoji-update) user state)]
   [("bnqk" (integer-arg)) #:method "delete" ((curry emojihelper::emoji-delete) user state)]))
|#

(define/contract (execute state req)
  (-> state/c request? response?)
  (with-handlers
    ([错误结构? 发送/错误])
    (let* ([user (检查用户 state req)]
           [dispatch-route (bind-dispatch user state)]
           [result (dispatch-route req)]
           [body (json->byte result)])
      (response/full 200
                     #""
                     (current-seconds)
                     #f
                     (list (header #"Content-Type" #"application/json"))
                     (list body)))))
