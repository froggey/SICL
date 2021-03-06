(cl:in-package #:sicl-boot-phase-3)

(defun boot (boot)
  (format *trace-output* "Start phase 3~%")
  (with-accessors ((e2 sicl-boot:e2)
                   (e3 sicl-boot:e3)
                   (e4 sicl-boot:e4))
      boot
    (change-class e3 'environment)
    (set-up-environments boot)
    (setf (sicl-genv:fdefinition 'slot-boundp e3)
          (constantly t))
    (define-make-instance boot)
    (enable-defmethod boot)
    (define-method-on-method-function e3)
    (sicl-boot:enable-method-combinations e2 e3)
    (define-compile e3)
    (sicl-boot:define-class-of e3)
    (setf (sicl-genv:fdefinition 'typep e3)
          (lambda (object type-specifier)
            (sicl-genv:typep object type-specifier e3)))
    (sicl-boot:enable-generic-function-invocation e2 e3)
    (load-source "CLOS/standard-instance-access.lisp" e3)
    (sicl-boot:enable-defgeneric e2 e3 e4)
    (load-source "CLOS/invalidate-discriminating-function.lisp" e3)
    (sicl-boot:enable-generic-function-initialization e3)
    (sicl-boot:load-accessor-defgenerics e4)
    (enable-class-initialization boot)
    (sicl-boot:create-mop-classes e3)))
