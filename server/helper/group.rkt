#lang racket

(require web-server/http
         "../type/json.rkt"
         "../type/group.rkt"
         "../type/body.rkt"
         "../type/user.rkt"
         "../app.rkt")

(provide group-list
         group-create
         group-update)

#|分组|#

;;; 获取分组列表。
(define/contract (group-list state req)
  (-> state/c request? (listof group-type/c))
  (let ([rows (query-rows state "select id, mkzi, iljmriqi from ffzu order by id")])
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
