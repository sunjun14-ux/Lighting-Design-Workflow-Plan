(defun c:KXMJ (/ ss total i ent obj area unit-str)
  ;; 加载ActiveX支持
  (vl-load-com)

  ;; 提示用户选择对象
  (princ "\n选择要计算面积的对象（多段线/圆/面域）: ")
  (setq ss (ssget '((0 . "LWPOLYLINE,POLYLINE,CIRCLE,REGION"))))

  ;; 如果有选择对象
  (if ss
    (progn
      (setq total 0.0
            i 0)

      ;; 遍历选择集
      (repeat (sslength ss)
        (setq ent (ssname ss i)
              obj (vlax-ename->vla-object ent))

        ;; 计算面积
        (cond
          ;; 多段线
          ((wcmatch (vla-get-objectname obj) "*Polyline")
           (if (vlax-property-available-p obj 'Area)
             (setq area (vla-get-area obj))
           )
          )
          ;; 圆
          ((= (vla-get-objectname obj) "AcDbCircle")
           (setq area (* pi (expt (vla-get-radius obj) 2)))
          )
          ;; 面域
          ((= (vla-get-objectname obj) "AcDbRegion")
           (setq area (vla-get-area obj))
          )
        )

        ;; 累加面积
        (if area
          (setq total (+ total area)
                area nil)
          (princ (strcat "\n警告：对象 " (itoa (1+ i)) " 无法计算面积"))
        )

        ;; 下一个对象
        (setq i (1+ i))
      )

      ;; 设置单位
      (setq unit-str
        (cond
          ((= (getvar "INSUNITS") 4) "平方毫米")
          ((= (getvar "INSUNITS") 6) "平方米")
          ((= (getvar "INSUNITS") 2) "平方厘米")
          (t "")
        )
      )

      ;; 输出总面积
      (princ (strcat "\n总面积 = " (rtos total) " " unit-str))
    )
    ;; 如果没有选择对象
    (princ "\n未选择有效对象")
  )

  ;; 退出
  (princ)
)