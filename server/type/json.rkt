#lang racket

(provide (all-defined-out)
         (all-from-out json))

(require racket/generic
         json)

(define-syntax (id-defaults stx)
  (datum->syntax stx '(begin
                        (define ->jsexpr identity)
                        (define json->string jsexpr->string)
                        (define json->byte jsexpr->bytes))))

(define-generics ToJSON
  (->jsexpr ToJSON)
  (json->string ToJSON)
  (json->byte ToJSON)
  #:fallbacks ((define/generic -->jsexpr ->jsexpr)
               (define json->string
                 (compose jsexpr->string -->jsexpr))
               (define json->byte
                 (compose jsexpr->bytes -->jsexpr)))
  #:defaults ([string? (id-defaults)]
              [number? (id-defaults)]
              [hash? (id-defaults)]
              [list? (id-defaults)]
              [boolean? (id-defaults)]))

(module+ test
  (require quickcheck
           rackunit/quickcheck)
  (struct my-struct [id name]
    #:methods gen:ToJSON [(define (->jsexpr self)
                            (match self
                              [(my-struct id name)
                               (make-hash `((id . ,id)
                                            (name . ,name)))]))])

  ;;; 数字测试
  (define number<->json:prop
    (property
     ([n arbitrary-integer])
     (equal? (jsexpr->string n) (json->string n))))
  (check-property number<->json:prop)

  ;;; 字符串测试
  (define string<->json:prop
    (property
     ([s arbitrary-string])
     (equal? (jsexpr->string s) (json->string s))))
  (check-property string<->json:prop)

  ;;; 布尔值测试
  (define boolean<->json:prop
    (property
     ([b arbitrary-boolean])
     (equal? (jsexpr->string b) (json->string b))))
  (check-property boolean<->json:prop)

  ;;; 数组测试
  (define list<->json:prop
    (property
     ([xs (arbitrary-list arbitrary-string)])
     (equal? (jsexpr->string xs) (json->string xs))))
  (check-property list<->json:prop)

  ;;; hashmap及struct测试
  (define struct<->hash:prop
    (property
     ([id arbitrary-integer]
      [name arbitrary-string])
     (let ([me (my-struct id name)]
           [o (make-hash `((id . ,id) (name . ,name)))])
       (equal? (jsexpr->string o) (json->string me)))))
  (check-property struct<->hash:prop))
