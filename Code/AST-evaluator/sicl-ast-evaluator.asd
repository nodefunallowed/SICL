(cl:in-package #:asdf-user)

(defsystem #:sicl-ast-evaluator
  :depends-on (#:cleavir2-ast
               #:sicl-simple-environment)
  :serial t
  :components
  ((:file "packages")
   (:file "run-time")
   (:file "lexical-environment")
   (:file "translate-ast")))