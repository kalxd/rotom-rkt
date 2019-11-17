#lang racket

#|
用户身份验证相关。
|#

(require web-server/http

         "./type/user.rkt"
         "./type/error.rkt"
         "./state.rkt"

         (prefix-in userHelper:: "./helper/user.rkt"))

(provide check-req)

(module+ test
  (require quickcheck)
  (require rackunit/quickcheck))

;;; 从头部中找出token。
(define/contract (find-header-rotom headers)
  (-> (listof header?) (or/c #f bytes?))
  (let* ([f (λ (header) (equal? (header-field header) #"rotom"))]
         [header (findf f headers)])
    (and header (header-value header))))

(module+ test
  (define find-header-rotom:yes
    (property
     ([s arbitrary-string])
     (let* ([ver (string->bytes/utf-8 s)]
            [headers (list (make-header #"rotom" ver))])
       (equal? ver (find-header-rotom headers)))))
  (check-property find-header-rotom:yes)

  (define find-header-rotom:no
    (property
     ([k arbitrary-ascii-string]
      [v arbitrary-string])
     (let ([key (string->bytes/latin-1 k)]
           [value (string->bytes/utf-8 v)])
       (==> (not (equal? #"rotom" key))
            (let ([headers (list (make-header key value))])
              (false? (find-header-rotom headers)))))))
  (check-property find-header-rotom:no))

;;; 从请求中找出token。
(define/contract (rotom-ver req)
  (-> request? (or/c #f bytes?))
  (let ([headers (request-headers/raw req)])
    (find-header-rotom headers)))

;;; 检查是不是自己，遇到不陌生人直接抛错误。
(define/contract (check-req state req)
  (-> state/c request? user/c)
  (let* ([token (rotom-ver req)]
         [user (and token (userHelper::find-by-token state token))])
    (begin
      (unless user (raise (error:auth:user)))
      user)))
