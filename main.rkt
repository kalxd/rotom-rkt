#lang racket

(require web-server/servlet
         web-server/servlet-env

         "./server/app.rkt")

;;; 高阶函数，接受全局变量，并返回serve/servlet所需的参数。
(define/contract (wrap-app app)
  (-> app/c (-> request? void))
  (λ (req) (start app req)))

;;; 服务内部任务。
(define/contract (start app req)
  (-> app/c request? void)
  (displayln app)
  (displayln req))

(module+ main
  ;; 启动服务。
  (let ([app (init-app)])
    (serve/servlet (wrap-app app))))
