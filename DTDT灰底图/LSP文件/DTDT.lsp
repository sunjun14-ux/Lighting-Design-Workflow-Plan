(vl-load-com)
(defun c:DTDT (/ acadDoc blocks block obj ss index ent)
  (setq acadDoc (vla-get-activedocument (vlax-get-acad-object)))
  
  
  ;;; 1. 解锁所有图层并设置颜色为252
  (vlax-for layer (vla-get-layers acadDoc)
    (vla-put-Lock layer :vlax-false)   ; 解锁图层
    (vla-put-Color layer 252)          ; 设置图层颜色
  )
  
  ;;; 2. 设置所有对象颜色为随层（包含块内实体）
  (defun SetColorToByLayer (collection)
    (vlax-for obj collection
      (if (vlax-property-available-p obj 'Color)
        (vla-put-Color obj 0)          ; 0代表ByLayer
      )
    )
  )
  
  ; 处理模型空间和图纸空间
  (SetColorToByLayer (vla-get-ModelSpace acadDoc))
  (SetColorToByLayer (vla-get-PaperSpace acadDoc))
  
  ; 处理所有块定义（排除布局和外部参照）
  (setq blocks (vla-get-Blocks acadDoc))
  (vlax-for block blocks
    (if (and (= (vla-get-IsLayout block) :vlax-false)
             (= (vla-get-IsXRef block) :vlax-false))
      (SetColorToByLayer block)
    )
  )
  
  (princ "\nDTDT命令执行完毕！")
  (princ)
)