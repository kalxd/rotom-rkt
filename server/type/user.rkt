#lang racket

(require "./json.rkt")

(provide (all-defined-out))

(define (user->hash u)
  (match u
    [(user id name)
     (make-hash `((id . ,id)
                  (name . ,id)))]))

;;; 平平常常、普普通通的用户。
(struct user [id name]
  #:methods gen:ToJSON [(define json->string
                          (compose jsexpr->string user->hash))
                        (define json->byte
                          (compose jsexpr->bytes user->hash))])

;;; 这样用户才是好用户
(define user/c
  (struct/c user positive-integer? string?))
