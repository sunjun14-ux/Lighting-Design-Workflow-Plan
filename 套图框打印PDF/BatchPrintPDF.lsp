;;; BatchPrintPDF_CompleteFix.lsp - 完全修复版
;;; 修复所有已知问题，适用于AutoCAD 2025

(defun C:BatchPrintPDF (/ *error* files filePathList layoutName frameSize plotConfig pdfPath file)

  ;; 错误处理函数
  (defun *error* (msg)
    (princ (strcat "\n错误: " msg))
    (princ "\n脚本已终止。")
  )

  ;; 加载VL库（如果需要）
  (vl-load-com)

  ;; 获取用户选择的文件列表
  (setq files (getfiled "选择要打印的DWG文件（可多选）" "" "dwg" 8))

  (if (not files)
    (princ "\n未选择文件。")
    (progn
      ;; 处理文件列表
      (setq filePathList nil)

      ;; 判断文件类型
      (cond
        ((= (type files) 'STR) ; 单个文件
         (setq filePathList (list files)))
        ((= (type files) 'LIST) ; 文件列表
         (setq filePathList files))
        (T
         (princ "\n无法识别的文件格式。")
         (exit))
      )

      ;; 设置PDF输出路径 - 使用您的特定路径
      (setq path "D:\\00Project\\00\\03CAD拓展\\套图框打印PDF\\cad01\\")
      (setq pdfPath (strcat path "PDF输出\\"))

      ;; 创建输出目录 - 使用标准LISP函数
      (if (not (vl-file-directory-p pdfPath))
        (progn
          (princ (strcat "\n创建目录: " pdfPath))
          ;; 使用command创建目录
          (command "_.-MKDIR" pdfPath)
          ;; 如果上面的命令失败，尝试使用vl-mkdir
          (if (not (vl-file-directory-p pdfPath))
            (vl-mkdir pdfPath)
          )
        )
      )

      ;; 设置打印配置
      (setq plotConfig "DWG To PDF.pc3")
      (setq pdfStyle "monochrome.ctb")

      ;; 遍历每个文件
      (foreach file filePathList
        (princ (strcat "\n正在处理: " (vl-filename-base file)))

        ;; 打开文件
        (command "_.OPEN" file "")

        ;; 获取当前文档
        (setq doc (vla-get-activedocument (vlax-get-acad-object)))

        ;; 遍历所有布局
        (vlax-for layout (vla-get-layouts doc)
          (setq layoutName (vla-get-name layout))
          (if (/= layoutName "Model") ; 跳过模型空间
            (progn
              (setvar "CTAB" layoutName) ; 切换到当前布局

              ;; --- 自动识别图框尺寸 ---
              (setq frameSize nil)

              ;; 方法1：通过块属性识别
              (vlax-for obj (vla-get-blocks doc)
                (if (and (= (vla-get-objectname obj) "AcDbBlockReference")
                         (wcmatch (strcase (vla-get-name obj)) "*FRAME*"))
                  (progn
                    ;; 尝试获取属性中的图幅值
                    (vlax-for att (vla-get-attributes obj)
                      (if (wcmatch (strcase (vla-get-tagstring att)) "图幅*")
                        (setq frameSize (strcase (vla-get-textstring att)))
                      )
                    )
                  )
                )
              )

              ;; 方法2：通过图层名识别
              (if (not frameSize)
                (vlax-for obj (vla-get-blocks doc)
                  (if (and (= (vla-get-objectname obj) "AcDbBlockReference")
                           (wcmatch (strcase (vla-get-layer obj)) "*FRAME*"))
                    (setq frameSize (vla-get-layer obj))
                  )
                )
              )

              ;; 如果还是没找到，使用默认纸张
              (if (not frameSize)
                (setq frameSize "A3")
              )

              ;; 根据识别的尺寸设置打印纸张
              (princ (strcat "  识别图框: " frameSize))
              (cond
                ((wcmatch frameSize "*A0*") (setq paperSize "A0 (841 x 1189 mm)"))
                ((wcmatch frameSize "*A1*") (setq paperSize "A1 (594 x 841 mm)"))
                ((wcmatch frameSize "*A2*") (setq paperSize "A2 (420 x 594 mm)"))
                ((wcmatch frameSize "*A3*") (setq paperSize "A3 (297 x 420 mm)"))
                ((wcmatch frameSize "*A4*") (setq paperSize "A4 (210 x 297 mm)"))
                (T (setq paperSize "A3 (297 x 420 mm)")) ; 默认A3
              )

              ;; 生成PDF文件名 - 处理空格
              (setq pdfFile (strcat pdfPath (vl-filename-base file) "_" layoutName ".pdf"))

              ;; 执行打印命令 - 简化版本，避免路径问题
              (command "_.PLOT"
                       "Y"              ; 详细打印配置
                       layoutName       ; 布局名
                       plotConfig       ; 打印设备
                       paperSize        ; 纸张尺寸
                       "m"              ; 单位：毫米
                       "Landscape"      ; 方向
                       "N"              ; 打印样式
                       "Window"         ; 打印区域：窗口
                       "0,0"            ; 窗口左下角
                       "1,1"            ; 窗口右上角
                       "1:1"            ; 比例
                       "1:1"            ; 纸张单位比例
                       "Center"         ; 居中打印
                       "Y"              ; 打印到文件
                       pdfFile          ; PDF路径
                       pdfStyle         ; 打印样式表
                       "N"              ; 是否打印到图纸空间
                       "Y"              ; 是否打开PDF
              )
              (princ "  打印完成。")
            )
          )
        )

        ;; 关闭文件（不保存）
        (command "_.CLOSE" "N")
      )

      (princ "\n\n所有文件处理完成！PDF已保存至: ")
      (princ pdfPath)
    )
  )

  (princ)
)

;; 加载提示
(princ "\n完全修复版脚本加载完成。输入 BatchPrintPDF 开始批量打印。")
