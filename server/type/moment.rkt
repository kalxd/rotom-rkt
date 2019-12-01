#lang racket

(require (only-in db
                  sql-timestamp
                  sql-timestamp?)
         gregor
         "./json.rkt")

(provide (all-defined-out))

;;; 动态语言里还是不要太过动态，还是写死类型。
(struct sql-moment [t]
  #:methods gen:moment-provider
  [(define (->moment t)
     (match (sql-moment-t t)
       [(sql-timestamp year month day hour minute second nanosecond tz)
        (moment year month day hour minute second nanosecond #:tz tz)]))]

  #:methods gen:ToJSON
  [(define ->jsexpr
     (compose moment->iso8601 ->moment))])

;;; 数据库时间约束。
(define sql-moment/c
  (struct/c sql-moment sql-timestamp?))

;;; 打包sql-timestamp
(define/contract sql-timestamp->sql-moment
  (-> sql-timestamp? sql-moment/c)
  sql-moment)

(define/contract sql-timestamp->moment
  (-> sql-timestamp? moment?)
  (compose ->moment sql-timestamp->sql-moment))
