#lang racket

(require web-server/servlet
         web-server/servlet-env)

(define (start req)
  (displayln req))

(module+ main
  ;; 启动服务。
  (serve/servlet start))
