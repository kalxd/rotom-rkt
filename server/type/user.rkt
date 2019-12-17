#lang racket

(require "./json.rkt")

(provide (all-defined-out))

;;; 平平常常、普普通通的用户。
(struct 用户结构 [id 用户名]
  #:methods gen:ToJSON
  [(define (->jsexpr 用户)
     (match 用户
       [(用户结构 id 用户名)
        (make-hash `((id . ,id)
                     (用户名 . ,用户名)))]))])

;;; 这样用户才是好用户。
(define 用户/c
  (struct/c 用户结构 positive-integer? string?))
