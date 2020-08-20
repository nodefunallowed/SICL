(cl:in-package #:sicl-arithmetic)

(defmethod generic-round ((number fixnum) (divisor fixnum))
  (cond ((zerop divisor)
         (error 'division-by-zero
                :operation 'round
                :operands (list number divisor)))
        ((zerop number)
         (values 0 0))
        ((minusp number)
         (if (minusp divisor)
             (multiple-value-bind (quotient remainder)
                 (cleavir-primop:fixnum-divide (- number) (- divisor))
               (let ((diff (- (+ divisor remainder))))
                 (cond ((> diff remainder)
                        (values quotient (- remainder)))
                       ((< diff remainder)
                        (values (1+ quotient) diff))
                       (t
                        (if (evenp quotient)
                            (values quotient (- remainder))
                            (values (1+ quotient) diff))))))
             (multiple-value-bind (quotient remainder)
                 (cleavir-primop:fixnum-divide (- number) divisor)
               (let ((diff (- divisor remainder)))
                 (cond ((> diff remainder)
                        (values (- quotient) (- remainder)))
                       ((< diff remainder)
                        (values (- (1+ quotient)) diff))
                       (t
                        (if (evenp quotient)
                            (values (- quotient) (- remainder))
                            (values (- (1+ quotient)) diff))))))))
        (t
         (if (minusp divisor)
             (multiple-value-bind (quotient remainder)
                 (cleavir-primop:fixnum-divide number (- divisor))
               (let ((diff (- (+ divisor remainder))))
                 (cond ((> diff remainder)
                        (values (- quotient) remainder))
                       ((< diff remainder)
                        (values (- (1+ quotient)) (- diff)))
                       (t
                        (if (evenp quotient)
                            (values (- quotient) remainder)
                            (values (- (1+ quotient)) (- diff)))))))
             (multiple-value-bind (quotient remainder)
                 (cleavir-primop:fixnum-divide number divisor)
               (let ((diff (- divisor remainder)))
                 (cond ((> diff remainder)
                        (values quotient remainder))
                       ((< diff remainder)
                        (values (1+ quotient) (- diff)))
                       (t
                        (if (evenp quotient)
                            (values quotient remainder)
                            (values (1+ quotient) (- diff)))))))))))