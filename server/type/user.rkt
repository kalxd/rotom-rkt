#lang racket

(require "./json.rkt")

(provide (all-defined-out))

;;; 平平常常、普普通通的用户。
(struct user [id name]
  #:methods gen:ToJSON [(define (->jsexpr self)
                          (match self
                            [(user id name)
                             (make-hash `((id . ,id)
                                          (name . ,name)))]))]
  #:methods gen:equal+hash [(define (equal-proc self other cmp)
                              (let ([self-id (user-id self)]
                                    [other-id (user-id other)])
                                (cmp self-id other-id)))
                            (define (hash-proc self gen-code)
                              (gen-code (user-id self)))
                            (define (hash2-proc self gen-code)
                              (gen-code (user-id self)))])

;;; 这样用户才是好用户
(define user/c
  (struct/c user positive-integer? string?))

(module+ test
  (require quickcheck
           rackunit/quickcheck)

  ;;; 用户测试。
  (define user-equal:prop
    (property
     ([id arbitrary-integer]
      [name1 arbitrary-string]
      [name2 arbitrary-string])
     (let ([user1 (user id name1)]
           [user2 (user id name2)])
       (equal? user1 user2))))
  (check-property user-equal:prop))
