#lang racket

(require web-server/servlet-env
         "./server/type/config.rkt"
         "./server/type/state.rkt"
         "./server/main.rkt")

(module+ main
  ;; 启动服务。
  (let ([state (init-state)])
    (serve/servlet ((curry execute) state)
                   #:port (app-config-port 默认配置)
                   #:listen-ip (app-config-host 默认配置)
                   #:command-line? #t
                   #:servlet-regexp #rx"")))
