#lang racket

(require web-server/http
         "../type/user.rkt"
         "../type/emoji.rkt"
         "../type/json.rkt"
         "../type/body.rkt"
         "../app.rkt")

(provide 表情/创建
         emoji-update
         emoji-delete)

(define EMOJI_FILED_LIST
  (string-join '("id" "名字" "链接" "分组id" "创建日期")
               ", "))

(struct 表情form [名字 链接 分组id])

(define 表情form/c
  (struct/c 表情form
            string?
            string?
            positive-integer?))

(define/contract (body->表情form json)
  (-> jsexpr? 表情form/c)
  (match json
    [(hash-table ('名字 名字) ('链接 链接) ('分组id 分组id))
     (表情form 名字
               链接
               分组id)]))

(define INSERT_SQL
  (format "insert into 表情 \
(名字, 链接, 分组id) \
values ($1, $2, $3) \
returning ~a" EMOJI_FILED_LIST))

;;; 新建表情
(define/contract (表情/创建 用户 state req)
  (-> 用户/c state/c request? 表情/c)
  (let ([用户id (用户结构-id 用户)]
        [form (请求->对应数据 req body->表情form)])
    (match form
      [(表情form 名字 链接 分组id)
       (let ([row (query-row state
                             INSERT_SQL
                             名字
                             链接
                             分组id)])
         (vector->表情 row))])))

(define UPDATE_SQL
  "update bnqk \
set mkzi = $1, lmjp = $2, ffzu_id = $3 \
where yshu_id = $4 and id = $5 \
returning id, mkzi, lmjp, iljmriqi")

;;; 更新表情。
(define/contract (emoji-update user state req emoji-id)
  (-> 用户/c state/c request? positive-integer? (or/c #f 表情/c))
  (let ([user-id (用户结构-id user)]
        [form (请求->对应数据 req body->表情form)])
    (match form
      [(表情form name link group-id)
       (let ([row (query-row state
                             UPDATE_SQL
                             name
                             link
                             group-id
                             user-id
                             emoji-id)])
         (and row (vector->表情 row)))])))

(define DELETE_SQL
  "delete from bnqk \
where yshu_id = $1 and id = $2")

;;; 删除表情。
(define/contract (emoji-delete user state req emoji-id)
  (-> 用户/c state/c request? integer? #t)
  (let* ([user-id (用户结构-id user)]
         [_ (query-exec state
                        DELETE_SQL
                        user-id
                        emoji-id)])
      #t))
