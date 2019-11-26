#lang racket

(provide (all-defined-out)
         (all-from-out json))

(require racket/generic
         json)

(define-generics ToJSON
  (->jsexpr ToJSON)
  (json->string ToJSON)
  (json->byte ToJSON)
  #:fallbacks ((define/generic -->jsexpr ->jsexpr)
               (define json->string
                 (compose jsexpr->string -->jsexpr))
               (define json->byte
                 (compose jsexpr->bytes -->jsexpr)))
  #:defaults ([string? (begin
                         (define ->jsexpr identity)
                         (define json->string jsexpr->string)
                         (define json->byte jsexpr->bytes))]
              [number? (begin
                         (define ->jsexpr identity)
                         (define json->string jsexpr->string)
                         (define json->byte jsexpr->bytes))]
              [hash? (begin
                       (define ->jsexpr identity)
                       (define json->string jsexpr->string)
                       (define json->byte jsexpr->bytes))]
              [list? (begin
                       (define json->string jsexpr->string)
                       (define json->byte jsexpr->bytes))]
              [boolean? (begin
                          (define ->jsexpr identity)
                          (define json->string jsexpr->string)
                          (define json-byte jsexpr->bytes))]))

(module+ test
  (require quickcheck)
  (struct my-struct [id name]))
