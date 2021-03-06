(defun find-from-end-2 (x list)
  (declare (optimize (speed 3) (debug 0) (safety 0)))
  (declare (type list list))
  (labels ((recursive (x list n)
	     (declare (type fixnum n))
	     (if (zerop n)
		 nil
		 (progn (recursive x (cdr list) (1- n))
			(when (eq x (car list))
			  (return-from find-from-end-2 x))))))
    (labels ((aux (x list n)
	     (declare (type fixnum n))
	       (if (< n 10000)
		   (recursive x list n)
		   (let* ((n/2 (ash n -1))
			  (half (nthcdr n/2 list)))
		     (aux x half (- n n/2))
		     (aux x list n/2)))))
      (aux x list (length list)))))
