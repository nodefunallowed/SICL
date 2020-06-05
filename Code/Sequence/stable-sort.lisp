(cl:in-package #:sicl-sequence)

(defmethod stable-sort ((list list) predicate &key key)
  (let ((predicate (function-designator-function predicate)))
    (with-key-function (key key)
      (macrolet
          ;; We define a macro for sorting a given, small number of conses
          ;; by applying a certain permutation.  The expansion returns
          ;; three values: The first cons, the last cons, and the item that
          ;; used to be the rest of the rightmost supplied cons before
          ;; permuting.
          ((cons-sorter (conses permutation)
             (let* ((n (length conses))
                    (first-cons (nth (first permutation) conses))
                    (last-cons (nth (nth (1- n) permutation) conses)))
               (sicl-utilities:with-gensyms (rest)
                 `(let ((,rest (cdr ,(first (last conses)))))
                    ;; Set the correct successor for each cons.
                    ,@(loop repeat (1- n)
                            for (i j) on permutation
                            ;; As an optimization, do not set the CDR of a cons that
                            ;; already has the correct successor.
                            unless (= j (1+ i))
                              collect `(setf (cdr ,(nth i conses))
                                             ,(nth j conses)))
                    (setf (cdr ,last-cons) nil)
                    (values ,first-cons ,last-cons ,rest))))))
        ;; The actual stable sorting code consists of special cases for
        ;; sorting exactly two or three conses, and the general case of
        ;; sorting N conses.
        (labels ((stable-sort-2 (cons-1 &aux (cons-2 (cdr cons-1)))
                   (declare (cons cons-1 cons-2))
                   (let ((key-1 (key (car cons-1)))
                         (key-2 (key (car cons-2))))
                     (if (funcall predicate key-2 key-1)
                         (cons-sorter (cons-1 cons-2) (1 0))
                         (cons-sorter (cons-1 cons-2) (0 1)))))
                 (stable-sort-3 (cons-1 &aux (cons-2 (cdr cons-1)) (cons-3 (cdr cons-2)))
                   (declare (cons cons-1 cons-2 cons-3))
                   (let ((key-1 (key (car cons-1)))
                         (key-2 (key (car cons-2)))
                         (key-3 (key (car cons-3))))
                     (if (funcall predicate key-2 key-1)
                         (if (funcall predicate key-3 key-2)
                             (cons-sorter (cons-1 cons-2 cons-3) (2 1 0))
                             (if (funcall predicate key-3 key-1)
                                 (cons-sorter (cons-1 cons-2 cons-3) (1 2 0))
                                 (cons-sorter (cons-1 cons-2 cons-3) (1 0 2))))
                         (if (funcall predicate key-3 key-2)
                             (if (funcall predicate key-3 key-1)
                                 (cons-sorter (cons-1 cons-2 cons-3) (2 0 1))
                                 (cons-sorter (cons-1 cons-2 cons-3) (0 2 1)))
                             (cons-sorter (cons-1 cons-2 cons-3) (0 1 2))))))
                 (stable-sort-n (list n)
                   (case n
                     (2 (stable-sort-2 list))
                     (3 (stable-sort-3 list))
                     (otherwise
                      (let ((n/2 (floor n 2)))
                        (multiple-value-bind (list-1 tail-1 rest)
                            (stable-sort-n list n/2)
                          (multiple-value-bind (list-2 tail-2 rest)
                              (stable-sort-n rest (- n n/2))
                            (values
                             (merge 'list list-1 list-2 predicate :key key)
                             (if (null (cdr tail-1))
                                 tail-1
                                 tail-2)
                             rest))))))))
          (let ((n (length list)))
            ;; By handling the case of sorting zero elements and a single
            ;; element immediately, we ensure that the remaining code will
            ;; only ever deal with intervals of length two, three, or
            ;; larger than three.
            (case n
              ((0 1) list)
              (otherwise
               (values
                (stable-sort-n list n))))))))))
