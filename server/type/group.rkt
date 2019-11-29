#lang racket

(require "./json.rkt")

(provide (all-defined-out))

(struct group-type [id name]
  #:methods gen:ToJSON ([define (->jsexpr self)
                          (match self
                            [(group-type id name)
                             (make-hash `((id . ,id)
                                          (name . ,name)))])]))

(define group-type/c
  (struct/c group-type
            positive-integer?
            string?))

(define/contract (vector->group-type xs)
  (-> vector? group-type/c)
  (match xs
    [(vector id name) (group-type id name)]))
