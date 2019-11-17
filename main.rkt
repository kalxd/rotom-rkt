#lang racket

(require web-server/servlet
         web-server/servlet-env

         "./server/state.rkt")

;;; 服务内部任务。
(define/contract (start app req)
  (-> app/c request? void)
  (displayln "程序启动了！")
  (displayln req))

(module+ main
  ;; 启动服务。
  (let ([app (init-app)])
    (serve/servlet ((curry start) app)
                   #:command-line? #t
                   #:servlet-regexp #rx"")))
