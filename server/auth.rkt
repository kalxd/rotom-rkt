#lang racket

#|
用户身份验证相关。
|#

(require web-server/http

         "./type/user.rkt"
         "./type/error.rkt"
         "./app.rkt"

         (prefix-in userHelper:: "./helper/user.rkt"))

(provide 检查用户)

(module+ test
  (require quickcheck
           rackunit/quickcheck))

;;; 从头部中找出token。
(define/contract (头部token 头部列表)
  (-> (listof header?) (or/c #f bytes?))
  (define (匹配? 头部)
    (equal? (header-field 头部) #"rotom"))

  (let ([头部 (findf 匹配? 头部列表)])
    (and 头部 (header-value 头部))))

(module+ test
  (define 头部token:正确
    (property
     ([s arbitrary-string])
     (let* ([ver (string->bytes/utf-8 s)]
            [headers (list (make-header #"rotom" ver))])
       (equal? ver (头部token headers)))))
  (check-property 头部token:正确)

  (define 头部token:错误
    (property
     ([k arbitrary-ascii-string]
      [v arbitrary-string])
     (let ([key (string->bytes/utf-8 k)]
           [value (string->bytes/utf-8 v)])
       (==> (not (equal? #"rotom" key))
            (let ([headers (list (make-header key value))])
              (false? (头部token headers)))))))
  (check-property 头部token:错误))

;;; 从请求中找出token。
(define/contract (token版本 req)
  (-> request? (or/c #f bytes?))
  (let ([headers (request-headers/raw req)])
    (头部token headers)))

;;; 检查是不是自己，遇到不陌生人直接抛错误。
(define/contract (检查用户 state req)
  (-> state/c request? 用户/c)
  (let* ([token (token版本 req)]
         [user (and token
                    (userHelper::find-by-token state
                                               (bytes->string/utf-8 token)))])
    (begin
      (unless user (raise 未认证用户))
      user)))
