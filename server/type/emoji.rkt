#lang racket

(require racket/generic
         "./rotom.rkt"
         "./json.rkt"
         "./moment.rkt")

(provide (all-defined-out))

(struct 表情结构 [id 名字 链接 分组id 创建日期]
  #:methods gen:ToJSON
  [(define/generic -->jsexpr ->jsexpr)
   (define (->jsexpr self)
     (match self
       [(表情结构 id 名字 链接 分组id 创建日期)
        (make-hash `((id . ,id)
                     (名字 . ,名字)
                     (链接 . ,链接)
                     (创建日期 . ,(-->jsexpr 创建日期))))]))])

(define 表情/c
  (struct/c 表情结构
            positive-integer?
            string?
            string?
            positive-integer?
            sql-moment/c))

(define/contract (vector->表情 row)
  (-> (vector-size/c 5) 表情/c)
  (define-values (id 名字 链接 创建日期)
    (vector->values row))
  (表情结构 id
            名字
            链接
            (sql-timestamp->sql-moment 创建日期)))
