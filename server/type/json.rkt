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
  (require quickcheck)
  (struct my-struct [id name]))
