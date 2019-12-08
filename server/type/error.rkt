#lang racket

(require json
         web-server/http/response-structs)

(provide param-invalid-code
         other-code
         no-user-code
         no-group-code
         no-emoji-code
         auth-user-code
         error:box?

         throw
         unwrap-maybe
         send/error)

;;; 错误。
;;; code：我们自己的状态码；
;;; body：输出内容。
;;; status：http状态码
(struct error:box [code body status])

(define error:box/c
  (struct/c error:box
            integer?
            string?
            (integer-in 100 999)))

;;; 以下是枚举.jpg
(define other-code 0)
(define param-invalid-code 1)
(define no-user-code 101)
(define no-group-code 102)
(define no-emoji-code 103)
(define auth-user-code 201)

(define error-msg-hash
  (make-hash `((,param-invalid-code . "请求参数不正确")
               (,no-user-code . "找不到用户")
               (,no-group-code . "找不到分组")
               (,no-emoji-code . "找不到表情")
               (,auth-user-code . "你他妈的谁啊！"))))

(define/contract (->http-code code)
  (-> integer? (integer-in 100 999))
  (cond
    [(= param-invalid-code 403)]
    [(= no-user-code code) 404]
    [(= no-group-code code) 404]
    [(= no-emoji-code code) 404]
    [(= auth-user-code code) 403]
    [else 500]))

(define/contract (->http-msg code)
  (-> integer? string?)
  (hash-ref error-msg-hash
            code
            "未知错误"))

(define/contract (pack code)
  (-> integer? error:box/c)
  (let ([status (->http-code code)]
        [body (->http-msg code)])
    (error:box code body status)))

;;; 抛出错误
(define/contract (throw code)
  (-> integer? any)
  (raise (pack code)))

;;; 强制取值，若为空，抛出错误。
(define/contract (unwrap-maybe v e)
  (-> (or/c #f any/c) integer? any/c)
  (or v (throw e)))

;;; 渲染出错误信息，总觉着不应该写在这里。
(define/contract (send/error e)
  (-> error:box/c response?)
  (let ([body (make-hash `((err . ,(error:box-body e))
                           (code . ,(error:box-code e))))]
        [http-code (error:box-status e)])
    (response/full http-code
                   #""
                   (current-seconds)
                   #"application/json"
                   empty
                   (list (jsexpr->bytes body)))))
