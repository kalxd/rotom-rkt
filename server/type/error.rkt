#lang racket

(require racket/generic
         json
         web-server/http/response-structs)

(provide send/error
         error:base
         error:base?
         error:auth:user
         error:no:user
         error:no:group
         error:no:emoji)

;;; HTTP响应状态码
(define-generics ToHttpCode
  (->http-code ToHttpCode))

;;; 我们自己的状态码。
(define-generics ToErrorCode
  (->error-code ToErrorCode))

(define-syntax-rule (binding-code f code)
  (define (f _) code))

;;; 自定义错误
(struct error:base ([message #:auto])
  #:auto-value "error"
  #:transparent
  #:methods gen:ToHttpCode [(binding-code ->http-code 500)]
  #:methods gen:ToErrorCode [(binding-code ->error-code 0)])

;;; 验证错误
(struct error:auth:user error:base []
  #:methods gen:ToHttpCode [(binding-code ->http-code 403)]
  #:methods gen:ToErrorCode [(binding-code ->error-code 201)])

;;; 未找到
(struct error:no error:base []
  #:methods gen:ToHttpCode [(binding-code ->http-code 404)]
  #:methods gen:ToErrorCode [(binding-code ->error-code 0)])

(struct error:no:user error:no []
  #:methods gen:ToErrorCode [(binding-code ->error-code 101)])
(struct error:no:group error:no []
  #:methods gen:ToErrorCode [(binding-code ->error-code 102)])
(struct error:no:emoji error:no []
  #:methods gen:ToErrorCode [(binding-code ->error-code 103)])

;;; 响应错误
(define/contract (send/error e)
  (-> error:base? response?)
  (let* ([code (->http-code e)]
         [error-code (->error-code e)]
         [msg (error:base-message e)]
         [body (make-hash `((code . ,error-code)
                            (err . ,msg)))])
    (response/full code
                   #f
                   (current-seconds)
                   #"application/json"
                   empty
                   (list (jsexpr->bytes body)))))
