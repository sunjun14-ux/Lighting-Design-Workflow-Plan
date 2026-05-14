;;; KXBK.lsp - 快速创建块的插件
(defun c:KXBK (/ ss pt blkname currentLayer)
  ;; 步骤1：输入命令后提示选择对象
  (princ "\n选择需要组成块的图形元素: ")
  (if (setq ss (ssget))  ;; 框选图形元素
    (progn
      ;; 步骤2：获取插入点
      (setq pt (getpoint "\n指定块的插入点: "))  ;; 点击屏幕设置插入点
      
      ;; 步骤3：输入块名
      (initget 1)  ;; 禁止空输入
      (setq blkname (getstring "\n输入新块的块名: "))  ;; 提示输入块名

      ;; 获取当前图层
      (setq currentLayer (getvar "CLAYER"))  ;; 获取当前图层名称

      ;; 创建块定义
      (command "-block" blkname pt ss "")  ;; 使用命令创建块

      ;; 将块插入到图中
      (command "-insert" blkname pt 1 1 0)  ;; 插入块，比例为1，旋转角度为0

      ;; 提示成功
      (princ (strcat "\n块 '" blkname "' 已成功创建并插入到当前图层 '" currentLayer "'！"))
    )
    (princ "\n未选择任何对象，操作已取消。")  ;; 未选择对象时的提示
  )
  (princ)  ;; 静默退出
)