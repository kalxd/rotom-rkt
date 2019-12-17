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
         send/error

         用户未找到
         分组未找到
         表情未找到
         未认证用户
         不属于你
         参数格式不正确
         未知错误
         抛出错误信息)

;;; 错误。
;;; code：我们自己的状态码；
;;; body：输出内容。
;;; status：http状态码
(struct error:box [code body status])

(struct 错误结构 [错误码 内容 网络码])

(define 网络码/c (integer-in 100 999))

(define 错误/c
  (struct/c 错误结构
            integer?
            string?
            网络码/c))

;;; 这些都是未找到错误。
(define 用户未找到 (错误结构 101 "找不到用户。" 404))
(define 分组未找到 (错误结构 102 "找不到分组。" 404))
(define 表情未找到 (错误结构 103 "找不到表情。" 404))

;;; 这些都是不允许的操作。
(define 未认证用户 (错误结构 201 "你他妈的谁啊！" 403 ))
(define 不属于你 (错误结构 202 "操作对象不属于你。" 403))
(define 参数格式不正确 (错误结构 1 "请求参数不正确" 403))

(define/contract (未知错误 内容)
  (-> string? 错误/c)
  (错误结构 0 内容 500))

(define/contract 抛出错误信息
  (-> string? any)
  (compose raise 未知错误))

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
