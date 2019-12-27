#lang racket

(require "../type/user.rkt"
         "../type/error.rkt"
         "../app.rkt")

(provide (except-out (all-defined-out)
                     row->user))

(define/contract (row->user rs)
  (-> vector? 用户/c)
  (match rs
    [(vector id name) (用户结构 id name)]))

;;; 查找用户
(define/contract (根据token查找 state token)
  (-> state/c string? (or/c #f 用户/c))
  (let ([row (query-maybe-row state "select id, 用户名 from 用户_视图 where token = $1" token)])
    (and row (row->user row))))
