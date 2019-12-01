#lang racket

(require (only-in db
                  sql-timestamp
                  sql-timestamp?)
         gregor)

(provide (all-defined-out))

;;; 动态语言里还是不要太过动态，还是写死类型。
(struct sql-moment [t]
  #:methods gen:moment-provider [])

;;; 数据库时间约束。
(define sql-moment/c
  (struct/c sql-moment sql-timestamp?))

;;; 打包sql-timestamp
(define/contract sql-timestamp->sql-moment
  (-> sql-timestamp? sql-moment/c)
  sql-moment)
