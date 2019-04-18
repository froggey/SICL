(cl:in-package #:cleavir-cst-to-ast)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; CONVERT is responsible for converting a concrete syntax tree to an
;;; abstract syntax tree.

(defmethod convert (client cst environment)
  (let ((form (cst:raw cst)))
    (cond ((and (not (consp form)) (not (symbolp form)))
           (convert-constant cst environment client))
          ((and (symbolp form) (constantp form))
           (let* ((value (symbol-value form))
                  (value-cst (cst:cst-from-expression value)))
             (convert-constant value-cst environment client)))
          ((symbolp form)
           (convert-variable cst environment form))
          ((symbolp (car form))
           ;; Even if we are in COMPILE-TIME-TOO mode, at this point, we
           ;; do not know whether to evaluate the form at compile time,
           ;; simply because it might be a special form that is handled
           ;; specially.  So we must wait until we have more
           ;; information.
           (let ((info (function-info environment (car form))))
             (convert-cst cst info environment client)))
          (t
           ;; The form must be a compound form where the CAR is a lambda
           ;; expression.  Evaluating such a form might have some
           ;; compile-time side effects, so we must check whether we are
           ;; in COMPILE-TIME-TOO mode, in which case we must evaluate
           ;; the form as well.
           (when (and *current-form-is-top-level-p* *compile-time-too*)
             (cleavir-env:eval form environment environment))
           (convert-lambda-call cst environment client)))))

(defmethod convert :around (client cst environment)
  (declare (ignore cst client))
  (let ((*current-form-is-top-level-p* *subforms-are-top-level-p*)
        (*subforms-are-top-level-p* nil))
    (call-next-method)))