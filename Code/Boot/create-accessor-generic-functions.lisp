(cl:in-package #:sicl-boot)

(defun enable-generic-function-initialization (ea)
  (flet ((ld (path)
           (load-source-file path ea)))
    (ld "CLOS/generic-function-initialization-support.lisp")
    (ld "CLOS/generic-function-initialization-defmethods.lisp")))

(defun create-accessor-defgenerics (ea)
  (flet ((ld (path)
           (load-source-file path ea)))
    (ld "CLOS/documentation-defgeneric.lisp")
    (ld "CLOS/setf-documentation-defgeneric.lisp")
    (ld "CLOS/class-slots-defgeneric.lisp")
    (ld "CLOS/setf-class-slots-defgeneric.lisp")
    (ld "CLOS/dependents-defgeneric.lisp")
    (ld "CLOS/setf-dependents-defgeneric.lisp")
    (ld "Arithmetic/numerator-defgeneric.lisp")
    (ld "Arithmetic/denominator-defgeneric.lisp")
    (ld "Array/array-dimensions-defgeneric.lisp")
    (ld "Array/vector-fill-pointer-defgeneric.lisp")
    (ld "Array/setf-vector-fill-pointer-defgeneric.lisp")
    (ld "Package-and-symbol/symbol-name-defgeneric.lisp")
    (ld "Package-and-symbol/symbol-package-defgeneric.lisp")))
