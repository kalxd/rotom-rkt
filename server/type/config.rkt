#|老子的配置文件|#

#lang racket

(provide (except-out (all-defined-out)
                     get))

(struct db-config [host user password database]
  #:transparent)

(define (hash->db-config json)
  (match json
    [(hash-table ('host host)
                 ('user user)
                 ('password password)
                 ('database database))
     (db-config host user password database)]))

(struct app-config [host port db]
  #:transparent)

(define/contract pref-file
  path-for-some-system?
  (let ([dir (find-system-path 'pref-dir)])
    (build-path dir "rotom.rktd")))

(define/contract (get key)
  (-> symbol? (or/c #f any/c))
  (get-preference key (const #f) 'timestamp pref-file))

(define/contract def-app-config
  app-config?
  (let ([host (get 'host)]
        [port (get 'port)]
        [database (hash->db-config (get 'database))])
    (app-config host port database)))
