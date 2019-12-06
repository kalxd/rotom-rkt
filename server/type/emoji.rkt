#lang racket

(require racket/generic
         net/url
         "./rotom.rkt"
         "./json.rkt"
         "./moment.rkt")

(provide (all-defined-out))

(struct emoji-type [id name link create-at]
  #:methods gen:ToJSON
  [(define/generic -->jsexpr ->jsexpr)
   (define (->jsexpr self)
     (match self
       [(emoji-type id name link create-at)
        (make-hash `((id . ,id)
                     (name . ,name)
                     (link . ,(url->string link))
                     (createAt . ,(-->jsexpr create-at))))]))])

(define emoji-type/c
  (struct/c emoji-type
            positive-integer?
            string?
            url?
            sql-moment/c))

(define/contract (vector->emoji-type row)
  (-> (vector-size/c 4) emoji-type/c)
  (define-values (id name link create-at)
    (vector->values row))
  (let ([link (string->url link)]
        [create-at (sql-timestamp->sql-moment create-at)])
    (emoji-type id name link create-at)))
