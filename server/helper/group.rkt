#lang racket

(require web-server/http
         "../type/json.rkt"
         "../type/group.rkt"
         "../type/emoji.rkt"
         "../type/body.rkt"
         "../type/user.rkt"
         "../app.rkt")

(provide group-list
         group-create
         group-update
         group-emoji-list)

(define GROUP_LIST_SQL
  "select \
id, 名字, 用户id, 创建日期 \
from 分组 \
where 用户id = $1
order by id")

;;; 获取分组列表。
(define/contract (group-list 用户 state req)
  (-> 用户/c state/c request? (listof 分组/c))
  (let* ([用户id (用户结构-id 用户)]
         [rows (query-rows state GROUP_LIST_SQL 用户id)])
    (map vector->分组 rows)))

(struct group-form [name])

(define/contract (body->group-form json)
  (-> jsexpr? (struct/c group-form string?))
  (match json
    [(hash-table ('name name))
     (group-form name)]))

;;; 新建分组
(define/contract (group-create user state req)
  (-> 用户/c state/c request? 分组/c)
  (let* ([data (请求->对应数据 req body->group-form)]
         [name (group-form-name data)]
         [user-id (用户结构-id user)])
    (begin
      (let ([r (query-row state
                          "insert into ffzu (mkzi, yshu_id) values ($1, $2) returning id, mkzi, iljmriqi"
                          name
                          user-id)])
        (vector->分组 r)))))

;;; 更新分组
(define/contract (group-update user state req id)
  (-> 用户/c state/c request? positive-integer? (or/c #f 分组/c))
  (let ([user-id (用户结构-id user)]
        [data (请求->对应数据 req body->group-form)])
    (begin
      (define r
        (query-maybe-row state
                   "update ffzu set mkzi = $1 where id = $2 and yshu_id = $3 returning id, mkzi, iljmriqi"
                   (group-form-name data)
                   id
                   user-id))
      (and r (vector->分组 r)))))

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
