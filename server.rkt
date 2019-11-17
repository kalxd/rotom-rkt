#lang racket

(require web-server/http)

(module+ test
  (require quickcheck)
  (require rackunit/quickcheck))

(define/contract (find-header-rotom headers)
  (-> (listof header?) (or/c #f bytes?))
  (let* ([f (λ (header) (equal? (header-field header) #"rotom"))]
         [header (findf f headers)])
    (and header (header-value header))))

(module+ test
  (define find-header-rotom:yes
    (property
     ([s arbitrary-string])
     (let* ([ver (string->bytes/utf-8 s)]
            [headers (list (make-header #"rotom" ver))])
       (equal? ver (find-header-rotom headers)))))
  (check-property find-header-rotom:yes)

  (define find-header-rotom:no
    (property
     ([k arbitrary-ascii-string]
      [v arbitrary-string])
     (let ([key (string->bytes/latin-1 k)]
           [value (string->bytes/utf-8 v)])
       (==> (not (equal? #"rotom" key))
            (let ([headers (list (make-header key value))])
              (false? (find-header-rotom headers)))))))
  (check-property find-header-rotom:no))

(define/contract (rotom-ver req)
  (-> request? (or/c #f bytes?))
  (let* ([headers (request-headers/raw req)]
         [findp (λ (key . value) (equal? key "rotom"))]
         [ver (findf findp headers)])
    (or ver (last ver))))

(define/contract (check-req-rotom req)
  (-> request? boolean?)
  #f)
