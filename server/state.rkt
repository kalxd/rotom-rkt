#lang racket

(require (prefix-in db:: db))

(provide init-state
         state/c)

;;; 没想到，我竟然也要在这里写一个全局状态
(struct state [pool])

;;; state contract
(define state/c (struct/c state db::connection-pool?))

;;; 初始化数据库
(define/contract (init-db)
  (-> db::connection-pool?)
  (db::connection-pool
   (λ ()
     (db::postgresql-connect #:user "kalxd"
                             #:database "rotom"))))

;;; 初始化全局状态
(define/contract (init-state)
  (-> state/c)
  (let ([db (init-db)])
    (state db)))

;;; 从连接池里获得一个连接
(define/contract (ask-connection state)
  (-> state/c db::connection?)
  (let ([pool (state-pool state)])
    (db::connection-pool-lease pool)))

;;; 拼拼凑凑凑出sql参数。
;;; 最后只给喂给对应的函数即可。
(define/contract (->sql state stmt args)
  (-> state/c
      db::statement?
      (listof any/c)
      (listof any/c))
  (let ([conn (ask-connection state)]
        [sql (cons stmt args)])
    (cons conn sql)))

;;; 有了金，有了银，安心勤读过光阴。
(define/contract (apply-> f state stmt args)
  (-> any/c ;; 这里偷个懒，不定参数写起来太麻烦。
      state/c
      db::statement?
      (listof any/c)
      any)
  (let ([sql (->sql state stmt args)])
    (apply f sql)))

(define/contract (query state stmt . args)
  (->* (state/c db::statement?)
       #:rest (listof any/c)
       (or/c db::simple-result? db::rows-result?))
  (apply-> db::query state stmt args))

(define/contract (query-rows state stmt . args)
  (->* (state/c db::statement?)
       #:rest (listof any/c)
       (listof vector?))
  (apply-> db::query-rows state stmt args))

(define/contract (query-row state stmt . args)
  (->* (state/c db::statement?)
       #:rest (listof any/c)
       vector?)
  (apply-> db::query-row state stmt args))

(define/contract (query-maybe-row state stmt . args)
  (->* (state/c db::statement?)
       #:rest (listof any/c)
       (or/c vector? #f))
  (apply-> db::query-maybe-row state stmt args))
