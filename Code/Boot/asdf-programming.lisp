(cl:in-package #:sicl-boot)

(defclass load-op (asdf/action:downward-operation asdf/action:selfward-operation)
  ((asdf:selfward-operation :initform '(prepare-op) :allocation :class)))

(defclass prepare-op (asdf/action:upward-operation asdf/action:sideway-operation)
  ((asdf:sideway-operation :initform 'load-op :allocation :class)))

(defmethod asdf:perform ((operation load-op) component)
  (format *trace-output*
          "Not acting upon component ~s~%"
          component))

(defvar *environment*)

(defmethod asdf:perform
    ((operation load-op) (component asdf/lisp-action:cl-source-file))
  (load-source-file-common
   (asdf/component:component-pathname component)
   *environment*))

(defmethod asdf:perform ((operation load-op) (component asdf/system:system))
  (format *trace-output*
          "Done loading system ~s~%"
          component))

(defmethod asdf:perform ((operation prepare-op) component)
  (declare (ignore component))
  nil)

(defmethod asdf:perform ((operation prepare-op) (component asdf/system:system))
  (format *trace-output*
          "Loading system ~s~%"
          component))

(defmethod asdf/action:compute-action-stamp
    (plan (operation prepare-op) component &key just-done)
  (if just-done
      (values (get-universal-time) t)
      (values nil nil)))

(defmethod asdf/action:compute-action-stamp
    (plan (operation load-op) component &key just-done)
  (if just-done
      (values (get-universal-time) t)
      (values nil nil)))

(defmethod asdf/action:compute-action-stamp
    (plan (operation load-op) (component asdf/lisp-action:cl-source-file) &key just-done)
  (if just-done
      (values (get-universal-time) t)
      (let* ((files (loaded-files *environment*))
             (path (asdf/component:component-pathname component))
             (entry (assoc path files :test #'equal)))
        (if (null entry)
            (values nil nil)
            (values (cdr entry) t)))))

(defun load-asdf-system (asdf-system-name environment)
  (let ((*environment* environment))
    (asdf:operate (asdf:make-operation 'load-op)
                  (asdf:find-system asdf-system-name))))
