#lang racket

(require racket/generic
         "./rotom.rkt"
         "./json.rkt"
         "./moment.rkt")

(provide (all-defined-out))

;;; 分组基本信息。
(struct 分组结构 [id 名字 用户id 创建日期]
  #:methods gen:ToJSON
  [(define/generic -->jsexpr ->jsexpr)
   (define (->jsexpr self)
     (match self
       [(分组结构 id 名字 用户id 创建日期)
        (make-hash `((id . ,id)
                     (名字 . ,名字)
                     (用户id . ,用户id)
                     (创建日期 . ,(-->jsexpr 创建日期))))]))])

(define 分组/c
  (struct/c 分组结构
            positive-integer?
            string?
            positive-integer?
            sql-moment/c))

(define/contract (vector->分组 xs)
  (-> (vector-size/c 4) 分组/c)
  (match xs
    [(vector id 名字 用户id 日期)
     (分组结构 id 名字 用户id (sql-timestamp->sql-moment 日期))]))
