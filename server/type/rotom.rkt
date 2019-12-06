#|杂货铺，不知放哪儿的东西都可以扔在这里。|#
#lang racket

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
