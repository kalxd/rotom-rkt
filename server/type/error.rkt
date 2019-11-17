#lang racket

(require racket/generic
         json
         web-server/http/response-structs)

(provide send/error
         error:auth:user
         error:no:user
         error:no:group
         error:no:emoji)

(define-generics ToCode
  (->code ToCode))

;;; 自定义错误
(struct error:base [message]
  #:transparent

  #:methods gen:ToCode [(define (->code _) 500)])

;;; 验证错误
(struct error:auth:user error:base []
  #:methods gen:ToCode ([define (->code _) 403]))

;;; 未找到
(struct error:no error:base []
  #:methods gen:ToCode ([define (->code _) 404]))

(struct error:no:user error:no [])
(struct error:no:group error:no [])
(struct error:no:emoji error:no [])

;;; 响应错误
(define/contract (send/error e)
  (-> error:base? response?)
  (let* ([code (->code e)]
         [msg (error:base-message e)]
         [body (make-hash `((code . ,code)
                            (err . ,msg)))])
    (response/full code
                   #f
                   (current-seconds)
                   #"application/json"
                   empty
                   (list (jsexpr->bytes body)))))
