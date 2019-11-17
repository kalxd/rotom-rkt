#lang racket

(require "./json.rkt")

(provide (all-defined-out))

;;; 平平常常、普普通通的用户。
(struct user [id name]
  #:methods gen:ToJSON [(define (json->string self)
                          (match self
                            [(user id name) (make-json `((id . ,id)
                                                         (name . ,name)))]))])

;;; 这样用户才是好用户
(define user/c
  (struct/c user positive-integer? string?))
