#lang info
(define collection "rotom-rkt")
(define deps '("base gregor"))
(define build-deps '("scribble-lib"
                     "racket-doc"
                     "rackunit-lib"
                     "quickcheck"))
(define scribblings '(("scribblings/rotom-rkt.scrbl" ())))
(define pkg-desc "自用服务。")
(define version "1.0")
(define pkg-authors '(XG.Ley))
