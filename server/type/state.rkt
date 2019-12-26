#lang racket

(require (prefix-in db:: db)
         "./config.rkt")

(provide init-state
         state/c
         ask-connection)

;;; 没想到，我竟然也要在这里写一个全局状态
(struct state [pool])

;;; state contract
(define state/c
  (struct/c state db::connection-pool?))

;;; 初始化数据库
(define/contract (init-db)
  (-> db::connection-pool?)
  (let ([db (app-config-db 默认配置)])
    (match db
      [(db-config host user password database)
       (db::connection-pool
        (λ ()
          (db::postgresql-connect #:user user
                                  #:database database
                                  #:password password
                                  #:server host)))])))

;;; 初始化全局状态
(define/contract init-state
  (-> state/c)
  (compose state init-db))

;;; 从连接池里获得一个连接
(define/contract ask-connection
  (-> state/c db::connection?)
  (compose db::connection-pool-lease state-pool))
