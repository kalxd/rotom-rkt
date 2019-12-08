#|老子的配置文件|#

#lang racket

(require racket/hash
         json)

(provide (all-defined-out))

(struct db-config [host user password database]
  #:transparent)

(define (json->db-config json)
  (match json
    [(hash-table ('host host)
                 ('user user)
                 ('password password)
                 ('database database))
     (db-config host user password database)]))

(struct app-config [port db]
  #:transparent)

(define (json->app-config json)
  (match json
    [(hash-table ('port port) ('db db))
     (let ([db (json->db-config db)])
       (app-config port db))]))

(define/contract read-config
  (-> input-port? app-config?)
  (compose json->app-config read-json))
