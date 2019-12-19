#lang racket

(require web-server/http/response-structs
         "./json.rkt")

(provide 错误结构?

         用户未找到
         分组未找到
         表情未找到
         未认证用户
         不属于你
         参数格式不正确
         未知错误
         抛出错误信息)

(struct 错误结构 [错误码 内容 网络码]
  #:methods gen:ToJSON
  [(define (->jsexpr 错误)
     (let ([错误码 (错误结构-错误码 错误)]
           [内容 (错误结构-内容 错误)])
       (make-hash `((错误码 . ,错误码)
                    (内容 . ,内容)))))])

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

;;; 渲染出错误信息，总觉着不应该写在这里。
(define/contract (发送/错误 错误)
  (-> 错误结构? response?)
  (response/full (错误结构-网络码 错误)
                 #""
                 (current-seconds)
                 #"application/json"
                 empty
                 (list (json->byte 错误))))

(module+ test
  (require quickcheck
           rackunit/quickcheck)

  (define 所有错误
    (list 用户未找到
          分组未找到
          表情未找到
          未认证用户
          不属于你
          参数格式不正确))

  (define code:prop
    (property
     ([任一错误 (choose-one-of 所有错误)])
     (let ([结果 (发送/错误 任一错误)])
       (= (response-code 结果)
          (错误结构-网络码 任一错误)))))
  (check-property code:prop))
