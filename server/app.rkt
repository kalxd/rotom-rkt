#lang racket

(require (prefix-in db:: db)
         (for-syntax racket/string)

         "./type/state.rkt")

(provide state/c

         query
         query-rows
         query-list
         query-row
         query-maybe-row
         query-value
         query-maybe-value)

#|
业务紧密相连的模块，写sql离不开它。
|#

;;; db::query -> query
(define-for-syntax (cur-function-name name)
  (let* ([fname (symbol->string name)]
         [cut-name (substring fname 4)])
    (string->symbol cut-name)))

;;; 模板代码写多了手麻，写个宏娱乐一下。
(define-syntax (extend-db stx)
  (syntax-case stx ()
    [(_ f return-contract)
     (with-syntax ([f-name (datum->syntax
                            #'f
                            (cur-function-name (syntax->datum #'f)))])
       #'(define/contract (f-name state stmt . args)
           (->* (state/c db::statement?)
               #:rest (listof any/c)
               return-contract)
           (let ([conn (ask-connection state)]
                 [sql (cons stmt args)])
             (begin
               (define args (cons conn sql))
               (apply f args)))))]))

(extend-db db::query (or/c db::simple-result? db::rows-result?))
(extend-db db::query-rows  (listof vector?))
(extend-db db::query-list list?)
(extend-db db::query-row vector?)
(extend-db db::query-maybe-row (or/c #f vector?))
(extend-db db::query-value any/c)
(extend-db db::query-maybe-value (or/c #f any/c))
