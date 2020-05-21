(cl:in-package #:sicl-boot-phase-7)

(defun allocate-class-prototypes (e5)
  (let ((built-in-class (sicl-genv:find-class 'built-in-class e5)))
    (do-all-symbols (symbol)
      (let ((potential-class (sicl-genv:find-class symbol e5)))
        (unless (null potential-class)
          (let ((metaclass (slot-value potential-class 'sicl-boot::%class)))
            (unless (eq metaclass built-in-class)
              (funcall (sicl-genv:fdefinition '(setf sicl-clos::class-prototype) e5)
                       (funcall (sicl-genv:fdefinition 'allocate-instance e5)
                                potential-class)
                       potential-class))))))))

