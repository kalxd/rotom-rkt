#lang racket

(require web-server/http
         "../type/json.rkt"
         "../type/group.rkt"
         "../type/emoji.rkt"
         "../type/body.rkt"
         "../type/user.rkt"
         "../app.rkt")

(provide 分组/列表
         分组/创建
         分组/更新
         group-emoji-list)

(define GROUP_FIELD_LIST
  (string-join '("id" "名字" "用户id" "创建日期")
               ", "))

;;; 获取分组列表。
(define GROUP_LIST_SQL
  (format "select \
~a \
from 分组 \
where 用户id = $1 \
order by id"
          GROUP_FIELD_LIST))

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
returning ~a" GROUP_FIELD_LIST))

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
returning ~a"
          GROUP_FIELD_LIST))

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
    (and row (vector->分组 row))))

(define GROUP_EMOJI_SQL
  "select \
id, mkzi, lmjp, iljmriqi \
from bnqk \
where ffzu_id = $1 and yshu_id = $2")

;;; 某组下所有表情。
(define/contract (group-emoji-list user state req group-id)
  (-> 用户/c state/c request? integer? (listof emoji-type/c))
  (let* ([user-id (用户结构-id user)]
         [rows (query-rows state
                           GROUP_EMOJI_SQL
                           group-id
                           user-id)])
    (map vector->emoji-type rows)))
