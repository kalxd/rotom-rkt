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
              [boolean? (id-defaults)]
              [symbol? (id-defaults)]
              [list? (define/generic -->jsexpr ->jsexpr)
                     (define (->jsexpr self)
                       (define (f x)
                         (cond
                           [(jsexpr? x) x]
                           [else (-->jsexpr x)]))
                       (map f self))]))

(module+ test
  (require quickcheck
           rackunit/quickcheck)

  (define (mk-hash id name)
    (make-hash `((id . ,id)
                 (name . ,name))))

  (struct my-struct [id name]
    #:methods gen:ToJSON [(define (->jsexpr self)
                            (match self
                              [(my-struct id name) (mk-hash id name)]))])

  ;;; 数字测试。
  (define number<->json:prop
    (property
     ([n arbitrary-integer])
     (equal? (jsexpr->string n) (json->string n))))
  (check-property number<->json:prop)

  ;;; 字符串测试。
  (define string<->json:prop
    (property
     ([s arbitrary-string])
     (equal? (jsexpr->string s) (json->string s))))
  (check-property string<->json:prop)

  ;;; 布尔值测试。
  (define boolean<->json:prop
    (property
     ([b arbitrary-boolean])
     (equal? (jsexpr->string b) (json->string b))))
  (check-property boolean<->json:prop)

  ;;; 数组测试。
  (define list<->json:prop
    (property
     ([xs (arbitrary-list arbitrary-string)])
     (equal? (jsexpr->string xs) (json->string xs))))
  (check-property list<->json:prop)

  ;;; hashmap及struct测试。
  (define struct<->hash:prop
    (property
     ([id arbitrary-integer]
      [name arbitrary-string])
     (let ([me (my-struct id name)]
           [o (make-hash `((id . ,id) (name . ,name)))])
       (equal? (jsexpr->string o) (json->string me)))))
  (check-property struct<->hash:prop)

  ;;; 自定义struct列表测试。
  (define struct-list<->hash-list:prop
    (property
     ([xs (arbitrary-list (arbitrary-pair arbitrary-integer arbitrary-string))])
     (let ([me-list (map (match-lambda
                           [(cons id name) (my-struct id name)])
                         xs)]
           [hash-list (map (match-lambda
                             [(cons id name) (mk-hash id name)])
                           xs)])
       (equal? (json->string me-list) (jsexpr->string hash-list)))))
  (check-property struct-list<->hash-list:prop))
