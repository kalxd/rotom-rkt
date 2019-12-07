#lang racket

(require web-server/http
         "../type/user.rkt"
         "../type/emoji.rkt"
         "../type/json.rkt"
         "../type/body.rkt"
         "../app.rkt")

(provide emoji-create)

(struct emoji-create-form [name link group-id])

(define emoji-create-form/c
  (struct/c emoji-create-form
            string?
            string?
            positive-integer?))

(define/contract (body->emoji-create-form json)
  (-> jsexpr? emoji-create-form/c)
  (match json
    [(hash-table ('name name) ('link link) ('group group-id))
     (emoji-create-form name
                        link
                        group-id)]))

(define INSERT_SQL
  "insert into bnqk \
(mkzi, lmjp, ffzu_id, yshu_id) \
values ($1, $2, $3, $4) \
returning id, mkzi, lmjp, iljmriqi")

(define/contract (emoji-create user state req)
  (-> user/c state/c request? emoji-type/c)
  (let ([user-id (user-id user)]
        [form (req->data req body->emoji-create-form)])
    (match form
      [(emoji-create-form name link group-id)
       (let ([row (query-row state
                             INSERT_SQL
                             name
                             link
                             group-id
                             user-id)])
         (vector->emoji-type row))])))
