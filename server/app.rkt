#lang racket

(require (prefix-in db:: db)

         "./type/state.rkt")

(provide state/c

         query
         query-rows
         query-list
         query-row
         query-value
         query-maybe-value)

#|
业务紧密相连的模块，写sql离不开它。
|#

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

(define/contract (query-list state stmt . args)
  (->* (state/c db::statement?)
       #:rest (listof any/c)
       list?)
  (apply-> db::query-list state stmt args))

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

(define/contract (query-value state stmt . args)
  (->* (state/c db::statement?)
       #:rest (listof any/c)
       any/c)
  (apply-> db::query-value state stmt args))

(define/contract (query-maybe-value state stmt . args)
  (->* (state/c db::statement?)
       #:rest (listof any/c)
       (or/c any/c #f))
  (apply-> db::query-maybe-value state stmt args))
