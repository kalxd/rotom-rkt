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
id, mkzi, iljmriqi \
from ffzu \
where yshu_id = $1
order by id")

;;; 获取分组列表。
(define/contract (group-list user state req)
  (-> user/c state/c request? (listof group-type/c))
  (let* ([user-id (user-id user)]
         [rows (query-rows state
                           GROUP_LIST_SQL
                           user-id)])
    (map vector->group-type rows)))


(struct group-form [name])

(define/contract (body->group-form json)
  (-> jsexpr? (struct/c group-form string?))
  (match json
    [(hash-table ('name name))
     (group-form name)]))

;;; 新建分组
(define/contract (group-create user state req)
  (-> user/c state/c request? group-type/c)
  (let* ([data (req->data req body->group-form)]
         [name (group-form-name data)]
         [user-id (user-id user)])
    (begin
      (let ([r (query-row state
                          "insert into ffzu (mkzi, yshu_id) values ($1, $2) returning id, mkzi, iljmriqi"
                          name
                          user-id)])
        (vector->group-type r)))))

;;; 更新分组
(define/contract (group-update user state req id)
  (-> user/c state/c request? positive-integer? (or/c #f group-type/c))
  (let ([user-id (user-id user)]
        [data (req->data req body->group-form)])
    (begin
      (define r
        (query-maybe-row state
                   "update ffzu set mkzi = $1 where id = $2 and yshu_id = $3 returning id, mkzi, iljmriqi"
                   (group-form-name data)
                   id
                   user-id))
      (and r (vector->group-type r)))))

(define GROUP_EMOJI_SQL
  "select \
id, mkzi, lmjp, iljmriqi \
from bnqk \
where ffzu_id = $1 and yshu_id = $2")

;;; 某组下所有表情。
(define/contract (group-emoji-list user state req group-id)
  (-> user/c state/c request? integer? (listof emoji-type/c))
  (let* ([user-id (user-id user)]
         [rows (query-rows state
                           GROUP_EMOJI_SQL
                           group-id
                           user-id)])
    (map vector->emoji-type rows)))
