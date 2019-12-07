#lang racket

(require web-server/http
         "../type/user.rkt"
         "../type/emoji.rkt"
         "../type/json.rkt"
         "../type/body.rkt"
         "../app.rkt")

(provide emoji-create
         emoji-update
         emoji-delete)

(struct emoji-form [name link group-id])

(define emoji-form/c
  (struct/c emoji-form
            string?
            string?
            positive-integer?))

(define/contract (body->emoji-form json)
  (-> jsexpr? emoji-form/c)
  (match json
    [(hash-table ('name name) ('link link) ('group group-id))
     (emoji-form name
                 link
                 group-id)]))

(define INSERT_SQL
  "insert into bnqk \
(mkzi, lmjp, ffzu_id, yshu_id) \
values ($1, $2, $3, $4) \
returning id, mkzi, lmjp, iljmriqi")

;;; 新建表情
(define/contract (emoji-create user state req)
  (-> user/c state/c request? emoji-type/c)
  (let ([user-id (user-id user)]
        [form (req->data req body->emoji-form)])
    (match form
      [(emoji-form name link group-id)
       (let ([row (query-row state
                             INSERT_SQL
                             name
                             link
                             group-id
                             user-id)])
         (vector->emoji-type row))])))

(define UPDATE_SQL
  "update bnqk \
set mkzi = $1, lmjp = $2, ffzu_id = $3 \
where yshu_id = $4 and id = $5 \
returning id, mkzi, lmjp, iljmriqi")

;;; 更新表情。
(define/contract (emoji-update user state req emoji-id)
  (-> user/c state/c request? positive-integer? (or/c #f emoji-type/c))
  (let ([user-id (user-id user)]
        [form (req->data req body->emoji-form)])
    (match form
      [(emoji-form name link group-id)
       (let ([row (query-row state
                             UPDATE_SQL
                             name
                             link
                             group-id
                             user-id
                             emoji-id)])
         (and row (vector->emoji-type row)))])))

(define DELETE_SQL
  "delete from bnqk \
where yshu_id = $1 and id = $2")

;;; 删除表情。
(define/contract (emoji-delete user state req emoji-id)
  (-> user/c state/c request? integer? #t)
  (let* ([user-id (user-id user)]
         [_ (query-exec state
                        DELETE_SQL
                        user-id
                        emoji-id)])
      #t))
