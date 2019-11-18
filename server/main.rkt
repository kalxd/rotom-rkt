#lang racket

(require web-server/http
         "./app.rkt"
         "./auth.rkt"
         "./type/error.rkt")

(provide execute)

#|
整个服务主入口，main.rkt是个傀儡。
|#

(define/contract (execute state req)
  (-> state/c request? response?)
  (with-handlers
    ([error:box? send/error])
    (let ([user (check-req state req)])
      (response/xexpr '(button "sb")))))
