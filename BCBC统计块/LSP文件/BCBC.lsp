(defun C:BCBC (/ ss blkdict blkname count i ent obj msg)
  (vl-load-com)
  (princ "\n请选择要统计的块对象...")
  ; 获取用户框选的对象集合
  (setq ss (ssget '((0 . "INSERT"))))
  (if ss
    (progn
      ; 初始化块统计字典
      (setq blkdict '())
      ; 遍历选择集
      (setq i 0)
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
        ; 将图元转换为VLA对象
        (setq obj (vlax-ename->vla-object ent))
        ; 获取块参照的实际名称
        (setq blkname (vla-get-effectivename obj))
        ; 统计块数量
        (if (assoc blkname blkdict)
          (setq blkdict 
            (subst 
              (cons blkname (+ (cdr (assoc blkname blkdict)) 1))
              (assoc blkname blkdict)
              blkdict
            )
          )
          (setq blkdict (cons (cons blkname 1) blkdict))
        )
        (setq i (1+ i))
      )
      ; 按数量排序（从高到低）
      (setq blkdict 
        (vl-sort blkdict 
          '(lambda (a b) (> (cdr a) (cdr b)))
        )
      )
      ; 构建统计结果字符串（仅统计结果）
      (setq msg "")
      (foreach blk blkdict
        (setq msg (strcat msg (car blk) "  " (itoa (cdr blk)) "\n"))
      )
      ; 使用弹窗显示结果
      (alert msg)
    )
    (princ "\n未选择任何块！")
  )
  (princ)
)