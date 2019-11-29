#lang racket

(require web-server/http
         "../type/group.rkt"
         "../app.rkt")

(provide (all-defined-out))

#|分组|#

(define/contract (group-list state req)
  (-> state/c request? (listof group-type/c))
  (let ([rows (query-rows state "select id, mkzi from ffzu order by id")])
    (map vector->group-type rows)))
