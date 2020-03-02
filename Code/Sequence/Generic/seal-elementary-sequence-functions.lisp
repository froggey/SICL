(cl:in-package #:sicl-sequence)

(seal-domain #'elt '(list t))
(seal-domain #'elt '(vector t))
(seal-domain #'(setf elt) '(t list t))
(seal-domain #'(setf elt) '(t vector t))
(seal-domain #'length '(list))
(seal-domain #'length '(vector))
(seal-domain #'adjust-sequence '(list t))
(seal-domain #'adjust-sequence '(vector t))
(seal-domain #'make-sequence-like '(list t))
(seal-domain #'make-sequence-like '(vector t))
