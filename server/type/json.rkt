#lang racket

(provide all-from-out)

(require racket/generic
         json)

(define-generics ToJSON
  (json->string ToJSON)
  (json->byte ToJSON)
  #:fallbacks ((define/generic -->string json->string)
               (define json->byte
                 (compose jsexpr->bytes -->string)))
  #:defaults ([string? (begin
                         (define json->string jsexpr->string)
                         (define json->byte jsexpr->bytes))]
              [number? (begin
                         (define json->string jsexpr->string)
                         (define json->byte jsexpr->bytes))]
              [hash? (begin
                       (define json->string jsexpr->string)
                       (define json->byte jsexpr->bytes))]
              [list? (begin
                       (define json->string jsexpr->string)
                       (define json->byte jsexpr->bytes))]
              [boolean? (begin
                          (define json->string jsexpr->string)
                          (define json->byte jsexpr->bytes))]))
