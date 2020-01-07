#|杂货铺，不知放哪儿的东西都可以扔在这里。|#
#lang racket

(require "./json.rkt")

(provide (all-defined-out))

(module+ test
  (require quickcheck
           rackunit/quickcheck))

;;; 固定数组长度。
(define/contract (vector-size/c n)
  (-> positive-integer? flat-contract?)
  (let ([length/c (λ (xs) (= n (vector-length xs)))]
        [name (format "vector-size/c/~a" n)])
    (flat-named-contract (string->symbol name)
                         (and/c vector? length/c))))

(module+ test
  (define check:prop:ok
    (property
     ([n arbitrary-natural])
     (==> (not (zero? n))
          (let ([xs (make-vector n)])
            (begin
              (define/contract (f xs)
                (-> (vector-size/c n) void?)
                (void))
              (void? (f xs)))))))
  (check-property check:prop:ok)

  (define check:prop:no
    (property
     ([n arbitrary-natural]
      [m arbitrary-natural])
     (==> (and (not (or (zero? n)
                        (zero? m)))
               (not (= m n)))
          (let ([xs (make-vector m)])
            (begin
              (define/contract (f xs)
                (-> (vector-size/c n) void?)
                (void))
              (with-handlers
                ([exn:fail:contract? (const #t)])
                (f xs)))))))
  (check-property check:prop:no))

;;; 一个请求最后结果。
;;; 部分操作仅返回boolean，我们就可以用它包裹。
(struct 结果结构 [状态]
  #:transparent

  #:methods gen:ToJSON
  [(define (->jsexpr 结果)
     (match 结果
       [(结果结构 状态)
        (make-hash `((结果 . ,状态)))]))])

(define 结果/c
  (struct/c 结果结构 boolean?))

(define/contract 好结果
  结果/c
  (结果结构 #t))

(define/contract 坏结果
  结果/c
  (结果结构 #f))

(define/contract 这个结果
  (-> boolean? 结果/c)
  结果结构)
