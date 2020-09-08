#lang racket

(require web-server/http
         (prefix-in db:: db)
         "../type/json.rkt"
         "../type/group.rkt"
         "../type/emoji.rkt"
         "../type/body.rkt"
         "../type/user.rkt"
         "../type/error.rkt"
         "../type/rotom.rkt"
         "../type/state.rkt"
         "../app.rkt")

(provide 分组/列表
         分组/创建
         分组/更新
         分组/全部清除
         分组/清除移动)

;;; 数量子查询
(define EMOJI_COUNT_SUB_QUERY
  "(select count(*) from 表情 where 表情.分组id = 分组.id) as 数量")

;;; 获取分组列表。
(define GROUP_LIST_SQL
  (format "select \
~a, ~a
from 分组 \
where 用户id = $1 \
order by id"
          GROUP_FIELD_LIST
          EMOJI_COUNT_SUB_QUERY))

(define/contract (分组/列表 用户 state req)
  (-> 用户/c state/c request? (listof 分组/c))
  (let* ([用户id (用户结构-id 用户)]
         [rows (query-rows state GROUP_LIST_SQL 用户id)])
    (map vector->分组 rows)))

(struct 分组form [名字])

(define/contract (body->分组form json)
  (-> jsexpr? (struct/c 分组form string?))
  (match json
    [(hash-table ('名字 name))
     (分组form name)]))

(define GROUP_CREATE_SQL
  (format "insert into 分组 \
(名字, 用户id) \
values \
($1, $2) \
returning ~a, 0" GROUP_FIELD_LIST))

;;; 新建分组
(define/contract (分组/创建 user state req)
  (-> 用户/c state/c request? 分组/c)
  (let* ([data (请求->对应数据 req body->分组form)]
         [name (分组form-名字 data)]
         [user-id (用户结构-id user)])
    (begin
      (let ([r (query-row state
                          GROUP_CREATE_SQL
                          name
                          user-id)])
        (vector->分组 r)))))

(define GROUP_UPDATE_SQL
  (format "update 分组 \
set 名字 = $1 \
where id = $2 and 用户id = $3 \
returning ~a, ~a"
          GROUP_FIELD_LIST EMOJI_COUNT_SUB_QUERY))

;;; 更新分组
(define/contract (分组/更新 用户 state req id)
  (-> 用户/c state/c request? positive-integer? (or/c #f 分组/c))
  (let* ([用户id (用户结构-id 用户)]
         [data (请求->对应数据 req body->分组form)]
         [名字 (分组form-名字 data)]
         [row (query-maybe-row state
                               GROUP_UPDATE_SQL
                               名字
                               id
                               用户id)])
    (begin
      (unless row (raise 不属于你))
      (vector->分组 row))))

;;; 删除分组、包括内部所有表情。
(define/contract (分组/全部清除 用户 state req id)
  (-> 用户/c state/c request? positive-integer? 结果/c)
  (得到用户的一个分组 state 用户 id)
  (let ([conn (ask-connection state)])
    (db::call-with-transaction
     conn
     (λ ()
       (db::query-exec conn "delete from 表情 where 分组id = $1" id)
       (db::query-exec conn "delete from 分组 where id = $1" id)
       好结果))))

(struct 移动form [下个id])

(define/contract (body->移动form body)
  (-> jsexpr? (struct/c 移动form positive-integer?))
  (match body
    [(hash-table ('下个分组id id))
     (移动form id)]))

;;; 删除分组，移动组内表情
(define/contract (分组/清除移动 用户 state req id)
  (-> 用户/c state/c request? positive-integer? 结果/c)
  (let ([用户id (用户结构-id 用户)]
        [data (请求->对应数据 req body->移动form)])
    (begin
      (displayln data)
      (define 下个分组id (移动form-下个id data))
      (得到用户的一个分组 state 用户 id)
      (得到用户的一个分组 state 用户 下个分组id)
      (let ([conn (ask-connection state)])
        (db::call-with-transaction
         conn
         (λ ()
           (db::query-exec conn
                           "update 表情 set 分组id = $1 where 分组id = $2"
                           下个分组id
                           id)
           (db::query-exec conn "delete from 分组 where id = $1" id)
           好结果))))))
