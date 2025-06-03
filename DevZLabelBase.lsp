(defun c:DevZLabelBase ( / ss i ent pt zfact baseZ dev textPt txt textHeight sign)
  ;; Ввод базовой высоты (проектной отметки)
  (setq baseZ (getreal "\nВведите базовую высоту (проектную отметку): "))

  (if (null baseZ)
    (progn
      (prompt "\n❌ Неверный ввод.")
      (exit)
    )
  )

  ;; Выбор блоков (крестов)
  (prompt "\nВыберите блоки-точки (кресты): ")
  (setq ss (ssget '((0 . "INSERT"))))

  ;; Высота текста
  (setq textHeight 1.5)

  (if ss
    (progn
      (setq i 0)
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
        (setq pt (cdr (assoc 10 (entget ent)))) ; точка вставки
        (setq zfact (caddr pt)) ; Фактическая высота

        ;; Вычисление отклонения
        (setq dev (- zfact baseZ))

        ;; Форматирование текста с +/-
        (setq sign (if (>= dev 0) "+" "-"))
        (setq txt (strcat sign (rtos (abs dev) 2 3) " м"))

        ;; Координата для текста чуть выше блока (+0.2 по Z)
        (setq textPt (list (car pt) (cadr pt) (+ zfact 0.2)))

        ;; Создание текста
        (entmakex
          (list
            (cons 0 "TEXT")
            (cons 10 textPt)
            (cons 40 textHeight)
            (cons 1 txt)
            (cons 7 "Standard") ; стиль текста
            (cons 8 "Отклонения") ; слой (создай или поменяй)
            (cons 50 0.0)
            (cons 72 1) ; центрирование
            (cons 73 0)
          )
        )

        (setq i (1+ i))
      )
    )
    (prompt "\n⚠️ Блоки не выбраны.")
  )
  (princ)
)
