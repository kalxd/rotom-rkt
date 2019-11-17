#lang racket

(require web-server/servlet
         web-server/servlet-env

         "./server/state.rkt"
         "./server/app.rkt")

(module+ main
  ;; 启动服务。
  (let ([state (init-state)])
    (serve/servlet ((curry execute) state)
                   #:command-line? #t
                   #:servlet-regexp #rx"")))
