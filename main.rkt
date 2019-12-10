#lang racket

(require web-server/servlet-env
         "./server/type/config.rkt"
         "./server/type/state.rkt"
         "./server/main.rkt")

(module+ main
  ;; 启动服务。
  (let ([state (init-state)])
    (serve/servlet ((curry execute) state)
                   #:port (app-config-port def-app-config)
                   #:listen-ip (app-config-host def-app-config)
                   #:command-line? #t
                   #:servlet-regexp #rx"")))
