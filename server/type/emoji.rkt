#lang racket

(require racket/generic
         "./rotom.rkt"
         "./json.rkt"
         "./moment.rkt"
         "./state.rkt"
         "./user.rkt"
         "./error.rkt"
         "../app.rkt")

(provide (except-out (all-defined-out)
                     FIELD_LIST
                     FIND_BY_USER_SQL))

(define FIELD_LIST
  '("id" "名字" "链接" "分组id" "创建日期"))

(define EMOJI_FILED_LIST
  (string-join FIELD_LIST ", "))

(struct 表情结构 [id 名字 链接 分组id 创建日期]
  #:methods gen:ToJSON
  [(define/generic -->jsexpr ->jsexpr)
   (define (->jsexpr self)
     (match self
       [(表情结构 id 名字 链接 分组id 创建日期)
        (make-hash `((id . ,id)
                     (名字 . ,名字)
                     (链接 . ,链接)
                     (分组id . ,分组id)
                     (创建日期 . ,(-->jsexpr 创建日期))))]))])

(define 表情/c
  (struct/c 表情结构
            positive-integer?
            string?
            string?
            positive-integer?
            sql-moment/c))

(define/contract (vector->表情 row)
  (-> (vector-size/c 5) 表情/c)
  (define-values (id 名字 链接 分组id 创建日期)
    (vector->values row))
  (表情结构 id
            名字
            链接
            分组id
            (sql-timestamp->sql-moment 创建日期)))

(define FIND_BY_USER_SQL
  (let* ([field-list (map (λ (x) (format "表情.~a" x)) FIELD_LIST)]
         [field-list (string-join field-list ", ")])
    (format "select ~a from 表情 \
join 分组 \
on 表情.分组id = 分组.id and 表情.id = $1 and 分组.用户id = $2 \
order by 表情.id limit 1"
            field-list)))

(define/contract (查找用户的一个表情 state 用户 id)
  (-> state/c 用户/c positive-integer? (or/c #f 表情/c))
  (define row (query-maybe-row state
                               FIND_BY_USER_SQL
                               id
                               (用户结构-id 用户)))
  (and row (vector->表情 row)))

(define/contract (得到用户的一个表情 state 用户 id)
  (-> state/c 用户/c positive-integer? 表情/c)
  (define 表情 (查找用户的一个表情 state 用户 id))
  (unless 表情 (raise 表情未找到))
  表情)
