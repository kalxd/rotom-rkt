#lang racket

(require "../type/user.rkt"
         "../type/error.rkt"
         "../app.rkt")

(provide (except-out (all-defined-out)
                     row->user))

(define/contract (row->user rs)
  (-> vector? user/c)
  (match rs
    [(vector id name) (user id name)]))

;;; 查找用户
(define/contract (find-by-token state token)
  (-> state/c string? (or/c #f user/c))
  (let ([row (query-maybe-row state "select id, mkzi from yshu_view where token = $1" token)])
    (and row (row->user row))))
