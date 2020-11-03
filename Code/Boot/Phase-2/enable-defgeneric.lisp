(cl:in-package #:sicl-boot-phase-2)

;;; We want to make it possible to load FASL files containing
;;; definitions of generic functions in E3 so that the result is the
;;; creation of a host standard generic function in E3.
;;;
;;; Defining a generic function involves calling
;;; ENSURE-GENERIC-FUNCTION, passing the name, the lambda list, and
;;; the environment as arguments.  For that reason,
;;; ENSURE-GENERIC-FUNCTION must exist in that environment, which in
;;; this case is E3.
;;;
;;; The way we have chosen to do it is to provide a specific
;;; definition of ENSURE-GENERIC-FUNCTION.  We do not want to use the
;;; ordinary SICL version of ENSURE-GENERIC-FUNCTION because it
;;; requires a battery of additional functionality in the form of
;;; other generic functions.  So to keep things simple, we supply a
;;; special bootstrapping version of it.
;;;
;;; We can rely entirely on the host to execute the generic-function
;;; initialization protocol.

(defun enable-defgeneric (e3)
  (let ((client (env:client e3)))
    (setf (env:fdefinition client e3 'ensure-generic-function)
          (lambda (function-name &rest arguments &key &allow-other-keys)
            (let ((args (copy-list arguments)))
              (loop while (remf args :environment))
              (loop while (remf args :generic-function-class))
              (loop while (remf args :method-class))
              (if (env:fboundp client e3 function-name)
                  (env:fdefinition client e3 function-name)
                  (setf (env:fdefinition client e3 function-name)
                        (apply #'make-instance 'standard-generic-function
                               :name function-name
                               :method-combination
                               (closer-mop:find-method-combination
                                #'class-name 'standard '())
                               args))))))))
