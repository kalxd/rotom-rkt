#lang racket

(require web-server/servlet-env
         "./server/type/config.rkt"
         "./server/type/state.rkt"
         "./server/main.rkt")

(module+ main
  ;; 启动服务。
  (let* ([config (read-config (open-input-file "./config/config.json"))]
         [state (init-state config)])
    (serve/servlet ((curry execute) state)
                   #:port (app-config-port config)
                   #:command-line? #t
                   #:servlet-regexp #rx"")))
