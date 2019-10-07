(cl:in-package :sicl-cons-high)

;;;; Copyright (c) 2008 - 2015
;;;;
;;;;     Robert Strandh (robert.strandh@gmail.com)
;;;;
;;;; all rights reserved. 
;;;;
;;;; Permission is hereby granted to use this software for any 
;;;; purpose, including using, modifying, and redistributing it.
;;;;
;;;; The software is provided "as-is" with no warranty.  The user of
;;;; this software assumes any responsibility of the consequences. 

;;;; This file is part of the cons-high module of the SICL project.
;;;; See the file SICL.text for a description of the project. 
;;;; See the file cons-high.text for a description of the module.

;;; special version of last used when the second argument to
;;; last is 1. 
(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun last-1 (list)
    (unless (typep list 'list)
      (error 'must-be-list
	     :datum list
	     :name 'last))
    ;; We can use for ... on, because it uses atom to test for
    ;; the end of the list. 
    (loop for rest on list
	  do (setf list rest))
    list))

(define-compiler-macro last (&whole form list &optional (n 1))
  (if (eql n 1)
      `(last-1 ,list)
      form))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Function acons

(defun acons (key datum alist)
  (cons (cons key datum) alist))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Function pairlis

;;; The hyperspec says the consequences are undefined if the two
;;; lists do not have the same length.  We check for this situation
;;; and signal an error in that case. 

(defun pairlis (keys data &optional alist)
  (loop with result = alist
	with remaining-keys = keys
	with remaining-data = data
	until (or (atom remaining-keys) (atom remaining-data))
	do (push (cons (pop remaining-keys) (pop remaining-data)) result)
	finally (unless (and (null remaining-keys) (null remaining-data))
		  (cond ((and (atom remaining-keys) (not (null remaining-keys)))
			 (error 'must-be-proper-list
				:datum keys
				:name 'pairlis))
			((and (atom remaining-data) (not (null remaining-data)))
			 (error 'must-be-proper-list
				:datum data
				:name 'pairlis))
			(t
			 (error 'lists-must-have-the-same-length
				:list1 keys
				:list2 data
				:name 'pairlis))))
		(return result)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Function copy-alist

;;; The HyperSpec says that the argument is an alist, and 
;;; in those cases, whenever the type doesn't correspond, it
;;; is legitimate to signal an error.  However, for copy-alist,
;;; the HyperSpec also says that any object that is referred to
;;; directly or indirectly is still shared betwee the argument
;;; and the resulting list, which suggests that any element that
;;; is not a cons should just be included in the resulting
;;; list as well.  And that is what we are doing. 

;;; We use (loop for ... on ...) because it uses ATOM to test for
;;; the end of the list.  Then we check that the atom is really 
;;; null, and if not, signal a type error.

(defun copy-alist (alist)
  (loop for remaining on alist
	collect (if (consp (car remaining))
		    (cons (caar remaining) (cdar remaining))
		    (car remaining))
	finally (unless (null remaining)
		  (error 'must-be-proper-list
			 :datum alist
			 :name 'copy-alist))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Function tailp

;;; We could use (loop for ... on ...) here for consistency. 

(defun tailp (object list)
  (loop for rest = list then (cdr rest)
	until (atom rest)
	when (eql object rest)
	  return t
	finally (return (eql object rest))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Function ldiff

(defun ldiff (list object)
  (if (or (eql list object) (atom list))
      nil
      (let* ((result (list (car list)))
             (current result)
             (remaining (cdr list)))
        (loop until (or (eql remaining object) (atom remaining))
              do (setf (cdr current) (list (car remaining)))
                 (setf current (cdr current))
                 (setf remaining (cdr remaining)))
        (if (eql remaining object)
            result
            (progn (setf (cdr current) remaining)
                   result)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Function getf

(defun getf (plist indicator &optional default)
  (unless (typep plist 'list)
    (error 'must-be-property-list
	   :datum plist
	   :name 'getf))
  (loop for rest on plist by #'cddr
	do (unless (consp (cdr rest))
	     (error 'must-be-property-list
		    :datum plist
		    'getf))
	when (eq (car rest) indicator)
	  return (cadr rest)
	finally (unless (null rest)
		  (error 'must-be-property-list
		    :datum plist
		    'getf))
		(return default)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Setf expander for getf

(define-setf-expander getf (place indicator &optional default &environment env)
  (let ((indicator-var (gensym))
	(default-var (gensym))
	(value-var (gensym)))
    (multiple-value-bind (vars vals store-vars writer-form reader-form)
	(get-setf-expansion place env)
      (values (append vars (list indicator-var default-var))
	      (append vals (list indicator default))
	      (list value-var)
	      `(let ((,default-var ,default-var))
		 (declare (ignore ,default-var))
		 (loop for rest on ,reader-form by #'cddr
		       when (eq (car rest) ,indicator-var)
			 do (setf (cadr rest) ,value-var)
			    (return nil)
		       finally (let ((,(car store-vars)
				      (list* ,indicator-var ,value-var ,reader-form)))
				 ,writer-form))
		 ,value-var)
	      `(getf ,reader-form ,indicator-var ,default)))))
[
