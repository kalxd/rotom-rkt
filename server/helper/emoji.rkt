#lang racket

(require web-server/http
         "../type/user.rkt"
         "../type/emoji.rkt"
         "../type/group.rkt"
         "../type/json.rkt"
         "../type/body.rkt"
         "../app.rkt")

(provide 表情/列表
         表情/创建
         表情/更新
         表情/删除)

(define SELECT_SQL
  (format "select ~a from 表情 where 分组id = $1"
          EMOJI_FILED_LIST))

;;; 列表
(define/contract (表情/列表 用户 state req 分组id)
  (-> 用户/c state/c request? positive-integer? (listof 表情/c))
  (得到用户的一个分组 state 用户 分组id)
  (define rs (query-rows state
                         SELECT_SQL
                         分组id))
  (map vector->表情 rs))

(struct 表情form [名字 链接 分组id])

(define 表情form/c
  (struct/c 表情form
            string?
            string?
            positive-integer?))

(define/contract (body->表情form json)
  (-> jsexpr? 表情form/c)
  (match json
    [(hash-table ('名字 名字) ('链接 链接) ('分组id 分组id))
     (表情form 名字
               链接
               分组id)]))

(define INSERT_SQL
  (format "insert into 表情 \
(名字, 链接, 分组id) \
values ($1, $2, $3) \
returning ~a" EMOJI_FILED_LIST))

;;; 新建表情
(define/contract (表情/创建 用户 state req)
  (-> 用户/c state/c request? 表情/c)
  (let ([用户id (用户结构-id 用户)]
        [form (请求->对应数据 req body->表情form)])
    (match form
      [(表情form 名字 链接 分组id)
       (let ([row (query-row state
                             INSERT_SQL
                             名字
                             链接
                             分组id)])
         (vector->表情 row))])))

(define UPDATE_SQL
  (format "update 表情 \
set 名字 = $1, 链接 = $2, 分组id = $3 \
where id = $4 \
returning ~a"
          EMOJI_FILED_LIST))

;;; 更新表情。
(define/contract (表情/更新 用户 state req id)
  (-> 用户/c state/c request? positive-integer? (or/c #f 表情/c))
  (得到用户的一个表情 state 用户 id)
  (let ([用户id (用户结构-id 用户)]
        [form (请求->对应数据 req body->表情form)])
    (match form
      [(表情form name link group-id)
       (let ([row (query-row state
                             UPDATE_SQL
                             name
                             link
                             group-id
                             id)])
         (and row (vector->表情 row)))])))

;;; 删除表情。
(define/contract (表情/删除 用户 state req id)
  (-> 用户/c state/c request? integer? #t)
  (得到用户的一个表情 state 用户 id)
  (begin
    (query-exec state
                "delete from 表情 where id = $1"
                id)
    #t))
