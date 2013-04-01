;;; internal/asdf-setup.lisp -- ASDF setup stuff
;;;
;;; Part of clbuild, a wrapper script for Lisp invocation with quicklisp
;;; preloaded.  Based on code from clbuild by Luke Gorrie and
;;; contributors.

;;; At this point, quicklisp already been set up.  We count on quicklisp
;;; to load the right version of ASDF.

(defpackage :clbuild
  (:use :cl)
  (:export "FIX-CENTRAL-REGISTRY"))

(in-package :clbuild)

;;;;
;;;; central registry
;;;;

;; In good old clbuild tradition, we clean out all the annoying ~/.sbcl
;; and *d-p-d* junk from the central registry, which usually only
;; conflicts with clbuild and quicklisp for no good reason.
;;
(defun clbuild:fix-central-registry (base-dir)
  (setf asdf:*central-registry*
	(cons (merge-pathnames "systems/" base-dir)
	      (remove-if-not (lambda (x)
			       (let ((y (namestring (eval x))))
				 (search "quicklisp" y)))
			     asdf:*central-registry*)))
  (let ((conf (merge-pathnames "conf.lisp" base-dir)))
    (when (probe-file conf)
      (load conf))))


;;;;
;;;; source registry
;;;;

;; Only that these days, we also need to clean out the mess found in the
;; source registry, which still contains #+sbcl ~/.sbcl and related
;; insanities.
;;
(when (hash-table-p asdf::*source-registry*)
  (maphash #'(lambda (key value)
	       (unless (or #+sbcl (search "/sb-" (namestring value)))
		 (remhash key asdf::*source-registry*)))
	   asdf::*source-registry*))
