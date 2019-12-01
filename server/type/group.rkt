#lang racket

(require racket/generic
         "./json.rkt"
         "./moment.rkt")

(provide (all-defined-out))

(struct group-type [id name create-at]
  #:methods gen:ToJSON
  [(define/generic -->jsexpr ->jsexpr)
   (define (->jsexpr self)
     (match self
       [(group-type id name t)
        (make-hash `((id . ,id)
                     (name . ,name)
                     (createAt . ,(-->jsexpr t))))]))])

(define group-type/c
  (struct/c group-type
            positive-integer?
            string?
            sql-moment/c))

(define/contract (vector->group-type xs)
  (-> vector? group-type/c)
  (match xs
    [(vector id name create_at)
     (group-type id name (sql-timestamp->sql-moment create_at))]))
