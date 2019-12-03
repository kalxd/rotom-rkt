#lang racket

(require web-server/http
         "../type/json.rkt"
         "../type/group.rkt"
         "../type/body.rkt"
         "../type/user.rkt"
         "../app.rkt")

(provide group-list
         group-create)

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
