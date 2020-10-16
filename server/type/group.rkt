#lang racket

(require racket/generic
         "./rotom.rkt"
         "./json.rkt"
         "./moment.rkt"
         "./user.rkt"
         "./error.rkt"
         "../app.rkt")

(provide (all-defined-out))

(define GROUP_FIELD_LIST
  (string-join '("id" "名字" "用户id" "创建日期")
               ", "))

;;; 数量子查询
(define EMOJI_COUNT_SUB_QUERY
  "(select count(*) from 表情 where 表情.分组id = 分组.id) as 数量")

;;; 分组基本信息。
(struct 分组结构 [id 名字 用户id 创建日期 数量]
  #:methods gen:ToJSON
  [(define/generic -->jsexpr ->jsexpr)
   (define (->jsexpr self)
     (match self
       [(分组结构 id 名字 用户id 创建日期 数量)
        (make-hash `((id . ,id)
                     (名字 . ,名字)
                     (用户id . ,用户id)
                     (创建日期 . ,(-->jsexpr 创建日期))
                     (数量 . ,数量)))]))])

(define 分组/c
  (struct/c 分组结构
            positive-integer?
            string?
            positive-integer?
            sql-moment/c
            positive-integer?))

(define/contract (vector->分组 xs)
  (-> (vector-size/c 5) 分组/c)
  (match xs
    [(vector id 名字 用户id 日期 数量)
     (分组结构 id 名字 用户id (sql-timestamp->sql-moment 日期) 数量)]))

(define/contract (查找用户的一个分组 state 用户 id)
  (-> state/c 用户/c positive-integer? (or/c #f 分组/c))
  (let ([sql (format "select ~a, ~a from 分组 where id = $1 and 用户id = $2"
                     GROUP_FIELD_LIST
                     EMOJI_COUNT_SUB_QUERY)]
        [用户id (用户结构-id 用户)])
    (begin
      (define row (query-maybe-row state sql id 用户id))
      (and row (vector->分组 row)))))

(define/contract (得到用户的一个分组 state 用户 id)
  (-> state/c 用户/c positive-integer? 分组/c)
  (define 分组 (查找用户的一个分组 state 用户 id))
  (unless 分组 (raise 分组未找到))
  分组)
