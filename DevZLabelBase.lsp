(defun c:DevZLabelMM ( / baseZ ss i ent entObj pt zfact dev txt textHeight
                          textPt acadApp doc ms objText )

  ;; Запрашиваем базовую отметку (в метрах)
  (setq baseZ (getreal "\nВведите базовую высоту (в метрах): "))
  (if (not baseZ)
    (progn (prompt "\n❌ Ошибка: не введена высота.") (exit)))

  ;; Выбор точек (POINT)
  (prompt "\nВыберите точки (объекты POINT): ")
  (setq ss (ssget '((0 . "POINT"))))
  (if (not ss)
    (progn (prompt "\n⚠️ Точки не выбраны.") (exit)))

  ;; Настройки текста
  (setq textHeight 1.5)
  (setq acadApp (vlax-get-acad-object))
  (setq doc (vla-get-ActiveDocument acadApp))
  (setq ms (vla-get-ModelSpace doc))

  ;; Перебираем все выбранные точки
  (setq i 0)
  (while (< i (sslength ss))
    (setq ent (ssname ss i))
    (setq entObj (vlax-ename->vla-object ent))
    (setq pt (vlax-get entObj 'Coordinates)) ; список (x y z)

    (setq zfact (caddr pt))
    (setq dev (* 1000.0 (- zfact baseZ))) ; отклонение в мм
    (setq txt (strcat
                (if (>= dev 0) "+" "-")
                (itoa (abs (fix dev))) ; округление до целых
                " мм"))

    ;; Положение текста — немного выше по Z
    (setq textPt (vlax-3d-point
                   (list (car pt) (cadr pt) (+ zfact 0.2))))

    ;; Создание текста
    (setq objText (vla-AddText ms txt textPt textHeight))
    (vla-put-HorizontalMode objText acTextHorzCenter)
    (vla-put-VerticalMode objText acTextVertBaseline)
    (vla-put-Alignment objText acAlignmentMiddleCenter)
    (vla-put-TextAlignmentPoint objText textPt)

    (setq i (1+ i))
  )

  (prompt (strcat "\n✅ Готово. Обработано " (itoa (sslength ss)) " точек."))
  (princ)
)
