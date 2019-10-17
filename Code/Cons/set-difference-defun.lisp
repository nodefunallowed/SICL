(cl:in-package #:sicl-cons)

(defun |set-difference key=identity test=eql| (name list1 list2)
  (let ((result '()))
    (with-proper-list-elements (element list1 name)
      (unless (|member test=eql key=identity| name element list2)
        (push element result)))
    result))

(defun |set-difference key=identity test=eq| (name list1 list2)
  (let ((result '()))
    (with-proper-list-elements (element list1 name)
      (unless (|member test=eq key=identity| name element list2)
        (push element result)))
    result))

(defun |set-difference key=other test=eql| (name list1 list2 key)
  (let ((result '()))
    (with-proper-list-elements (element list1 name)
      (unless (|member test=eql key=other| name (funcall key element) list2 key)
        (push element result)))
    result))

(defun |set-difference key=other test=eq| (name list1 list2 key)
  (let ((result '()))
    (with-proper-list-elements (element list1 name)
      (unless (|member test=eq key=other| name (funcall key element) list2 key)
        (push element result)))
    result))

(defun |set-difference key=identity test=other| (name list1 list2 test)
  (let ((result '()))
    (with-proper-list-elements (element list1 name)
      (unless (|member test=other key=identity| name element list2  test)
        (push element result)))
    result))

(defun |set-difference key=other test=other| (name list1 list2 key test)
  (let ((result '()))
    (with-proper-list-elements (element list1 name)
      (unless (|member test=other key=other| name (funcall key element) list2 test key)
        (push element result)))
    result))

(defun |set-difference key=identity test-not=other| (name list1 list2 test-not)
  (let ((result '()))
    (with-proper-list-elements (element list1 name)
      (unless (|member test-not=other key=identity| name element list2 test-not)
        (push element result)))
    result))

(defun |set-difference key=other test-not=other| (name list1 list2 key test-not)
  (let ((result '()))
    (with-proper-list-elements (element list1 name)
      (unless (|member test-not=other key=other| name (funcall key element) list2 test-not key)
        (push element result)))
    result))

(defun |set-difference key=identity test=eq hash| (name list1 list2)
  (let ((table (make-hash-table :test #'eq))
        (result '()))
    (with-proper-list-elements (element list2 name)
      (setf (gethash element table) t))
    (with-proper-list-elements (element list1 name)
      (unless (gethash element table)
        (push element result)))
    result))

(defun |set-difference key=identity test=eql hash| (name list1 list2)
  (let ((table (make-hash-table :test #'eql))
        (result '()))
    (with-proper-list-elements (element list2 name)
      (setf (gethash element table) t))
    (with-proper-list-elements (element list1 name)
      (unless (gethash element table)
        (push element result)))
    result))

(defun |set-difference key=identity test=equal hash| (name list1 list2)
  (let ((table (make-hash-table :test #'equal))
        (result '()))
    (with-proper-list-elements (element list2 name)
      (setf (gethash element table) t))
    (with-proper-list-elements (element list1 name)
      (unless (gethash element table)
        (push element result)))
    result))

(defun |set-difference key=identity test=equalp hash| (name list1 list2)
  (let ((table (make-hash-table :test #'equalp))
        (result '()))
    (with-proper-list-elements (element list2 name)
      (setf (gethash element table) t))
    (with-proper-list-elements (element list1 name)
      (unless (gethash element table)
        (push element result)))
    result))

(defun |set-difference key=other test=eq hash| (name list1 list2 key)
  (let ((table (make-hash-table :test #'eq))
        (result '()))
    (with-proper-list-elements (element list2 name)
      (setf (gethash (funcall key element) table) t))
    (with-proper-list-elements (element list1 name)
      (unless (gethash (funcall key element) table)
        (push element result)))
    result))

(defun |set-difference key=other test=eql hash| (name list1 list2 key)
  (let ((table (make-hash-table :test #'eql))
        (result '()))
    (with-proper-list-elements (element list2 name)
      (setf (gethash (funcall key element) table) t))
    (with-proper-list-elements (element list1 name)
      (unless (gethash (funcall key element) table)
        (push element result)))
    result))

(defun |set-difference key=other test=equal hash| (name list1 list2 key)
  (let ((table (make-hash-table :test #'equal))
        (result '()))
    (with-proper-list-elements (element list2 name)
      (setf (gethash (funcall key element) table) t))
    (with-proper-list-elements (element list1 name)
      (unless (gethash (funcall key element) table)
        (push element result)))
    result))

(defun |set-difference key=other test=equalp hash| (name list1 list2 key)
  (let ((table (make-hash-table :test #'equalp))
        (result '()))
    (with-proper-list-elements (element list2 name)
      (setf (gethash (funcall key element) table) t))
    (with-proper-list-elements (element list1 name)
      (unless (gethash (funcall key element) table)
        (push element result)))
    result))

(defun set-difference (list1 list2
                       &key key (test nil test-given) (test-not nil test-not-given))
  (when (and test-given test-not-given)
    (error 'both-test-and-test-not-given :name 'set-difference))
  (let ((use-hash (> (* (length list1) (length list2)) 1000)))
    (if key
        (if test-given
            (cond ((or (eq test #'eq) (eq test 'eq))
                   (if use-hash
                       (|set-difference key=other test=eq hash| 'set-difference list1 list2 key)
                       (|set-difference key=other test=eq| 'set-difference list1 list2 key)))
                  ((or (eq test #'eql) (eq test 'eql))
                   (if use-hash
                       (|set-difference key=other test=eql hash| 'set-difference list1 list2 key)
                       (|set-difference key=other test=eql| 'set-difference list1 list2 key)))
                  ((or (eq test #'equal) (eq test 'equal))
                   (if use-hash
                       (|set-difference key=other test=equal hash| 'set-difference list1 list2 key)
                       (|set-difference key=other test=other| 'set-difference list1 list2 key #'equal)))
                  ((or (eq test #'equalp) (eq test 'equalp))
                   (if use-hash
                       (|set-difference key=other test=equalp hash| 'set-difference list1 list2 key)
                       (|set-difference key=other test=other| 'set-difference list1 list2 key #'equalp)))
                  (t
                   (|set-difference key=other test=other| 'set-difference list1 list2 key test)))
            (if test-not-given
                (|set-difference key=other test-not=other| 'set-difference list1 list2 key test-not)
                (if use-hash
                    (|set-difference key=other test=eql hash| 'set-difference list1 list2 key)
                    (|set-difference key=other test=eql| 'set-difference list1 list2 key))))
        (if test-given
            (cond ((or (eq test #'eq) (eq test 'eq))
                   (if use-hash
                       (|set-difference key=identity test=eq hash| 'set-difference list1 list2)
                       (|set-difference key=identity test=eq| 'set-difference list1 list2)))
                  ((or (eq test #'eql) (eq test 'eql))
                   (if use-hash
                       (|set-difference key=identity test=eql hash| 'set-difference list1 list2)
                       (|set-difference key=identity test=eql| 'set-difference list1 list2)))
                  ((or (eq test #'equal) (eq test 'equal))
                   (if use-hash
                       (|set-difference key=identity test=equal hash| 'set-difference list1 list2)
                       (|set-difference key=identity test=other| 'set-difference list1 list2 #'equal)))
                  ((or (eq test #'equalp) (eq test 'equalp))
                   (if use-hash
                       (|set-difference key=identity test=equalp hash| 'set-difference list1 list2)
                       (|set-difference key=identity test=other| 'set-difference list1 list2 #'equalp)))
                  (t
                   (|set-difference key=identity test=other| 'set-difference list1 list2 test)))
            (if test-not-given
                (|set-difference key=identity test-not=other| 'set-difference list1 list2 test-not)
                (if use-hash
                    (|set-difference key=identity test=eql hash| 'set-difference list1 list2)
                    (|set-difference key=identity test=eql| 'set-difference list1 list2)))))))