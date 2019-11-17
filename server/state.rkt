#lang racket

(require (prefix-in db:: db))

(provide init-app
         app/c)

;;; 没想到，我竟然也要在这里写一个全局状态
(struct app [pool])

;;; app contract
(define app/c (struct/c app db::connection-pool?))

;;; 初始化数据库
(define/contract (init-db)
  (-> db::connection-pool?)
  (db::connection-pool
   (λ ()
     (db::postgresql-connect #:user "kalxd"
                             #:database "rotom"))))

;;; 初始化全局状态
(define/contract (init-app)
  (-> app/c)
  (let ([db (init-db)])
    (app db)))

;;; 从连接池里获得一个连接
(define/contract (ask-connection app)
  (-> app/c db::connection?)
  (let ([pool (app-pool app)])
    (db::connection-pool-lease pool)))

;;; 查询
(define/contract (query app stmt . args)
  (->* (app/c db::statement?)
       #:rest (listof any/c)
       (or/c db::simple-result? db::rows-result?))
  (let* ([conn (ask-connection app)]
         [sql (cons stmt args)])
    (apply db::query (cons conn sql))))
