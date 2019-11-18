#lang racket

(require "../type/user.rkt"
         "../type/error.rkt"
         "../app.rkt")

(provide (all-defined-out))

;;; 查找用户
(define/contract (find-by-token state token)
  (-> state/c bytes? (or/c #f user/c))
  #f)
