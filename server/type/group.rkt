#lang racket

(require racket/generic
         "./rotom.rkt"
         "./json.rkt"
         "./moment.rkt")

(provide (all-defined-out))

;;; 分组基本信息。
(struct 分组结构 [id 名字 创建日期]
  #:methods gen:ToJSON
  [(define/generic -->jsexpr ->jsexpr)
   (define (->jsexpr self)
     (match self
       [(分组结构 id 名字 创建日期)
        (make-hash `((id . ,id)
                     (名字 . ,名字)
                     (创建日期 . ,(-->jsexpr 创建日期))))]))])

(define 分组/c
  (struct/c 分组结构
            positive-integer?
            string?
            sql-moment/c))

(define/contract (vector->group-type xs)
  (-> (vector-size/c 3) 分组/c)
  (match xs
    [(vector id 名字 日期)
     (分组结构 id 名字 (sql-timestamp->sql-moment 日期))]))
