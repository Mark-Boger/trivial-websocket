
(in-package :asdf-user)

(defsystem :trivial-websockets
  :description "Trivial implementation of websockets"
  :author ("Mark Boger <93mar.bog@gmail.com>"
           "Elijah Malaby")
  :depends-on (:flexi-streams)
  :version "0.0.0"
  :license "MIT"
  :pathname "src/"
  :serial t
  :components ((:file "package")
               (:file "byte-masks")
               (:file "framing")))
