(in-package :trivial-websockets)

(defun bytes->fixnum (bytes &key from-end (size 8))
  (flet ((big (int byte)
           (logior (ash int size) byte))
         (little (byte int)
           (logior (ash int size) byte)))
    (let ((f (if (null from-end)
                 #'big
                 #'little)))
      (reduce f bytes :from-end from-end))))

