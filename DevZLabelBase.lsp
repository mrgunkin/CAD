(defun c:DevZLabelByPoints ( / baseZ ss i ent entObj pt zfact dev txt sign
                              textHeight textPt acadApp doc ms objText)
  ;; Запрос базовой высоты
  (setq baseZ (getreal "\nВведите базовую высоту (проектную отметку): "))
  (if (not baseZ)
    (progn (prompt "\n❌ Ошибка: не введена высота.") (exit))
  )

  ;; Выбор точек
  (prompt "\nВыберите объекты-точки: ")
  (setq ss (ssget '((0 . "POINT"))))
  (if (not ss)
    (progn (prompt "\n⚠️ Точки не выбраны.") (exit))
  )

  ;; Настройки
  (setq textHeight 1.5)
  (setq acadApp (vlax-get-acad-object))
  (setq doc (vla-get-ActiveDocument acadApp))
  (setq ms (vla-get-ModelSpace doc))

  ;; Перебор точек
  (setq i 0)
  (while (< i (sslength ss))
    (setq ent (ssname ss i))
    (setq entObj (vlax-ename->vla-object ent))
    (setq pt (vlax-get entObj 'Coordinates))

    ;; z-фактическая
    (setq zfact (caddr pt))

    ;; вычисление отклонения
    (setq dev (- zfact baseZ))

    ;; формат текста
    (setq sign (if (>= dev 0) "+" "-"))
    (setq txt (strcat sign (rtos (abs dev) 2 3) " м"))

    ;; точка размещения текста над исходной точкой
    (setq textPt (vlax-3d-point (list (car pt) (cadr pt) (+ zfact 0.2))))

    ;; создаём текст
    (setq objText (vla-AddText ms txt textPt textHeight))
    (vla-put-HorizontalMode objText acTextHorzCenter)
    (vla-put-VerticalMode objText acTextVertBaseline)
    (vla-put-Alignment objText acAlignmentMiddleCenter)
    (vla-put-TextAlignmentPoint objText textPt)

    (setq i (1+ i))
  )

  (prompt (strcat "\n✅ Готово. Созданы отметки по " (itoa (sslength ss)) " точкам."))
  (princ)
)
