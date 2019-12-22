#|这里请求body相关内容|#
#lang racket

(require web-server/http
         "./json.rkt"
         "./error.rkt")

(provide 请求->对应数据)

;;; 从一个请求中得到相对应的数据，
;;; 该功能还是得依赖异常来实现。
(define/contract (请求->对应数据 req f)
  (-> request? (-> jsexpr? any/c) any/c)
  (let ([body-data (request-post-data/raw req)])
    (begin
      (when (false? body-data) (raise 参数格式不正确))
      (with-handlers
        ([exn:fail? (λ (_) (raise 参数格式不正确))])
        (f (bytes->jsexpr body-data))))))

(module+ test
  (require quickcheck
           rackunit/quickcheck
           net/url-string)

  (define (mk-req body)
    (request #"post"
             (string->url "")
             empty
             (delay empty)
             (json->byte body)
             ""
             3000
             ""))

  (struct fd [id name]
    #:transparent)

  (define fd/1/c
    (struct/c fd integer? string?))

  (define/contract (jsexpr->fd/1 json)
    (-> jsexpr? fd/1/c)
    (match json
      [(hash-table ('id id) ('name name))
       (fd id name)]))

  ;;; 正确格式，
  ;;; 允许多个可选项。
  (define req<->fd/1:ok
    (property
     ([id arbitrary-natural]
      [name arbitrary-string]
      [other arbitrary-string])
     (let* ([body (make-hash `((id . ,id)
                               (name . ,name)
                               (other . ,other)))]
            [req (mk-req body)]
            [fd/data (请求->对应数据 req jsexpr->fd/1)])
       (and (= (fd-id fd/data) id)
            (equal? (fd-name fd/data) name)))))
  (check-property req<->fd/1:ok)

  ;;; 格式正确，类型不正确
  (define req<->fd/1:fail:type
    (property
     ([id arbitrary-string]
      [name arbitrary-string])
     (let* ([body (make-hash `((id . ,id) (name . ,name)))]
            [req (mk-req body)])
       (with-handlers
         ([错误结构? (const #t)])
         (请求->对应数据 req jsexpr->fd/1)))))
  (check-property req<->fd/1:fail:type))
