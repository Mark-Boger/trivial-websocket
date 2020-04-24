(in-package :trivial-websockets)

(defun %read-fin (byte)
  (logand +fin+ byte))

(defun %read-rsv1 (byte)
  (logand +rsv1+ byte))

(defun %read-rsv2 (byte)
  (logand +rsv2+ byte))

(defun %read-rsv3 (byte)
  (logand +rsv3+ byte))

(defun %read-op (byte)
  (logand +op+ byte))

(defun %read-mask (byte)
  (logand +mask+ byte))

(defun %read-payload-length (byte stream)
  (declare (ignore stream))
  (let ((len (logand +len+ byte)))
    len))

(defgeneric handle-op (stream type payload))

(defmethod handle-op (stream (type (eql :utf-8)) payload)
  (read-sequence payload stream)
  (flexi-streams:octets-to-string payload :external-format type))

(defun read-ws (stream)
  (let ((buffer (make-array 2 :element-type '(unsigned-byte 8)))
        (fin/rsv*/op nil)
        (mask/len nil))
    (unless (= 2 (read-sequence buffer stream))
      (error "Couldn't read first 2 bytes from ws stream"))
    (setf fin/rsv*/op (aref buffer 0))
    (setf mask/len (aref buffer 1))
    (let* ((fin (%read-fin fin/rsv*/op))
           (rsv1 (%read-rsv1 fin/rsv*/op))
           (rsv2 (%read-rsv2 fin/rsv*/op))
           (rsv3 (%read-rsv3 fin/rsv*/op))
           (op (%read-op fin/rsv*/op))
           (mask (%read-mask mask/len))
           (payload-len (%read-payload-length mask/len stream))
           (payload (make-array payload-len :element-type '(unsigned-byte 8)))
           (type (case op
                   (#x0 :cont)
                   (#x1 :utf-8)
                   (#x2 :binary)
                   (#x8 :close)
                   (#x9 :ping)
                   (#xA :pong)
                   (t (error "Illegal op code ~A" op)))))
      (values (handle-op stream type payload) fin rsv1 rsv2 rsv3 mask payload-len))))

(defun send-string (string stream &optional (mask nil))
  (let ((string-length (length
                        (flexi-streams:string-to-octets string :external-format :utf-8))))
    (write-byte (logior +fin+ +text-op+) stream)
    (write-byte (logior (if mask 1 0) string-length) stream)
    (write-string string stream)
    (force-output stream)))
